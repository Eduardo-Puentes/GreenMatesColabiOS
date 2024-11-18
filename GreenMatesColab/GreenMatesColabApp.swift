//
//  GreenMatesColabApp.swift
//  GreenMatesColab
//
//  Created by base on 17/11/24.
//

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
                    HomeScreen(userInfo: user)
                } else {
                    if showLogin {
                        LoginScreen(
                            onLoginSuccess: { email, password in
                                signInWithFirebase(email: email, password: password) { success, fetchedUserInfo in
                                    if success, let fetchedUserInfo = fetchedUserInfo {
                                        isLoggedIn = true
                                        userInfo = fetchedUserInfo
                                    } else {
                                        // Handle login failure
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
    let url = URL(string: "http://10.50.90.159:3000/api/collaborator/\(uid)")! // Update endpoint if necessary

    let task = URLSession.shared.dataTask(with: url) { data, response, error in
        guard let data = data, error == nil else {
            print("Network error: \(error?.localizedDescription ?? "Unknown error")")
            completion(nil)
            return
        }
        
        do {
            let userResponse = try JSONDecoder().decode(UserResponse.self, from: data)
            // Pass the collaborator (User) to the completion handler
            completion(userResponse.collaborator)
        } catch {
            print("Failed to decode user data: \(error.localizedDescription)")
            completion(nil)
        }
    }
    task.resume()
}
