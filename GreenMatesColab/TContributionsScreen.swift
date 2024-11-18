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
    let progress: Int // Progress as a percentage (0-100)

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

    var body: some View {
        VStack {
            Text("Escanear Código")
                .font(.largeTitle)
                .fontWeight(.bold)
            Text("Course ID: \(courseId)")
                .padding()
            Spacer()
            Button(action: onClose) {
                Text("Cerrar")
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
