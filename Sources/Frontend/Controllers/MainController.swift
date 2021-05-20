import Vapor
import Leaf

var allSeries: [Serie] = [
    .init(uuid: UUID(), name: "Porsche iRacing Cup", nextRace: "2 minutes", startDate: "11 May", length: "16 laps", track: "Hockenheimring Baden-Württemberg - Grand Prix", isFavorite: false),
    .init(uuid: UUID(), name: "VRS GT Sprint Series", nextRace: "12 minutes", startDate: "11 May", length: "40 mins", track: "Okayama International Circuit - Full Course", isFavorite: false),
    .init(uuid: UUID(), name: "IMSA Michelin Pilot Challenge", nextRace: "67 minutes", startDate: "11 May", length: "30 mins", track: "Mid-Ohio Sports Car Course - Full Course", isFavorite: false),
    .init(uuid: UUID(), name: "IMSA Hagerty iRacing Series", nextRace: "112 minutes", startDate: "11 May", length: "45 mins", track: "Mid-Ohio Sports Car Course - Full Course", isFavorite: false),
    .init(uuid: UUID(), name: "Pure Driving School European Sprint Series", nextRace: "15 minutes", startDate: "11 May", length: "60 mins", track: "Silverstone Circuit - Grand Prix", isFavorite: false)
]

struct MainController: RouteCollection {

    func boot(routes: RoutesBuilder) throws {
        routes.get(use: homeView)
        routes.get("home", use: homeView)
        routes.get("all-series", use: allSeriesView)
        routes.get("favorite-series", use: favoriteSeriesView)
        routes.get("user-profile", use: homeView)
        routes.post("setFavoriteStatus", use: setFavoriteStatus)

        routes.get("login", "google", use: loginWithGoogle)
        routes.get("oauth", "google", use: handleGoogleOauth)
    }

    func loginWithGoogle(request: Request) throws -> EventLoopFuture<Response> {
        let callbackUrl = Environment.get("GOOGLE_CALLBACK_URL")!
        let clientId = Environment.get("GOOGLE_CLIENT_ID")!

        var components = URLComponents()
        components.scheme = "https"
        components.host = "accounts.google.com"
        components.path = "/o/oauth2/v2/auth"
        components.queryItems = [
            URLQueryItem(name: "scope", value: "profile email"),
            URLQueryItem(name: "access_type", value: "offline"),
            URLQueryItem(name: "include_granted_scopes", value: "true"),
            URLQueryItem(name: "response_type", value: "code"),
            URLQueryItem(name: "redirect_uri", value: callbackUrl),
            URLQueryItem(name: "client_id", value: clientId),
            URLQueryItem(name: "prompt", value: "select_account")
        ]

        return request.eventLoop.future(request.redirect(to: components.url!.absoluteString))
    }

    func handleGoogleOauth(request: Request) throws -> EventLoopFuture<Response> {
        let code = try request.query.get(String.self, at: "code")
        
        return request.client.post("https://oauth2.googleapis.com/token", 
            headers: ["Content-Type": "application/x-www-form-urlencoded"]) { req in 
            try req.content.encode([
                "code": code,
                "client_id": Environment.get("GOOGLE_CLIENT_ID")!,
                "client_secret": Environment.get("GOOGLE_CLIENT_SECRET")!,
                "redirect_uri": Environment.get("GOOGLE_CALLBACK_URL")!,
                "grant_type": "authorization_code"
                ], as: .urlEncodedForm)
        }.flatMapThrowing { res in
            try res.content.decode(GoogleTokenResponse.self)
        }.flatMapThrowing { token in 
            print(token)
            return request.redirect(to: "/")
        }
    }

    func homeView(req: Request) throws -> EventLoopFuture<View> {
        let context = HomeViewContext(
            title: "All series",
            navbarItems: [
                .init(title: "Favorites", link: "favorite-series", isActive: false),
                .init(title: "All series", link: "all-series", isActive: false),
                .init(title: "Profile", link: "home", isActive: false),
            ]
            )
        return req.view.render("home", context)
    }

    func allSeriesView(req: Request) throws -> EventLoopFuture<View> {
        let context = SeriesViewContext(
            title: "All series",
            series: allSeries,
            navbarItems: [
                .init(title: "Favorites", link: "favorite-series", isActive: false),
                .init(title: "All series", link: "all-series", isActive: true),
                .init(title: "Profile", link: "home", isActive: false),
            ]
            )
        return req.view.render("all-series-view", context)
    }

    func favoriteSeriesView(req: Request) throws -> EventLoopFuture<View> {
        let context = SeriesViewContext(
            title: "Favorite series",
            series: allSeries.filter { $0.isFavorite },
            navbarItems: [
                .init(title: "Favorites", link: "favorite-series", isActive: true),
                .init(title: "All series", link: "all-series", isActive: false),
                .init(title: "Profile", link: "home", isActive: false),
            ]
            )
        return req.view.render("favorite-series-view", context)
    }

    func setFavoriteStatus(req: Request) throws -> EventLoopFuture<Response> {
        let uuid = try req.query.get(UUID.self, at: "uuid")
        let isFavorite = try req.query.get(Bool.self, at: "isFavorite")
        app.logger.info("Set isFavorite \(isFavorite) to \(uuid)")
        
        if let index = allSeries.firstIndex(where: { $0.uuid == uuid }) {
            allSeries[index].isFavorite = isFavorite
        }

        return req.eventLoop.makeSucceededFuture(.init(status: .ok))
    }
}