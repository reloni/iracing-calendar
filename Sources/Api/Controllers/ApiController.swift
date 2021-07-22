import Vapor
import Core
import JWT

struct ApiController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let group = routes.grouped("api")
        
        group.get("testJwt", use: testJwt)
        // group.post(["oauth", "authorize", "google"], use: authorizeWithGoogleToken)

        // authorization optional
        let authOptional = group.grouped(UserAuthenticator())
        authOptional.get("current-season", use: currentSeason)

        // autroruzation required
        let authRequired = group.grouped(UserAuthenticator()).grouped(User.guardMiddleware())
        authRequired.post("set-favorite-status", use: setFavoriteStatus)
        authRequired.get("favorite-series", use: favoriteSeries)
        
    }

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

    func favoriteSeries(req: Request) throws -> EventLoopFuture<[RacingSerie]> {
        let user = try req.auth.require() as User
        return DbUser.find(user.id, on: req.db)
            .unwrap(or: Abort(.notFound))
            .flatMap { $0.$series.query(on: req.db).with(\.$weeks).all() }
            .map { $0.map(RacingSerie.init) }
    }

    func testJwt(req: Request) -> EventLoopFuture<HTTPStatus> {
        req.jwt.google.verify().map { token in
            print(token) // GoogleIdentityToken
            return .ok
        }
    }
}