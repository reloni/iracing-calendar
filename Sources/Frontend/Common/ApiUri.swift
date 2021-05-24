import Vapor

enum ApiUri {
    static let base: URI = {
        "\(Environment.EnvVar.apiProtocol.value!)://\(Environment.EnvVar.apiHost.value!):\(Environment.EnvVar.apiPort.value!)"
    }()

    case allSeries
    case setFavoriteStatus

    var url: URI {
        switch self {
            case .allSeries: return "\(Self.base)/api/all-series"
            case .setFavoriteStatus: return "\(Self.base)/api/set-favorite-status"
        }
    }
}