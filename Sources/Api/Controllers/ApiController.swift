import Vapor
import Core
import JWT

struct ApiController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let group = routes.grouped("api")
        // group.get("all-series", use: listAllSeries)
        
        group.get("all-series", use: allRacingSeries)
        group.get("all-seasons", use: allSeasons)
        group.get("current-season", use: currentSeason)
        group.get("testJwt", use: testJwt)
        group.post(["oauth", "authorize", "google"], use: authorizeWithGoogleToken)

        // authorization optional
        let authOptional = group.grouped(UserAuthenticator())
        authOptional.get("current-season", use: currentSeason)

        // autroruzation required
        let authRequired = group.grouped(UserAuthenticator()).grouped(User.guardMiddleware())
        authRequired.post("set-favorite-status", use: setFavoriteStatus)
        authRequired.get("favorite-series", use: favoriteSeries)
        
    }

    // func listAllSeries(req: Request) throws -> EventLoopFuture<[Serie]> {
    //     return req.eventLoop.makeSucceededFuture(allSeries)
    // }

    func setFavoriteStatus(req: Request) throws -> EventLoopFuture<Response> {
        let user = try req.auth.require() as User
        let serieUuid = try req.query.get(UUID.self, at: "uuid")
        let newFavoriteStatus = try req.query.get(Bool.self, at: "isFavorite")
        
        let serieQuery = DbRacingSerie.find(serieUuid, on: req.db)
            .unwrap(or: Abort(.notFound))

        let userQuery = DbUser.query(on: req.db)
            .filter(\.$id, .equal, user.id)
            .with(\.$series)
            .first()
            .unwrap(or: Abort(.notFound))

        return serieQuery.and(userQuery).flatMap { serie, user -> EventLoopFuture<Response> in 
            if user.series.contains(where: { $0.id == serie.id }) { // check if the serie is already favorite
                if newFavoriteStatus {
                    req.logger.info("Serie is already favorite. Do nothing")
                    return req.eventLoop.makeSucceededFuture(.init(status: .ok))
                } else {
                    req.logger.info("Remove serie from favorites")
                    return user.$series.detach(serie, on: req.db)
                        .flatMap { req.eventLoop.makeSucceededFuture(.init(status: .ok)) }
                }
            } else {
                if newFavoriteStatus {
                    req.logger.info("Add serie to favorites")
                    return user.$series.attach(serie, on: req.db)
                        .flatMap { req.eventLoop.makeSucceededFuture(.init(status: .ok)) }
                } else {
                    req.logger.info("Serie is already not favorite. Do nothing")
                    return req.eventLoop.makeSucceededFuture(.init(status: .ok))
                }
            }
        }
    }

    func allRacingSeries(req: Request) throws -> EventLoopFuture<[DbRacingSerie]> {
        DbRacingSerie.query(on: req.db).all()
    }

    func allSeasons(req: Request) throws -> EventLoopFuture<[DbRacingSeason]> {
        DbRacingSeason.query(on: req.db).with(\.$series).all()
    }

    func authorizeWithGoogleToken(req: Request) throws -> EventLoopFuture<DbUser> {
        let token = try req.content.decode(GoogleTokenData.self)
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

    func currentSeason(req: Request) throws -> EventLoopFuture<Response> {
        let userId = (req.auth.get(User.self) as User?)?.id
        
        // load user favorite series if user is present
        let favoriteSeries = userId.map {
            DbUser
                .find($0, on: req.db)
                .unwrap(or: Abort(.notFound, reason: "User not found"))
                .flatMap { user in user.$series.load(on: req.db).map { _ in user } }
                .map { Set($0.series.map { $0.id! }) }
        } ?? req.eventLoop.makeSucceededFuture(Set<UUID>())
        
        return DbRacingSeason
            .query(on: req.db)
            .filter(\.$isActive, .equal, .BooleanLiteralType(booleanLiteral: true))
            .with(\.$series)
            .with(\.$series, { $0.with(\.$weeks) })
            .first()
            .unwrap(or: Abort(.notFound, reason: "Season not found"))
            .and(favoriteSeries)
            .map { dbSeason, favoriteSeries in RacingSeason.init(dbSeason, favoriteSeries: favoriteSeries) }
            .flatMap { $0.encodeResponse(for: req) }
    }

    func favoriteSeries(req: Request) throws -> EventLoopFuture<[DbRacingSerie]> {
        let user = try req.auth.require() as User
        return DbUser.find(user.id, on: req.db)
            .unwrap(or: Abort(.notFound))
            .flatMap { $0.$series.query(on: req.db).all() }
    }

    func testJwt(req: Request) -> EventLoopFuture<HTTPStatus> {
        req.jwt.google.verify().map { token in
            print(token) // GoogleIdentityToken
            return .ok
        }
    }
}