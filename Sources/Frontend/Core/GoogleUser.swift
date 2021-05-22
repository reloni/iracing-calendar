import Vapor

struct GoogleUser: Codable {
    let name: String?
    let email: String
    let picture: URL?
}