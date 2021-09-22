import Vapor
import Core
import JWT

public struct GoogleAuthBackendController: RouteCollection {
    public init() { }
    
    public func boot(routes: RoutesBuilder) throws {
        routes.post(["oauth", "authorize", "google"], use: authorizeWithGoogleToken)
    }

    func authorizeWithGoogleToken(req: Request) throws -> EventLoopFuture<DbUser> {
        let token = try req.content.decode(GoogleToken.self)
        return req.jwt.google.verify(token.id_token)
            .flatMap { Self.updateOrCreateUser(for: req, with: $0) }
    }

    static func updateOrCreateUser(for req: Request, with idToken: GoogleIdentityToken) -> EventLoopFuture<DbUser> {
        return DbUser
            .query(on: req.db)
            .filter(\.$email, .equal, idToken.email!)
            .first()
            .flatMap { dbUser -> EventLoopFuture<DbUser> in 
                if let dbUser = dbUser {
                    req.logger.info("User exists")
                    return req.eventLoop.future(dbUser)
                } else {
                    req.logger.info("Create new user")
                    let newUser = DbUser(name: idToken.name ?? "", email: idToken.email!, pictureUrl: idToken.picture)
                    return newUser.create(on: req.db)
                        .map { _ in newUser }
                }
            }
    }
}