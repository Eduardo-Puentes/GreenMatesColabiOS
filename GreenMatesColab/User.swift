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


