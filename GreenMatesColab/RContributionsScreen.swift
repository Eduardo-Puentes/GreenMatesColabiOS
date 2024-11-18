//
//  RContributionsScreen.swift
//  GreenMatesColab
//
//  Created by base on 17/11/24.
//


import SwiftUI

struct RContributionsScreen: View {
    @State private var showScanCodeRScreen = false
    let onClose: () -> Void
    let recolecta: getRecolecta

    var body: some View {
        VStack {
            if showScanCodeRScreen {
                ScanCodeRScreen(
                    onClose: { showScanCodeRScreen = false },
                    recolectaId: recolecta.recollectID
                )
            } else {
                VStack(spacing: 16) {
                    Text("Ecoespacio")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.green)
                    
                    RecolectaDetailsBox(recolecta: recolecta)
                    
                    Text("Aportaciones")
                        .font(.title)
                        .fontWeight(.bold)
                        .padding(.top)
                    
                    ScrollView {
                        ForEach(recolecta.donationArray, id: \.userFBID) { donation in
                            let items = [
                                donation.cardboard > 0 ? "Cartón: \(donation.cardboard) kg" : nil,
                                donation.glass > 0 ? "Vidrio: \(donation.glass) kg" : nil,
                                donation.metal > 0 ? "Metales: \(donation.metal) kg" : nil,
                                donation.paper > 0 ? "Papel: \(donation.paper) kg" : nil,
                                donation.plastic > 0 ? "Plástico: \(donation.plastic) kg" : nil,
                                donation.tetrapack > 0 ? "Tetrapack: \(donation.tetrapack) kg" : nil
                            ].compactMap { $0 }
                            let total = donation.cardboard + donation.glass + donation.metal + donation.paper + donation.plastic + donation.tetrapack
                            ContributionEntry(name: donation.username, items: items, total: Int(total))
                        }
                    }
                    
                    Spacer()
                    
                    Button(action: { showScanCodeRScreen = true }) {
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

struct RecolectaDetailsBox: View {
    let recolecta: getRecolecta

    var body: some View {
        VStack {
            HStack {
                VStack(alignment: .leading) {
                    Text(recolecta.recollectID)
                        .fontWeight(.semibold)
                    Text("Ubicación: \(recolecta.latitude), \(recolecta.longitude)")
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

struct ContributionEntry: View {
    let name: String
    let items: [String]
    let total: Int

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(name)
                    .fontWeight(.semibold)
                ForEach(items, id: \.self) { item in
                    Text("• \(item)")
                }
            }
            Spacer()
            VStack {
                Text("\(total) kg")
                    .font(.title)
                    .fontWeight(.bold)
                Text("Total Aportado")
                    .font(.caption)
            }
        }
        .padding()
        .background(Color.gray.opacity(0.2))
        .cornerRadius(16)
    }
}

struct ScanCodeRScreen: View {
    let onClose: () -> Void
    let recolectaId: String
    
    @State private var showAddRecolectaScreen = false
    @State private var userFBID: String = "j2SLLR35SvakRrnbo5ZM9LGhURA2" // Default UserFBID
    
    var body: some View {
        if showAddRecolectaScreen {
            AddRecolectaScreen(onClose: { showAddRecolectaScreen = false }, recolectaId: recolectaId, userFBID: userFBID)
        } else {
            VStack(spacing: 24) {
                Text("Ecoespacio")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.green)
                
                Text("Registro de recolecta")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Text("Escanea código de usuario")
                    .font(.headline)
                
                // Simulate QR Code Scanner Box
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 200, height: 200)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.black, lineWidth: 2)
                    )
                
                Text("Recolecta ID: \(recolectaId)")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                
                // Input Field for Simulating User FBID
                VStack(alignment: .leading, spacing: 8) {
                    Text("User FBID")
                        .font(.headline)
                    TextField("Enter User FBID", text: $userFBID)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.horizontal)
                }
                
                Spacer()
                
                // Buttons
                HStack {
                    Button(action: onClose) {
                        Text("Regresar")
                            .fontWeight(.bold)
                            .frame(maxWidth: .infinity, maxHeight: 50)
                            .background(Color.gray)
                            .foregroundColor(.white)
                            .cornerRadius(16)
                    }
                    
                    Button(action: { showAddRecolectaScreen = true }) {
                        Text("Escanear")
                            .fontWeight(.bold)
                            .frame(maxWidth: .infinity, maxHeight: 50)
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(16)
                    }
                }
                .padding()
            }
            .padding()
        }
    }
}


