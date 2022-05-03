import Vapor
import Core
import JWT

struct ApiController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let group = routes.grouped("api")
        
        // authorization optional
        let authOptional = group.grouped(UserAuthenticator())
        authOptional.get("current-season", use: currentSeason)

        // autroruzation required
        let authRequired = group.grouped(UserAuthenticator()).grouped(User.guardMiddleware())
        authRequired.get("favorite-series", use: favoriteSeries)
        authRequired.post("set-favorite-status", use: setFavoriteStatus)

        group.get("ir-test", use: testIr)
        group.get("ir-auth", use: testIrAuth)
    }

    func testIr(req: Request) throws -> EventLoopFuture<ClientResponse> {
        return req.client.get(URI(string: "https://members-ng.iracing.com/data/track/get"), headers: ["Cookie":"irsso_members=59AE78C67E5F012701EE8B3584EDCF5FE1A9B844FCAB98B31948D632C040A513CCD4F56752A7090B4EA97B1FAAED69E1D6CDC92A5665D4D7701C8E6323BEA8C4141C4648F9437B6AD135C0B02AA1BC83ED42083F186CF6B62E42E465959F78214657E18ED8B2B163E6FC869E8BA8AE07EA55FF3BE2879C7BD848F5536F18CD39;  authtoken_members=%7B%22authtoken%22%3A%7B%22authcode%22%3A%22U2FsdGVkX18Faw8Rt1883oInhnyq1QHQm5lUYMrLKWZYS7w5PhABcfB%2FkmeFD%2F3XDsiGUwFMGS3LPevT1c94JhuTK3ALAoUQIv6hxRszWinb5xDCPDxLBJo1oeJH1CNLVi8iPDKw7%2ByBPoOoHHW36ie%2FExyyRLeYIFZ1KaLNW%2B5QNPFHSuUtXSGxyFM4HC1xOkgazDv90Ezl7HweV9TLcwbxZhdswsoys5%2BZpvbbsJy%2FPtr3Dx%2FtHaygQCpbxXN4HRP0IoAbLXGLO03uknwhSttjYethGTQwvSEvEZwQX2RE24bq6hyGec2EODJ4Bf0w9dtMP5LoOsiaov8wVflBZJlZq4MIYKL7Gq0lGBRd7kGxuts4BBruApwG4MVJ6f6oyy5ulEBIxUvjQZc%2FwjuUVf0IsHRu6MUfGdrbGZ5ReVD%2FNbldmsRnGl8KSG74ahn1bd1dLRcSqNaaEoTjuZkSrSnorhzUIt3ks9SiqO0NoxK0yxgPh0TPYlXj9Yr7W5FmDu0YU%2FiXTRXuQevH6rYXY2mGFKb2%2Brpv3cnQORlgriODKYOoTteOPcU%2FpXgWVX4x%22%2C%22email%22%3A%22reloni%40ya.ru%22%7D%7D"])
            .flatMapThrowing { resp in
            req.logger.info("Success")
            let h = resp.headers.map { "\($0.name): \($0.value)" }.joined(separator: ",")
            req.logger.info("\(h)")
            req.logger.info("\(resp.headers.cookie)")
            return resp
        }
    }

        func testIrAuth(req: Request) throws -> EventLoopFuture<ClientResponse> {
        return req.client.post(URI(string: "https://members-ng.iracing.com/auth"), 
            headers: ["Content-Type": "Content-Type: application/json"]) { req in 
            try req.content.encode([
                "email": "reloni@ya.ru",
                "password": "Tu_3sHkeQKJ@BEmyU.@yZasN"
                ], as: .json)
            }
            .flatMapThrowing { resp in
            req.logger.info("Success")
            let h = resp.headers.map { "\($0.name): \($0.value)" }.joined(separator: ",")
            req.logger.info("\(h)")
            req.logger.info("\(resp.headers.cookie)")
            req.logger.info("Set-cookie: \(resp.headers["set-cookie"])")
            return resp
        }
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
            .unwrap(or: Abort(.notFound, reason: "User not found"))
            .flatMap { $0.$series.query(on: req.db).with(\.$weeks).all() }
            .map { $0.map(RacingSerie.init) }
    }
}