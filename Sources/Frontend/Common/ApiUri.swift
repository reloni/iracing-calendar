import Vapor

enum ApiUri {
    static let base: URI = {
        "\(Environment.EnvVar.apiProtocol.value!)://\(Environment.EnvVar.apiHost.value!):\(Environment.EnvVar.apiPort.value!)"
    }()

    case allSeries
    case setFavoriteStatus
    case currentSeason

    var url: URI {
        switch self {
            case .allSeries: return "\(Self.base)/api/all-series"
            case .currentSeason: return "\(Self.base)/api/current-season"
            case .setFavoriteStatus: return "\(Self.base)/api/set-favorite-status"
        }
    }
}