import Vapor
import Core

public struct GoogleAuthController: RouteCollection {
    public init() { }
    
    public func boot(routes: RoutesBuilder) throws {
        routes.get("oauth", "login", "google", use: loginWithGoogle)
        routes.get("oauth", "callback", "google", use: handleGoogleOauth)
    }

    func loginWithGoogle(request: Request) throws -> EventLoopFuture<Response> {
        let callbackUrl = Environment.EnvVar.callbackUrl.value!
        let clientId = Environment.EnvVar.clientId.value!

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
        
        return request.client.post(URI(string: Environment.EnvVar.tokenExchangeUrl.value!), 
            headers: ["Content-Type": "application/x-www-form-urlencoded"]) { req in 
            try req.content.encode([
                "code": code,
                "client_id": Environment.EnvVar.clientId.value!,
                "client_secret": Environment.EnvVar.clientSecret.value!,
                "redirect_uri": Environment.EnvVar.callbackUrl.value!,
                "grant_type": "authorization_code"
                ], as: .urlEncodedForm)
        }.flatMapThrowing { res in
            try res.content.decode(GoogleTokenData.self)
        }.flatMap { token in
            GoogleAuthController.authorize(on: request, with: token)
        }.flatMap { user, token in 
            request.session.user = SessionUser(user: user, token: token)
            
            let response = request.redirect(to: "/")
            response.cookies["token"] = 
                HTTPCookies.Value(
                    string: token.access_token, 
                    maxAge: 60,
                    isSecure: false, 
                    isHTTPOnly: true, 
                    sameSite: .lax
                )
            return request.eventLoop.future(response)
        }
    }

    static func authorize(on request: Request, with token: GoogleTokenData) -> EventLoopFuture<(User, GoogleTokenData)> {
        return request.client
            .post(ApiUri.authorizeGoogle.url) { req in  try req.content.encode(token, as: .json) }
            .flatMapThrowing { res in
                if res.status == .ok {
                    return (try res.content.decode(User.self), token)
                } else {
                    throw Abort(.internalServerError)
                }
            }
    }
}