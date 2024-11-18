//
//  TContributionsScreen.swift
//  GreenMatesColab
//
//  Created by base on 17/11/24.
//


import SwiftUI

struct TContributionsScreen: View {
    @State private var showScanCodeTScreen = false
    let onClose: () -> Void
    let taller: getTaller

    var body: some View {
        VStack {
            if showScanCodeTScreen {
                ScanCodeTScreen(
                    onClose: { showScanCodeTScreen = false },
                    courseId: taller.courseID
                )
            } else {
                VStack(spacing: 16) {
                    Text("Ecoespacio")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.green)
                    
                    TallerDetailsBox(taller: taller)
                    
                    Text("Aportaciones")
                        .font(.title)
                        .fontWeight(.bold)
                        .padding(.top)
                    
                    ScrollView {
                        ForEach(taller.assistantArray, id: \.userFBID) { assistant in
                            ContributionEntryT(name: assistant.username)
                                .padding(.bottom, 8)
                        }
                    }
                    
                    Spacer()
                    
                    Button(action: { showScanCodeTScreen = true }) {
                        Text("Escanear Código")
                            .fontWeight(.bold)
                            .frame(maxWidth: .infinity, maxHeight: 50)
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(16)
                    }
                    
                    Button(action: onClose) {
                        Text("Regresar")
                            .fontWeight(.bold)
                            .frame(maxWidth: .infinity, maxHeight: 50)
                            .background(Color.gray)
                            .foregroundColor(.white)
                            .cornerRadius(16)
                    }
                }
                .padding()
            }
        }
    }
}

struct TallerDetailsBox: View {
    let taller: getTaller

    var body: some View {
        VStack {
            HStack {
                VStack(alignment: .leading) {
                    Text("Taller ID: \(taller.courseID)")
                        .fontWeight(.semibold)
                    Text("Ubicación: \(taller.latitude), \(taller.longitude)")
                }
                Spacer()
                CircularProgress(progress: 80) // Replace with dynamic progress if needed
            }
        }
        .padding()
        .background(Color.gray.opacity(0.2))
        .cornerRadius(16)
    }
}

struct CircularProgress: View {
    let progress: Int

    var body: some View {
        ZStack {
            Circle()
                .stroke(lineWidth: 6)
                .opacity(0.3)
                .foregroundColor(.green)
            Circle()
                .trim(from: 0.0, to: CGFloat(progress) / 100)
                .stroke(style: StrokeStyle(lineWidth: 6, lineCap: .round))
                .foregroundColor(.green)
                .rotationEffect(Angle(degrees: -90))
            Text("\(progress)%")
                .font(.footnote)
                .fontWeight(.bold)
                .foregroundColor(.green)
        }
        .frame(width: 48, height: 48)
    }
}

struct ContributionEntryT: View {
    let name: String

    var body: some View {
        HStack {
            Text(name)
                .fontWeight(.semibold)
            Spacer()
            Text("Asistió")
                .font(.title3)
                .fontWeight(.bold)
        }
        .padding()
        .background(Color.gray.opacity(0.2))
        .cornerRadius(16)
    }
}

struct ScanCodeTScreen: View {
    let onClose: () -> Void
    let courseId: String

    @State private var userFBID: String = ""
    @State private var errorMessage: String? = nil
    @State private var isLoading: Bool = false

    var body: some View {
        VStack {
            Text("Ecoespacio")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.green)
                .padding()

            Text("Registro de Asistencia al Taller")
                .font(.title2)
                .fontWeight(.semibold)
                .padding()

            Spacer()

            Text("Escanea código de usuario")
                .font(.headline)
                .padding()

            // Placeholder for QR Code Scanner
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.gray.opacity(0.3))
                .frame(width: 200, height: 200)
                .overlay(Text("QR Code Scanner Placeholder").foregroundColor(.gray))

            Spacer()

            // User FBID Input
            TextField("User FBID", text: $userFBID)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

            if let errorMessage = errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .padding(.bottom)
            }

            Button(action: {
                handleAddAssistance()
            }) {
                if isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: 50)
                        .background(Color.green.opacity(0.8))
                        .foregroundColor(.white)
                        .cornerRadius(16)
                } else {
                    Text("Confirmar Asistencia")
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity, maxHeight: 50)
                        .background(Color.green.opacity(0.8))
                        .foregroundColor(.white)
                        .cornerRadius(16)
                }
            }
            .disabled(isLoading || userFBID.isEmpty)
            .padding()

            Button(action: onClose) {
                Text("Regresar")
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, maxHeight: 50)
                    .background(Color.gray.opacity(0.3))
                    .foregroundColor(.white)
                    .cornerRadius(16)
            }
            .padding()
        }
        .padding()
    }

    private func handleAddAssistance() {
        guard !userFBID.isEmpty else {
            errorMessage = "Por favor ingrese el ID del usuario."
            return
        }

        isLoading = true
        errorMessage = nil

        let body = TallerRequestBody(UserFBID: userFBID)

        GreenMatesApi.shared.addAssistance(courseId: courseId, body: body) { result in
            DispatchQueue.main.async {
                isLoading = false
                switch result {
                case .success:
                    onClose()
                case .failure(let error):
                    errorMessage = "Error al registrar asistencia: \(error.localizedDescription)"
                }
            }
        }
    }
}

