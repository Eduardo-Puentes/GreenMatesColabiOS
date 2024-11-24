import SwiftUI
import FirebaseAuth

@main
struct GreenMatesApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}


struct ContentView: View {
    @State private var isLoggedIn = false
    @State private var userInfo: User? = nil
    @State private var showLogin = true

    var body: some View {
        NavigationView {
            VStack {
                if isLoggedIn, let user = userInfo {
                    HomeScreen(
                        userInfo: user,
                        onLogout: {
                            isLoggedIn = false
                            userInfo = nil
                            showLogin = true
                        }
                    )
                } else {
                    if showLogin {
                        LoginScreen(
                            onLoginSuccess: { email, password in
                                signInWithFirebase(email: email, password: password) { success, fetchedUserInfo in
                                    if success, let fetchedUserInfo = fetchedUserInfo {
                                        isLoggedIn = true
                                        userInfo = fetchedUserInfo
                                    } else {
                                        // Error Login
                                    }
                                }
                            },
                            onNavigateToRegister: {
                                showLogin = false
                            }
                        )
                    } else {
                        RegisterScreen(onNavigateToLogin: { showLogin = true })
                    }
                }
            }
        }
    }
}


func signInWithFirebase(email: String, password: String, completion: @escaping (Bool, User?) -> Void) {
    Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
        if let error = error {
            print("Sign-in failed: \(error.localizedDescription)")
            completion(false, nil)
            return
        }
        
        if let user = authResult?.user {
            fetchUserData(uid: user.uid) { userInfo in
                completion(userInfo != nil, userInfo)
            }
        } else {
            completion(false, nil)
        }
    }
}

func fetchUserData(uid: String, completion: @escaping (User?) -> Void) {
    let url = URL(string: "https://7cae-189-156-240-57.ngrok-free.app/api/collaborator/\(uid)")!

    let task = URLSession.shared.dataTask(with: url) { data, response, error in
        guard let data = data, error == nil else {
            print("Network error: \(error?.localizedDescription ?? "Unknown error")")
            completion(nil)
            return
        }
        
        do {
            let userResponse = try JSONDecoder().decode(UserResponse.self, from: data)
            completion(userResponse.collaborator)
        } catch {
            print("Failed to decode user data: \(error.localizedDescription)")
            completion(nil)
        }
    }
    task.resume()
}
