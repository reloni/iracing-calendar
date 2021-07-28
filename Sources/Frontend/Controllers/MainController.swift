import Vapor
import Leaf
import Core

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
            navbarItems: navBarItems(req, activeItem: nil)
            )

        return req.view.render("home", context)
    }

    func allSeriesView(req: Request) throws -> EventLoopFuture<View> {
        let navBarItems = navBarItems(req, activeItem: .allSeries)
        return req.client.get(ApiUri.currentSeason.url, headers: req.createHeaders([]))
            .filterHttpError()
            .flatMapThrowing { try $0.content.decode(RacingSeason.self) }
            .map { SeriesViewContext(title: "All Series", user: req.session.user, series: $0.series, navbarItems: navBarItems) }
            .flatMap { req.view.render("all-series-view", $0) }
    }

    func favoriteSeriesView(req: Request) throws -> EventLoopFuture<Response> {
        let navBarItems = navBarItems(req, activeItem: .favorites)
        return req.client.get(ApiUri.favoriteSeries.url, headers: req.createHeaders([]))
            .filterHttpError()
            .flatMapThrowing { try $0.content.decode([RacingSerie].self) }
            .map { SeriesViewContext.init(title: "Favorite series", user: req.session.user, series: $0, navbarItems: navBarItems) }
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