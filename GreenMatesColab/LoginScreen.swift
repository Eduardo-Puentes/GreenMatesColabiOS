//
//  LoginScreen.swift
//  GreenMatesColab
//
//  Created by base on 17/11/24.
//


import SwiftUI
import FirebaseAuth

struct LoginScreen: View {
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var errorMessage: String? = nil
    
    let onLoginSuccess: (String, String) -> Void
    let onNavigateToRegister: () -> Void
    
    var body: some View {
        VStack {
            Text("Inicia Sesión")
                .font(.title)
                .padding(.bottom, 20)
            
            TextField("Usuario", text: $email)
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
                if email.isEmpty || password.isEmpty {
                    errorMessage = "Please enter both email and password"
                } else {
                    errorMessage = nil
                    onLoginSuccess(email, password)
                }
            }) {
                GradientButton(text: "Iniciar Sesión", colors: [Color.yellow, Color.green])
            }
            .padding(.top, 20)
            
            Text("o")
                .padding(.top, 20)
            
            Button(action: onNavigateToRegister) {
                GradientButton(text: "Crear Cuenta", colors: [Color.green, Color.green])
            }
            .padding(.top, 20)
            
            Spacer()
        }
        .padding()
    }
}

struct GradientButton: View {
    let text: String
    let colors: [Color]
    
    var body: some View {
        LinearGradient(gradient: Gradient(colors: colors), startPoint: .leading, endPoint: .trailing)
            .frame(height: 50)
            .cornerRadius(8)
            .overlay(
                Text(text)
                    .foregroundColor(.white)
                    .font(.headline)
            )
    }
}
