import Vapor
import Core

var allSeries: [Serie] = [
    .init(uuid: UUID(), name: "Porsche iRacing Cup", nextRace: "2 minutes", startDate: "11 May", length: "16 laps", track: "Hockenheimring Baden-Württemberg - Grand Prix", isFavorite: false),
    .init(uuid: UUID(), name: "VRS GT Sprint Series", nextRace: "12 minutes", startDate: "11 May", length: "40 mins", track: "Okayama International Circuit - Full Course", isFavorite: false),
    .init(uuid: UUID(), name: "IMSA Michelin Pilot Challenge", nextRace: "67 minutes", startDate: "11 May", length: "30 mins", track: "Mid-Ohio Sports Car Course - Full Course", isFavorite: false),
    .init(uuid: UUID(), name: "IMSA Hagerty iRacing Series", nextRace: "112 minutes", startDate: "11 May", length: "45 mins", track: "Mid-Ohio Sports Car Course - Full Course", isFavorite: false),
    .init(uuid: UUID(), name: "Pure Driving School European Sprint Series", nextRace: "15 minutes", startDate: "11 May", length: "60 mins", track: "Silverstone Circuit - Grand Prix", isFavorite: false)
]

struct ApiController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let group = routes.grouped("api")
        // group.get("all-series", use: listAllSeries)
        group.post("set-favorite-status", use: setFavoriteStatus)
        group.get("all-series", use: allRacingSeries)
        group.get("all-seasons", use: allSeasons)
        group.get("current-season", use: currentSeason)
        group.post(["oauth", "authorize", "google"], use: authorizeWithGoogleToken)
    }

    // func listAllSeries(req: Request) throws -> EventLoopFuture<[Serie]> {
    //     return req.eventLoop.makeSucceededFuture(allSeries)
    // }

    func setFavoriteStatus(req: Request) throws -> EventLoopFuture<Response> {
        let uuid = try req.query.get(UUID.self, at: "uuid")
        let isFavorite = try req.query.get(Bool.self, at: "isFavorite")
        // app.logger.info("User id \(req.session.user?.user.id.uuidString ?? "")")
        app.logger.info("Set isFavorite \(isFavorite) to \(uuid)")
        
        // if let index = allSeries.firstIndex(where: { $0.uuid == uuid }) {
        //     allSeries[index].isFavorite = isFavorite
        // }

        return req.eventLoop.makeSucceededFuture(.init(status: .ok))
    }

    func allRacingSeries(req: Request) throws -> EventLoopFuture<[RacingSerie]> {
        RacingSerie.query(on: req.db).all()
    }

    func allSeasons(req: Request) throws -> EventLoopFuture<[RacingSeason]> {
        RacingSeason.query(on: req.db).with(\.$series).all()
    }

    func authorizeWithGoogleToken(req: Request) throws -> EventLoopFuture<DbUser> {
        let token = try req.content.decode(GoogleTokenData.self)
        return loadUserInfo(on: req, with: token)
                    .flatMap { Self.updateOrCreateUser(for: req, with: $0) }
    }

    static func updateOrCreateUser(for req: Request, with user: GoogleUser) -> EventLoopFuture<DbUser> {
        return DbUser
            .query(on: req.db)
            .filter(\.$email, .equal, user.email)
            .first()
            .flatMap { dbUser -> EventLoopFuture<DbUser> in 
                if dbUser == nil {
                    app.logger.info("Create new user")
                    let newUser = DbUser.init(name: user.name ?? "", email: user.email, pictureUrl: user.picture?.absoluteString)
                    return newUser.create(on: req.db).map { _ in newUser }
                } else {
                    app.logger.info("User exists")
                    return req.eventLoop.makeSucceededFuture(dbUser!)
                }
            }
    }

    func loadUserInfo(on request: Request, with token: GoogleTokenData) -> EventLoopFuture<GoogleUser> {
        app.logger.info("Load user info")
        var headers = HTTPHeaders()
        headers.bearerAuthorization = BearerAuthorization(token: token.access_token)
        return request.client
            .get("https://www.googleapis.com/oauth2/v1/userinfo?alt=json", headers: headers)
            .flatMapThrowing { res in
                if res.status == .ok {
                    return try res.content.decode(GoogleUser.self)
                } else {
                    throw Abort(.internalServerError)
                }
            }
    }

    func currentSeason(req: Request) throws -> EventLoopFuture<Response> {
        RacingSeason
            .query(on: req.db)
            .filter(\.$isActive, .equal, .BooleanLiteralType(booleanLiteral: true))
            .with(\.$series)
            .with(\.$series, { $0.with(\.$weeks) })
            .first()
            .flatMap { season in
                season?.encodeResponse(for: req) ?? req.eventLoop.makeSucceededFuture(Response()).encodeResponse(for: req)
            }
    }
}