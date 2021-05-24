import Vapor

extension Environment {
    enum EnvVar: String, CaseIterable {
        case callbackUrl = "GOOGLE_CALLBACK_URL"
        case clientId = "GOOGLE_CLIENT_ID"
        case clientSecret = "GOOGLE_CLIENT_SECRET"
        case tokenExchangeUrl = "GOOGLE_TOKEN_EXCHANGE_URL"

        var value: String? {
            Environment.get(rawValue)
        }
    }
}