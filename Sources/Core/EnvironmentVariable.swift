import Vapor

public struct EnvironmentTag<T: CaseIterable> where T.AllCases.Element: RawRepresentable {
    public var variables: [String] { 
        return T.self.allCases.map { "\($0.rawValue)" } 
    }
    public var cases: T.Type { T.self }
}

extension Environment {
    public static var frontend: EnvironmentTag<FrontendEnvVar> { EnvironmentTag<FrontendEnvVar>() }

    public enum FrontendEnvVar: String, CaseIterable {
        case apiProtocol = "API_PROTOCOL"
        case apiHost = "API_HOST"
        case apiPort = "API_PORT"
        case googleClientid = "GOOGLE_CLIENT_ID"
        case googleClientSecret = "GOOGLE_CLIENT_SECRET"
        case googleCallbackUrl = "GOOGLE_CALLBACK_URL"
        case googleTokenExchangeUrl = "GOOGLE_TOKEN_EXCHANGE_URL"

        public var value: String? {
            Environment.get(rawValue)
        }
    }

    public enum BackendEnvVar: String, CaseIterable {
        case googleClientid = "GOOGLE_CLIENT_ID"

        public var value: String? {
            Environment.get(rawValue)
        }
    }
}