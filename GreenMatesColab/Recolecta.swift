//
//  Recolecta.swift
//  GreenMatesColab
//
//  Created by base on 17/11/24.
//


import Foundation

struct Recolecta: Codable {
    let CollaboratorFBID: String
    let StartTime: Date
    let EndTime: Date
    let Longitude: Double
    let Latitude: Double
    let Limit: Int
}
