import Vapor

extension Environment {
    enum EnvVar: String, CaseIterable {
        case apiProtocol = "API_PROTOCOL"
        case apiHost = "API_HOST"
        case apiPort = "API_PORT"

        var value: String? {
            Environment.get(rawValue)
        }
    }
}