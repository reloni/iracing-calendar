import Vapor

public enum ApiUri {
    public static let base: URI = {
        "\(Environment.FrontendEnvVar.apiProtocol.value!)://\(Environment.FrontendEnvVar.apiHost.value!):\(Environment.FrontendEnvVar.apiPort.value!)"
    }()

    case allSeries
    case setFavoriteStatus
    case currentSeason
    case authorizeGoogle
    case favoriteSeries

    public var url: URI {
        switch self {
            case .allSeries: return "\(Self.base)/api/all-series"
            case .currentSeason: return "\(Self.base)/api/current-season"
            case .setFavoriteStatus: return "\(Self.base)/api/set-favorite-status"
            case .favoriteSeries: return "\(Self.base)/api/favorite-series"

            case .authorizeGoogle: return "\(Self.base)/oauth/authorize/google"
        }
    }
}