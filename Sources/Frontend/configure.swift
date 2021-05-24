import Vapor
import Leaf
import Core

// configures your application
public func configure(_ app: Application) throws {
    app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))

    app.middleware.use(app.sessions.middleware)
    
    app.leaf.cache.isEnabled = app.environment.isRelease
    app.views.use(.leaf)

    checkEnvironmentVariables(for: app, expectedVariables: Environment.EnvVar.allCases.map { $0.rawValue })

    // register routes
    try routes(app)
}
