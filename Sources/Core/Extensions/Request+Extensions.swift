import Vapor

extension Request {
    public var accessTokenHeader: (String, String)? {
        (session.user?.token.id_token).map { ("Authorization", "Bearer \($0)") }
    }

    public func createHeaders(_ headers: [(String, String)]) -> HTTPHeaders {
        HTTPHeaders(headers + [accessTokenHeader].compactMap { $0 })
    }
}