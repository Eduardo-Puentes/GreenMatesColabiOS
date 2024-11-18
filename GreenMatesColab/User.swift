//
//  User.swift
//  GreenMatesColab
//
//  Created by base on 17/11/24.
//


import Foundation

struct UserResponse: Codable {
    let collaborator: User
}

struct User: Codable {
    let CollaboratorID: String
    let FBID: String
    let Username: String
    let Email: String
}


