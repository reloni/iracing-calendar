import Vapor
import JWT

public struct UserAuthenticator: BearerAuthenticator {
    public init() { }
    public func authenticate(
        bearer: BearerAuthorization,
        for request: Request
    ) -> EventLoopFuture<Void> {
        request.jwt.google.verify(bearer.token).flatMap { token -> EventLoopFuture<Void> in
            DbUser
                .query(on: request.db)
                .filter(\.$email, .equal, token.email!)
                .first()
                .unwrap(orError: Abort(.unauthorized, reason: "User not existed"))
                .map { User(id: $0.id!, name: $0.name, email: $0.email, pictureUrl: $0.pictureUrl) }
                .flatMap { user in
                    request.auth.login(user)
                    return request.eventLoop.makeSucceededFuture(())
                }
                
        }
   }
}