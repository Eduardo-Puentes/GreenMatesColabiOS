//
//  RecolectaRequestBody.swift
//  GreenMatesColab
//
//  Created by base on 17/11/24.
//


import Foundation

struct RecolectaRequestBody: Codable {
    let UserFBID: String
    let Paper: Int
    let Cardboard: Int
    let Metal: Int
    let Plastic: Int
    let Glass: Int
    let Tetrapack: Int
}

struct TallerRequestBody: Codable {
    let UserFBID: String
}

struct getTaller: Codable, Identifiable {
    let courseID: String
    let collaboratorFBID: String
    let title: String
    let pillar: String
    let startTime: Date
    let endTime: Date
    let longitude: Double
    let latitude: Double
    let limit: Int
    let assistantArray: [Assistant]
    
    var id: String { courseID }

    enum CodingKeys: String, CodingKey {
        case courseID = "CourseID"
        case collaboratorFBID = "CollaboratorFBID"
        case title = "Title"
        case pillar = "Pillar"
        case startTime = "StartTime"
        case endTime = "EndTime"
        case longitude = "Longitude"
        case latitude = "Latitude"
        case limit = "Limit"
        case assistantArray = "AssistantArray"
    }
}

struct Assistant: Codable {
    let userFBID: String
    let username: String
    let email: String

    enum CodingKeys: String, CodingKey {
        case userFBID = "UserFBID"
        case username = "Username"
        case email = "Email"
    }
}


struct getRecolecta: Codable, Identifiable {
    let recollectID: String
    let collaboratorFBID: String
    let startTime: Date
    let endTime: Date
    let longitude: Double
    let latitude: Double
    let limit: Int
    let donationArray: [Donation]
    
    var id: String { recollectID }

    enum CodingKeys: String, CodingKey {
        case recollectID = "RecollectID"
        case collaboratorFBID = "CollaboratorFBID"
        case startTime = "StartTime"
        case endTime = "EndTime"
        case longitude = "Longitude"
        case latitude = "Latitude"
        case limit = "Limit"
        case donationArray = "DonationArray"
    }
}

struct Donation: Codable {
    let userFBID: String
    let username: String
    let cardboard: Int
    let glass: Int
    let tetrapack: Int
    let plastic: Int
    let paper: Int
    let metal: Int

    enum CodingKeys: String, CodingKey {
        case userFBID = "UserFBID"
        case username = "Username"
        case cardboard = "Cardboard"
        case glass = "Glass"
        case tetrapack = "Tetrapack"
        case plastic = "Plastic"
        case paper = "Paper"
        case metal = "Metal"
    }
}



