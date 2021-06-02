import Vapor

public struct SessionUser: Codable {
    public let user: User
    public let token: GoogleTokenData

    public init(user: User, token: GoogleTokenData) {
        self.user = user
        self.token = token
    }
}