import Vapor
import Core

struct UserAuthenticator: BearerAuthenticator {
    init() { }
    func authenticate(
        bearer: BearerAuthorization,
        for request: Request
    ) -> EventLoopFuture<Void> {
        return AccessToken
            .query(on: request.db)
            .with(\.$user)
            .filter(\.$token, .equal, bearer.token)
            .filter(\.$expireAt, .greaterThan, Date())
            .first()
            .unwrap(orError: Abort(.unauthorized))
            .map { User(id: $0.user.id!, name: $0.user.name, email: $0.user.email, pictureUrl: $0.user.pictureUrl) }
            .flatMap { user in
                request.auth.login(user)
                return request.eventLoop.makeSucceededFuture(())
            }
   }
}