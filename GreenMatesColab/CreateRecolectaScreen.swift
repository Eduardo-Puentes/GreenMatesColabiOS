//
//  CreateRecolectaScreen.swift
//  GreenMatesColab
//
//  Created by base on 17/11/24.
//


import SwiftUI
import MapKit

struct CreateRecolectaScreen: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var selectedDate: Date = Date()
    @State private var selectedStartTime: Date = Date()
    @State private var selectedEndTime: Date = Date()
    @State private var selectedLocation: CLLocationCoordinate2D? = nil
    @State private var limit: String = ""
    @State private var errorMessage: String? = nil
    @State private var isLoading: Bool = false
    
    let userInfo: User
    let onClose: () -> Void
    
    var body: some View {
        NavigationView {
            VStack {
                Text("Crear Nueva Recolecta")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.green)
                
                Form {
                    Section(header: Text("Detalles")) {
                        TextField("Límite de Participantes", text: $limit)
                            .keyboardType(.numberPad)
                        
                        DatePicker("Fecha", selection: $selectedDate, displayedComponents: .date)
                            .datePickerStyle(GraphicalDatePickerStyle())
                        
                        DatePicker("Hora de Inicio", selection: $selectedStartTime, displayedComponents: .hourAndMinute)
                            .datePickerStyle(WheelDatePickerStyle())
                        
                        DatePicker("Hora de Fin", selection: $selectedEndTime, displayedComponents: .hourAndMinute)
                            .datePickerStyle(WheelDatePickerStyle())
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
                }
                
                if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .padding()
                }
                
                HStack {
                    Button(action: handleCreateRecolecta) {
                        Text("Crear")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                    .disabled(isLoading || !isFormValid())
                    
                    Button(action: { onClose() }) {
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
        !limit.isEmpty && selectedLocation != nil
    }
    
    private func handleCreateRecolecta() {
        guard let latitude = selectedLocation?.latitude,
              let longitude = selectedLocation?.longitude,
              let limitInt = Int(limit) else {
            errorMessage = "Por favor completa todos los campos correctamente."
            return
        }
        
        let calendar = Calendar.current
        let startDateTime = calendar.date(bySettingHour: calendar.component(.hour, from: selectedStartTime),
                                          minute: calendar.component(.minute, from: selectedStartTime),
                                          second: 0, of: selectedDate)!
        
        let endDateTime = calendar.date(bySettingHour: calendar.component(.hour, from: selectedEndTime),
                                        minute: calendar.component(.minute, from: selectedEndTime),
                                        second: 0, of: selectedDate)!
        
        if endDateTime <= startDateTime {
            errorMessage = "La hora de fin debe ser después de la hora de inicio."
            return
        }
        
        let recolecta = Recolecta(
            CollaboratorFBID: userInfo.FBID,
            StartTime: startDateTime,
            EndTime: endDateTime,
            Longitude: longitude,
            Latitude: latitude,
            Limit: limitInt
        )
        
        isLoading = true
        GreenMatesApi.shared.addRecolecta(recolecta: recolecta) { result in
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

struct MapView: UIViewRepresentable {
    @Binding var selectedLocation: CLLocationCoordinate2D?
    
    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        mapView.showsUserLocation = true
        let initialLocation = CLLocationCoordinate2D(latitude: 19.4326, longitude: -99.1332)
        mapView.setRegion(MKCoordinateRegion(center: initialLocation, span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)), animated: true)
        let tapGesture = UITapGestureRecognizer(target: context.coordinator, action: #selector(context.coordinator.mapTapped(_:)))
        mapView.addGestureRecognizer(tapGesture)
        return mapView
    }
    
    func updateUIView(_ uiView: MKMapView, context: Context) {
        if let selectedLocation = selectedLocation {
            let annotation = MKPointAnnotation()
            annotation.coordinate = selectedLocation
            annotation.title = "Ubicación seleccionada"
            uiView.addAnnotation(annotation)
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: MapView
        
        init(_ parent: MapView) {
            self.parent = parent
        }
        
        @objc func mapTapped(_ gesture: UITapGestureRecognizer) {
            let mapView = gesture.view as! MKMapView
            let touchPoint = gesture.location(in: mapView)
            let coordinate = mapView.convert(touchPoint, toCoordinateFrom: mapView)
            parent.selectedLocation = coordinate
        }
    }
}
