import Vapor
import Leaf

// configures your application
public func configure(_ app: Application) throws {
    app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))

    app.middleware.use(app.sessions.middleware)
    
    app.leaf.cache.isEnabled = app.environment.isRelease
    
    app.views.use(.leaf)

    // register routes
    try routes(app)
}
