import Vapor
import Leaf
import Core

extension Request {
    var accessTokenHeader: (String, String)? {
        (session.user?.token.access_token).map { ("Authorization", "Bearer \($0)") }
    }

    func createHeaders(_ headers: [(String, String)]) -> HTTPHeaders {
        HTTPHeaders(headers + [accessTokenHeader].compactMap { $0 })
    }
}

struct MainController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        routes.get(use: homeView)
        routes.get("home", use: homeView)
        routes.get("all-series", use: allSeriesView)
        routes.get("favorite-series", use: favoriteSeriesView)
        routes.get("user-profile", use: homeView)
        routes.post("setFavoriteStatus", use: setFavoriteStatus)
    }

    func homeView(req: Request) throws -> EventLoopFuture<View> {
        let context = HomeViewContext(
            title: "All series",
            user: req.session.user,
            navbarItems: [
                    .init(title: "Favorites", link: "favorite-series", isActive: false), 
                    .init(title: "All series", link: "all-series", isActive: false),
                    .init(title: "Profile", link: "home", isActive: false),
                ]
            )
        return req.view.render("home", context)
    }

    func allSeriesView(req: Request) throws -> EventLoopFuture<View> {
        let navbarItems: [NavbarItem] = [
            .init(title: "Favorites", link: "favorite-series", isActive: false),
            .init(title: "All series", link: "all-series", isActive: true),
            .init(title: "Profile", link: "home", isActive: false)
        ]

        

        return req.client.get(ApiUri.currentSeason.url, headers: req.createHeaders([]))
            .filterHttpError()
            .flatMapThrowing { try $0.content.decode(RacingSeason.self) }
            .map { SeriesViewContext.init(title: "All Series", user: req.session.user, series: $0.series, navbarItems: navbarItems) }
            .flatMap { req.view.render("all-series-view", $0) }
    }

    func favoriteSeriesView(req: Request) throws -> EventLoopFuture<Response> {
        let navbarItems: [NavbarItem] = [
            .init(title: "Favorites", link: "favorite-series", isActive: true),
            .init(title: "All series", link: "all-series", isActive: false),
            .init(title: "Profile", link: "home", isActive: false),
        ]

        return req.client.get(ApiUri.favoriteSeries.url, headers: req.createHeaders([]))
            .filterHttpError()
            .flatMapThrowing { try $0.content.decode([RacingSerie].self) }
            .map { SeriesViewContext.init(title: "Favorite series", user: req.session.user, series: $0, navbarItems: navbarItems) }
            .flatMap { req.view.render("favorite-series-view", $0) }
            .encodeResponse(for: req)
    }

    func setFavoriteStatus(req: Request) throws -> EventLoopFuture<Response> {
        let uuid = try req.query.get(UUID.self, at: "uuid")
        let isFavorite = try req.query.get(Bool.self, at: "isFavorite")
        return req.client.post(ApiUri.setFavoriteStatus.url, headers: req.createHeaders([])) { req in 
            try req.query.encode(["uuid":uuid.uuidString, "isFavorite": "\(isFavorite)"])
        }
        .filterHttpError()
        .encodeResponse(for: req)
    }
}