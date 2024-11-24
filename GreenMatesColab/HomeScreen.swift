import SwiftUI

struct HomeScreen: View {
    @State private var showCreateRecolectaScreen = false
    @State private var showCreateTallerScreen = false
    @State private var showTContributionsScreen = false
    @State private var showRContributionsScreen = false
    @State private var recolectaToShow: getRecolecta? = nil
    @State private var tallerToShow: getTaller? = nil
    @State private var talleres: [getTaller] = []
    @State private var recolectas: [getRecolecta] = []
    @State private var isLoading = false
    @State private var errorMessage: String? = nil
    
    @Environment(\.presentationMode) var presentationMode

    var userInfo: User
    var onLogout: () -> Void

    var body: some View {
        NavigationStack {
            if showCreateRecolectaScreen {
                CreateRecolectaScreen(userInfo: userInfo, onClose: {
                    showCreateRecolectaScreen = false
                    fetchRecolectas(userID: userInfo.FBID)
                })
            } else if showCreateTallerScreen {
                CreateTallerScreen(userInfo: userInfo, onClose: {
                    showCreateTallerScreen = false
                    fetchTalleres(userID: userInfo.FBID)
                })
            } else if showTContributionsScreen, let taller = tallerToShow {
                TContributionsScreen(onClose: { showTContributionsScreen = false; fetchTalleres(userID: userInfo.FBID) }, taller: taller)
            } else if showRContributionsScreen, let recolecta = recolectaToShow {
                RContributionsScreen(onClose: { showRContributionsScreen = false; fetchRecolectas(userID: userInfo.FBID) }, recolecta: recolecta)
            } else {
                ScrollView {
                    VStack(spacing: 16) {
                        Text("Ecoespacio")
                            .font(.largeTitle)
                            .bold()
                            .foregroundColor(Color.green)

                        if isLoading {
                            ProgressView("Cargando datos...")
                        } else if let errorMessage = errorMessage {
                            Text("Error: \(errorMessage)")
                                .foregroundColor(.red)
                        } else {
                            Text("Recolectas")
                                .font(.title2)
                                .bold()

                            if recolectas.isEmpty {
                                Text("No hay recolectas disponibles")
                                    .foregroundColor(.gray)
                            } else {
                                ForEach(recolectas) { recolecta in
                                    RecolectaCard(
                                        sdate: formatDateString(recolecta.startTime),
                                        edate: formatDateString(recolecta.endTime),
                                        location: "Ubicación: \(recolecta.latitude), \(recolecta.longitude)",
                                        progress: recolecta.donationArray.count * 100 / max(recolecta.limit, 1),
                                        onc: {
                                            showRContributionsScreen = true
                                            recolectaToShow = recolecta
                                        }
                                    )
                                }
                            }

                            CreateButton(text: "Crear Recolecta", onc: { showCreateRecolectaScreen = true })

                            Text("Talleres")
                                .font(.title2)
                                .bold()

                            if talleres.isEmpty {
                                Text("No hay talleres disponibles")
                                    .foregroundColor(.gray)
                            } else {
                                ForEach(talleres) { taller in
                                    TallerCard(
                                        title: taller.title ?? "",
                                        date: formatDateString(taller.startTime),
                                        address: "Ubicación: \(taller.latitude), \(taller.longitude)",
                                        progress: taller.assistantArray.count * 100 / max(taller.limit, 1),
                                        onc: {
                                            if let updatedTaller = talleres.first(where: { $0.courseID == taller.courseID }) {
                                                tallerToShow = updatedTaller
                                                showTContributionsScreen = true
                                            }
                                        }
                                    )
                                }
                            }

                            CreateButton(text: "Crear Taller", onc: { showCreateTallerScreen = true })
                        }
                    }
                    .padding()
                }
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Cerar Sesión") {
                            onLogout()
                        }
                        .foregroundColor(.red)
                    }
                }
            }
        }
        .onAppear {
            fetchRecolectas(userID: userInfo.FBID)
            fetchTalleres(userID: userInfo.FBID)
        }
    }


        func logout() {
            print("User logged out")
            presentationMode.wrappedValue.dismiss()
        }
    

    func fetchRecolectas(userID: String) {
        print("Fetching recolectas for userID: \(userID)")
        isLoading = true
        errorMessage = nil

        GreenMatesApi.shared.getRecolectas(uid: userID) { result in
            DispatchQueue.main.async {
                isLoading = false
                switch result {
                case .success(let fetchedRecolectas):
                    print("Fetched recolectas: \(fetchedRecolectas)")
                    recolectas = fetchedRecolectas.isEmpty ? [] : fetchedRecolectas
                case .failure(let error):
                    print("Error fetching recolectas: \(error.localizedDescription)")
                    recolectas = []
                }
            }
        }
    }

    func fetchTalleres(userID: String) {
        print("Fetching talleres for userID: \(userID)")
        isLoading = true
        errorMessage = nil

        GreenMatesApi.shared.getCourses(uid: userID) { result in
            DispatchQueue.main.async {
                isLoading = false
                switch result {
                case .success(let fetchedTalleres):
                    print("Fetched talleres: \(fetchedTalleres)")
                    talleres = fetchedTalleres.isEmpty ? [] : fetchedTalleres
                case .failure(let error):
                    print("Error fetching talleres: \(error.localizedDescription)")
                    talleres = []
                }
            }
        }
    }
}

struct RecolectaCard: View {
    let sdate: String
    let edate: String
    let location: String
    let progress: Int
    let onc: () -> Void
    
    var body: some View {
        HStack{
            VStack(alignment: .leading, spacing: 8) {
                Text("\(sdate) - \(edate)")
                    .bold()
                Text(location)
                Button(action: onc) {
                    Text("Ver Detalle")
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(8)
                }
            }
            Spacer()
            ZStack {
                Circle()
                    .stroke(lineWidth: 6)
                    .opacity(0.3)
                    .foregroundColor(Color.green)
                Circle()
                    .trim(from: 0.0, to: CGFloat(progress) / 100)
                    .stroke(style: StrokeStyle(lineWidth: 6, lineCap: .round, lineJoin: .round))
                    .foregroundColor(Color.green)
                    .rotationEffect(Angle(degrees: -90))
                Text("\(progress)%")
                    .bold()
            }
            .frame(width: 48, height: 48)
        }            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(12)
    }
}

struct TallerCard: View {
    let title: String
    let date: String
    let address: String
    let progress: Int
    let onc: () -> Void
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(title).bold()
                Text(date)
                Text(address)
                Button(action: onc) {
                    Text("Ver Detalle")
                        .padding()
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(8)
                }
            }
            Spacer()
            ZStack {
                Circle()
                    .stroke(lineWidth: 6)
                    .opacity(0.3)
                    .foregroundColor(Color.green)
                Circle()
                    .trim(from: 0.0, to: CGFloat(progress) / 100)
                    .stroke(style: StrokeStyle(lineWidth: 6, lineCap: .round, lineJoin: .round))
                    .foregroundColor(Color.green)
                    .rotationEffect(Angle(degrees: -90))
                Text("\(progress)%")
                    .bold()
            }
            .frame(width: 48, height: 48)
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
    }
}

func formatDateString(_ date: Date?) -> String {
    guard let date = date else { return "Fecha no disponible" }
    let formatter = DateFormatter()
    formatter.dateFormat = "dd-MM-yyyy HH:mm"
    return formatter.string(from: date)
}

struct CreateButton: View {
    let text: String
    let onc: () -> Void

    var body: some View {
        Button(action: onc) {
            Text("+ \(text)")
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity, maxHeight: 50)
                .background(Color.gray.opacity(0.2))
                .cornerRadius(16)
        }
    }
}

