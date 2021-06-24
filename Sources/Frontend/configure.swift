import Vapor
import Leaf
import Core

// configures your application
public func configure(_ app: Application) throws {
    checkEnvironmentVariables(for: app, tag: Environment.frontend)

    app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))

    app.middleware.use(app.sessions.middleware)
    
    app.leaf.cache.isEnabled = app.environment.isRelease
    app.views.use(.leaf)

    // register routes
    try routes(app)
}
