public struct GoogleToken: Codable {
    public let access_token: String
    public let expires_in: Int
    public let refresh_token: String
    public let scope: String
    public let token_type: String
    public let id_token: String

    public init(access_token: String,
                expires_in: Int,
                refresh_token: String,
                scope: String,
                token_type: String,
                id_token: String) {
        self.access_token = access_token
        self.expires_in = expires_in
        self.refresh_token = refresh_token
        self.scope = scope
        self.token_type = token_type
        self.id_token = id_token
    }
}