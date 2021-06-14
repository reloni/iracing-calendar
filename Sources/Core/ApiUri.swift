import Vapor

public enum ApiUri {
    public static let base: URI = {
        "\(Environment.FrontendEnvVar.apiProtocol.value!)://\(Environment.FrontendEnvVar.apiHost.value!):\(Environment.FrontendEnvVar.apiPort.value!)"
    }()

    case allSeries
    case setFavoriteStatus
    case currentSeason
    case authorizeGoogle

    public var url: URI {
        switch self {
            case .allSeries: return "\(Self.base)/api/all-series"
            case .currentSeason: return "\(Self.base)/api/current-season"
            case .setFavoriteStatus: return "\(Self.base)/api/set-favorite-status"
            case .authorizeGoogle: return "\(Self.base)/api/oauth/authorize/google"
        }
    }
}