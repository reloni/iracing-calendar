import Vapor

struct SessionUser: Codable {
    let uuid: UUID
    let name: String
    let email: String
    let token: GoogleTokenData
}