import Vapor

public struct UserAuthenticator: BearerAuthenticator {
    public init() { }
    public func authenticate(
        bearer: BearerAuthorization,
        for request: Request
    ) -> EventLoopFuture<Void> {
        return DbAccessToken
            .query(on: request.db)
            .with(\.$user)
            .filter(\.$token, .equal, bearer.token)
            .first()
            .unwrap(orError: Abort(.unauthorized, reason: "Invalid access token"))
            .flatMapThrowing { token -> DbAccessToken in
                guard token.expireAt > Date() else { throw Abort(.unauthorized, reason: "Access token expired") }
                return token
            }
            .map { User(id: $0.user.id!, name: $0.user.name, email: $0.user.email, pictureUrl: $0.user.pictureUrl) }
            .flatMap { user in
                request.auth.login(user)
                return request.eventLoop.makeSucceededFuture(())
            }
   }
}