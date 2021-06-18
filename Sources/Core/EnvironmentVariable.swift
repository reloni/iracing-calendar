import Vapor

public struct EnvironmentTag<T: CaseIterable> where T.AllCases.Element: RawRepresentable {
    public var variables: [String] {  T.self.allCases.map { "\($0.rawValue)" } }
    public var cases: T.Type { T.self }
}

extension Environment {
    public static var frontend: EnvironmentTag<FrontendEnvVar> { EnvironmentTag<FrontendEnvVar>() }
    public static var api: EnvironmentTag<ApiEnvVar> { EnvironmentTag<ApiEnvVar>() }

    public enum FrontendEnvVar: String, CaseIterable {
        case apiProtocol = "API_PROTOCOL"
        case apiHost = "API_HOST"
        case apiPort = "API_PORT"
        case googleClientId = "GOOGLE_CLIENT_ID"
        case googleClientSecret = "GOOGLE_CLIENT_SECRET"
        case googleCallbackUrl = "GOOGLE_CALLBACK_URL"
        case googleTokenExchangeUrl = "GOOGLE_TOKEN_EXCHANGE_URL"

        public var value: String? {
            Environment.get(rawValue)
        }
    }

    public enum ApiEnvVar: String, CaseIterable {
        case googleClientId = "GOOGLE_CLIENT_ID"
        case databaseHost = "DATABASE_HOST"
        case databasePort = "DATABASE_PORT"
        case databaseUserName = "DATABASE_USERNAME"
        case databasePassword = "DATABASE_PASSWORD"
        case databaseName = "DATABASE_NAME"
        case databaseSearchPath = "DATABASE_SEARCH_PATH"

        public var value: String? {
            Environment.get(rawValue)
        }
    }
}