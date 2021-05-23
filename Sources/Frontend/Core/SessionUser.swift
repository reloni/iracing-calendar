import Vapor

struct SessionUser: Codable {
    let uuid: UUID
    let name: String
    let email: String
    let profileImage: String?
    let token: GoogleTokenData
}