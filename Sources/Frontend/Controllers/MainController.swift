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

struct FrontendError: DebuggableError {
    struct ErrorResponse: Codable {
        let error: Bool
        let reason: String
    }

    var identifier: String {
        return UUID().uuidString
    }

    var reason: String {
        "HttpCode: \(httpCode). \(errorResponse?.reason ?? "Unknown")"
    }

    var source: ErrorSource?
    var stackTrace: StackTrace?

    private let httpCode: UInt
    private let errorResponse: ErrorResponse?

    init(
        _ errorResponse: ErrorResponse?,
        httpCode: UInt,
        file: String = #file,
        function: String = #function,
        line: UInt = #line,
        column: UInt = #column,
        stackTrace: StackTrace? = .capture()
    ) {
        self.errorResponse = errorResponse
        self.httpCode = httpCode

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
    func filterHttpError() -> EventLoopFuture<Value> {
        flatMap { response in
            if response.isSuccess {
                return self.eventLoop.makeSucceededFuture(response)
            } else {
                let error =  FrontendError.init(try? response.content.decode(FrontendError.ErrorResponse.self), 
                                                httpCode: response.status.code)
                return self.eventLoop.makeCompletedFuture(.failure(error))
            }
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

        return req.client.get(ApiUri.favoriteSeries.url, headers: req.accessTokenHeader())
            .filterHttpError()
            .flatMapThrowing { try $0.content.decode([RacingSerie].self) }
            .map { SeriesViewContext.init(title: "Favorite series", user: req.session.user, series: $0, navbarItems: navbarItems) }
            .flatMap { req.view.render("favorite-series-view", $0) }
            .encodeResponse(for: req)
    }

    func setFavoriteStatus(req: Request) throws -> EventLoopFuture<Response> {
        let uuid = try req.query.get(UUID.self, at: "uuid")
        let isFavorite = try req.query.get(Bool.self, at: "isFavorite")
        return req.client.post(ApiUri.setFavoriteStatus.url, headers: req.accessTokenHeader()) { req in 
            try req.query.encode(["uuid":uuid.uuidString, "isFavorite": "\(isFavorite)"])
        }.encodeResponse(for: req)
    }
}