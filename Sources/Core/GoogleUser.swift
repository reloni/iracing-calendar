import Vapor

public struct GoogleUser: Codable, Content {
    public let name: String?
    public let email: String
    public let picture: URL?

    public init(name: String?,
                email: String,
                picture: URL?) {
        self.name = name
        self.email = email
        self.picture = picture
    }
}