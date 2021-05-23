import Vapor

public struct SessionUser: Codable {
    public let uuid: UUID
    public let name: String
    public let email: String
    public let profileImage: String?
    public let token: GoogleTokenData

    public init(uuid: UUID,
                name: String,
                email: String,
                profileImage: String?,
                token: GoogleTokenData) {
        self.uuid = uuid
        self.name = name
        self.email = email
        self.profileImage = profileImage
        self.token = token
    }
}