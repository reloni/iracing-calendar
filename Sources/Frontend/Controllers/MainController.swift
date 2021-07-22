import Vapor
import Leaf
import Core

extension Request {
    func accessTokenHeader() -> HTTPHeaders {
        (session.user?.token.access_token).map { ["Authorization": "Bearer \($0)"] } ?? [:]
    }
}

extension ClientResponse {
    var isSuccess: Bool {
        200..<300 ~= status.code
    }
}

struct FrontendError: Error {

}

// enum MyError {
//     case userNotLoggedIn
//     case invalidEmail(String)
// }

struct MyError: DebuggableError {
    enum Value {
        case userNotLoggedIn
        case invalidEmail(String)
    }

    var identifier: String {
        switch self.value {
        case .userNotLoggedIn:
            return "userNotLoggedIn"
        case .invalidEmail:
            return "invalidEmail"
        }
    }

    var reason: String {
        switch self.value {
        case .userNotLoggedIn:
            return "User is not logged in."
        case .invalidEmail(let email):
            return "Email address is not valid: \(email)."
        }
    }

    var value: Value
    var source: ErrorSource?
    var stackTrace: StackTrace?

    var possibleCauses: [String] { ["1", "2"] }

    init(
        _ value: Value,
        file: String = #file,
        function: String = #function,
        line: UInt = #line,
        column: UInt = #column,
        stackTrace: StackTrace? = .capture()
    ) {
        self.value = value
        self.source = .init(
            file: file,
            function: function,
            line: line,
            column: column
        )
        self.stackTrace = stackTrace
    }
}

extension EventLoopFuture where Value == ClientResponse {  
    func filterError() -> EventLoopFuture<Value> {
        flatMap {
            $0.isSuccess 
                ? self.eventLoop.makeSucceededFuture($0)
                : self.eventLoop.makeCompletedFuture(.failure(MyError.init(.invalidEmail("ololo"))))
        }
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

        return req.client.get(ApiUri.currentSeason.url, headers: req.accessTokenHeader())
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

        // let prom = req.eventLoop.makePromise(of: ClientResponse.self)
        

        // let a = req.client.get(ApiUri.favoriteSeries.url, headers: req.accessTokenHeader())
            // .flatMapResult { $0.isSuccess ? .success($0) : .failure(FrontendError()) }
            // .cascade(to: EventLoopPromise<ClientResponse>?)
        

        return req.client.get(ApiUri.favoriteSeries.url, headers: req.accessTokenHeader())
            .filterError()
            // .map { $0.isSuccess ? Result.success($0) : .failure(FrontendError()) }
            .flatMapThrowing { try $0.content.decode([RacingSerie].self) }
            .map { SeriesViewContext.init(title: "Favorite series", user: req.session.user, series: $0, navbarItems: navbarItems) }
            .flatMap { req.view.render("favorite-series-view", $0) }
            .encodeResponse(for: req)

        // return prom.futureResult
    }

    func setFavoriteStatus(req: Request) throws -> EventLoopFuture<Response> {
        let uuid = try req.query.get(UUID.self, at: "uuid")
        let isFavorite = try req.query.get(Bool.self, at: "isFavorite")
        return req.client.post(ApiUri.setFavoriteStatus.url, headers: req.accessTokenHeader()) { req in 
            try req.query.encode(["uuid":uuid.uuidString, "isFavorite": "\(isFavorite)"])
        }.encodeResponse(for: req)
    }
}