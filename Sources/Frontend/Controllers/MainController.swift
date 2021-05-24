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
        return req.client.get(ApiUri.allSeries.url)
            .flatMapThrowing { try $0.content.decode([Serie].self) }
            .map { SeriesViewContext.init(title: "All Series", user: req.session.user, series: $0, navbarItems: navbarItems) }
            .flatMap { req.view.render("all-series-view", $0) }
    }

    func favoriteSeriesView(req: Request) throws -> EventLoopFuture<View> {
        let navbarItems: [NavbarItem] = [
            .init(title: "Favorites", link: "favorite-series", isActive: true),
            .init(title: "All series", link: "all-series", isActive: false),
            .init(title: "Profile", link: "home", isActive: false),
        ]
        return req.client.get(ApiUri.allSeries.url)
            .flatMapThrowing { try $0.content.decode([Serie].self).filter { $0.isFavorite } }
            .map { SeriesViewContext.init(title: "Favorite series", user: req.session.user, series: $0, navbarItems: navbarItems) }
            .flatMap { req.view.render("favorite-series-view", $0) }
    }

    func setFavoriteStatus(req: Request) throws -> EventLoopFuture<Response> {
        let uuid = try req.query.get(UUID.self, at: "uuid")
        let isFavorite = try req.query.get(Bool.self, at: "isFavorite")
        return req.client.post(ApiUri.setFavoriteStatus.url) { req in 
            try req.query.encode(["uuid":uuid.uuidString, "isFavorite": "\(isFavorite)"])
        }.encodeResponse(for: req)
    }
}