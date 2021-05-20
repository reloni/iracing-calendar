import Vapor

struct GoogleAuthController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
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
            URLQueryItem(name: "prompt", value: "consent")
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
            try res.content.decode(GoogleTokenData.self)
        }.flatMapThrowing { token in 
            print(token)
            return request.redirect(to: "/")
        }
    }
}