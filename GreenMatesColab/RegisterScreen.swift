import SwiftUI
import FirebaseAuth


struct RegisterScreen: View {
    @State private var username: String = ""
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var errorMessage: String? = nil
    
    let onNavigateToLogin: () -> Void
    
    var body: some View {
        VStack {
            Text("Crear Cuenta")
                .font(.title)
                .padding(.bottom, 20)
            
            TextField("Usuario", text: $username)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(8)
                .padding(.horizontal)
            
            TextField("Correo Electrónico", text: $email)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(8)
                .padding(.horizontal)
            
            SecureField("Contraseña", text: $password)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(8)
                .padding(.horizontal)
            
            if let errorMessage = errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .font(.caption)
                    .padding(.top, 10)
            }
            
            Button(action: {
                if username.isEmpty || email.isEmpty || password.isEmpty {
                    errorMessage = "All fields are required"
                } else {
                    errorMessage = nil
                    registerUser(username: username, email: email, password: password)
                }
            }) {
                GradientButton(text: "Crear Cuenta", colors: [Color.yellow, Color.green])
            }
            .padding(.top, 20)
            
            Text("o")
                .padding(.top, 20)
            
            Button(action: onNavigateToLogin) {
                GradientButton(text: "Iniciar Sesión", colors: [Color.green, Color.green])
            }
            .padding(.top, 20)
            
            Spacer()
        }
        .padding()
    }
}

func registerUser(username: String, email: String, password: String) {
    Auth.auth().createUser(withEmail: email, password: password) { result, error in
        if let error = error {
            print("Firebase registration failed: \(error.localizedDescription)")
            return
        }
        
        guard let user = result?.user else { return }
        let newUser = User(CollaboratorID: "", FBID: user.uid, Username: username, Email: email)
        
        registerUserInDatabase(user: newUser)
    }
}

func registerUserInDatabase(user: User) {
    guard let url = URL(string: "https://7cae-189-156-240-57.ngrok-free.app/api/collaborator") else { return }
    
    Auth.auth().currentUser?.getIDToken { token, error in
        if let error = error {
            print("Failed to get Firebase token: \(error.localizedDescription)")
            return
        }
        
        guard let token = token else {
            print("Firebase token is nil")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        do {
            let jsonData = try JSONEncoder().encode(user)
            request.httpBody = jsonData
        } catch {
            print("Failed to encode user data: \(error.localizedDescription)")
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Network error: \(error.localizedDescription)")
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                print("Response status code: \(httpResponse.statusCode)")
                if let data = data,
                   let responseString = String(data: data, encoding: .utf8) {
                    print("Response body: \(responseString)")
                }
                
                if httpResponse.statusCode == 200 || httpResponse.statusCode == 201 {
                    print("User successfully registered in the database")
                } else {
                    print("Failed to register user in database")
                }
            } else {
                print("Failed to get HTTP response")
            }
        }.resume()

    }
}
