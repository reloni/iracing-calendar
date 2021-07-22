import Vapor

public struct SessionUser: Codable {
    public let user: User
    public let token: GoogleToken

    public init(user: User, token: GoogleToken) {
        self.user = user
        self.token = token
    }
}