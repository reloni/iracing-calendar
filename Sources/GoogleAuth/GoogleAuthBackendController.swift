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
            .flatMap { Self.updateOrCreateUser(for: req, with: $0, accessToken: token.access_token) }
    }

    static func updateOrCreateUser(for req: Request, with idToken: GoogleIdentityToken, accessToken: String) -> EventLoopFuture<DbUser> {
        return DbUser
            .query(on: req.db)
            .filter(\.$email, .equal, idToken.email!)
            .first()
            .flatMap { dbUser -> EventLoopFuture<DbUser> in 
                if let dbUser = dbUser {
                    req.logger.info("User exists")
                    return DbAccessToken
                        .query(on: req.db)
                        .filter(\.$token, .equal, accessToken)
                        .first()
                        .flatMap { $0?.delete(on: req.db) ?? req.eventLoop.makeSucceededFuture(()) }
                        .flatMapThrowing { try DbAccessToken(token: accessToken, expireAt: idToken.expires.value, user: dbUser) }
                        .flatMap { dbUser.$tokens.create($0, on: req.db) }
                        .map { _ in dbUser }
                } else {
                    req.logger.info("Create new user")
                    let newUser = DbUser(name: idToken.name ?? "", email: idToken.email!, pictureUrl: idToken.picture)
                    return newUser.create(on: req.db).flatMapThrowing { 
                        try DbAccessToken(token: accessToken, expireAt: idToken.expires.value, user: newUser)
                    }.flatMap { newUser.$tokens.create($0, on: req.db) }
                    .map { _ in newUser }
                }
            }
    }
}