import SwiftUI

struct AddRecolectaScreen: View {
    let onClose: () -> Void
    let recolectaId: String
    let userFBID: String

    @State private var paper: Int = 0
    @State private var cardboard: Int = 0
    @State private var metal: Int = 0
    @State private var plastic: Int = 0
    @State private var glass: Int = 0
    @State private var tetrapack: Int = 0
    @State private var isLoading: Bool = false
    @State private var errorMessage: String? = nil

    var body: some View {
        NavigationView {
            VStack {
                Text("Ecoespacio")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.green)

                Text("Agregar Recolecta")
                    .font(.title2)
                    .fontWeight(.semibold)

                Spacer()

                VStack(spacing: 16) {
                    ItemInputRow(label: "Cartón", value: $cardboard)
                    ItemInputRow(label: "Vidrio", value: $glass)
                    ItemInputRow(label: "Plástico", value: $plastic)
                    ItemInputRow(label: "Tetrapack", value: $tetrapack)
                    ItemInputRow(label: "Papel", value: $paper)
                    ItemInputRow(label: "Metales", value: $metal)
                }
                .padding()

                if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                }

                Spacer()

                HStack {
                    Button(action: onClose) {
                        Text("Regresar")
                            .fontWeight(.bold)
                            .frame(maxWidth: .infinity, maxHeight: 50)
                            .background(Color.gray)
                            .foregroundColor(.white)
                            .cornerRadius(16)
                    }

                    Button(action: {
                        handleAddRecolecta()
                    }) {
                        if isLoading {
                            ProgressView()
                                .frame(maxWidth: .infinity, maxHeight: 50)
                                .background(Color.green)
                                .cornerRadius(16)
                        } else {
                            Text("Registrar")
                                .fontWeight(.bold)
                                .frame(maxWidth: .infinity, maxHeight: 50)
                                .background(Color.green)
                                .foregroundColor(.white)
                                .cornerRadius(16)
                        }
                    }
                    .disabled(isLoading)
                }
                .padding()
            }
            .padding()
        }
    }

    private func handleAddRecolecta() {
        isLoading = true
        errorMessage = nil

        let body = RecolectaRequestBody(
            UserFBID: userFBID,
            Paper: paper,
            Cardboard: cardboard,
            Metal: metal,
            Plastic: plastic,
            Glass: glass,
            Tetrapack: tetrapack
        )

        GreenMatesApi.shared.addToRecolecta(
            recollectId: recolectaId,
            body: body
        ) { result in
            DispatchQueue.main.async {
                isLoading = false
                switch result {
                case .success:
                    onClose()
                case .failure(let error):
                    errorMessage = "Error: \(error.localizedDescription)"
                }
            }
        }
    }
}

struct ItemInputRow: View {
    let label: String
    @Binding var value: Int

    var body: some View {
        HStack {
            Text(label)
                .fontWeight(.bold)
                .frame(maxWidth: .infinity, alignment: .leading)

            TextField("0", value: $value, formatter: NumberFormatter())
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .keyboardType(.numberPad)
                .frame(width: 100)

            Text("kg")
                .fontWeight(.bold)
        }
        .padding(.vertical, 8)
    }
}
