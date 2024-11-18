import SwiftUI
import MapKit

struct CreateTallerScreen: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var title: String = ""
    @State private var selectedPillar: String = ""
    @State private var date: String = ""
    @State private var startTime: String = ""
    @State private var endTime: String = ""
    @State private var selectedLocation: CLLocationCoordinate2D? = nil
    @State private var limit: String = ""
    @State private var errorMessage: String? = nil
    @State private var isLoading: Bool = false
    
    let userInfo: User
    let onClose: () -> Void
    
    var body: some View {
        NavigationView {
            VStack {
                Text("Crear Nuevo Taller")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.green)
                
                Form {
                    Section(header: Text("Detalles del Taller")) {
                        TextField("Nombre del Taller", text: $title)
                        TextField("Cupo máximo", text: $limit)
                            .keyboardType(.numberPad)
                    }
                    
                    Section(header: Text("Categoría del Taller")) {
                        HStack {
                            PillarCheckbox(label: "Transporte", selectedPillar: $selectedPillar, value: "TRANSPORTE")
                            PillarCheckbox(label: "Energía", selectedPillar: $selectedPillar, value: "ENERGIA")
                        }
                        HStack {
                            PillarCheckbox(label: "Consumo", selectedPillar: $selectedPillar, value: "CONSUMO")
                            PillarCheckbox(label: "Desecho", selectedPillar: $selectedPillar, value: "DESECHO")
                        }
                    }
                    
                    Section(header: Text("Ubicación")) {
                        MapView(selectedLocation: $selectedLocation)
                            .frame(height: 250)
                        
                        if let selectedLocation = selectedLocation {
                            Text("Lat: \(selectedLocation.latitude), Lng: \(selectedLocation.longitude)")
                        } else {
                            Text("No se ha seleccionado ubicación")
                                .foregroundColor(.gray)
                        }
                    }
                    
                    Section(header: Text("Horario")) {
                        TextField("Fecha (yyyy-MM-dd)", text: $date)
                        HStack {
                            TimeInputField(label: "Hora de inicio", time: $startTime)
                            TimeInputField(label: "Hora de fin", time: $endTime)
                        }
                    }
                }
                
                if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                }
                
                HStack {
                    Button(action: handleCreateTaller) {
                        Text("Crear")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                    .disabled(isLoading || !isFormValid())
                    
                    Button(action: { presentationMode.wrappedValue.dismiss() }) {
                        Text("Cancelar")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.gray)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                }
                .padding()
            }
            .navigationBarHidden(true)
        }
    }
    
    private func isFormValid() -> Bool {
        !title.isEmpty && !limit.isEmpty && !selectedPillar.isEmpty &&
        !date.isEmpty && !startTime.isEmpty && !endTime.isEmpty &&
        selectedLocation != nil
    }
    
    private func handleCreateTaller() {
        guard let latitude = selectedLocation?.latitude,
              let longitude = selectedLocation?.longitude,
              let limitInt = Int(limit) else {
            errorMessage = "Por favor completa todos los campos correctamente."
            return
        }
        
        let dateFormatter = ISO8601DateFormatter()
        dateFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        
        let startDateTimeString = "\(date)T\(startTime):00Z"
        let endDateTimeString = "\(date)T\(endTime):00Z"
        
        guard let startDateTime = dateFormatter.date(from: startDateTimeString),
              let endDateTime = dateFormatter.date(from: endDateTimeString) else {
            errorMessage = "Error al formatear fecha u hora."
            return
        }
        
        let taller = Taller(
            collaboratorFBID: userInfo.FBID,
            title: title,
            pillar: selectedPillar,
            startTime: startDateTime,
            endTime: endDateTime,
            longitude: longitude,
            latitude: latitude,
            limit: limitInt
        )
        
        isLoading = true
        GreenMatesApi.shared.addWorkshop(taller: taller) { result in
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

struct PillarCheckbox: View {
    let label: String
    @Binding var selectedPillar: String
    let value: String
    
    var body: some View {
        HStack {
            Button(action: {
                selectedPillar = value
            }) {
                HStack {
                    Circle()
                        .strokeBorder(selectedPillar == value ? Color.green : Color.gray, lineWidth: 2)
                        .background(selectedPillar == value ? Color.green : Color.clear)
                        .frame(width: 24, height: 24)
                    
                    Text(label)
                }
            }
        }
    }
}

struct TimeInputField: View {
    let label: String
    @Binding var time: String
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(label)
                .font(.caption)
            TextField("HH:mm", text: $time)
                .keyboardType(.numbersAndPunctuation)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .frame(width: 100)
        }
    }
}

