import Vapor

private var env = try Environment.detect()
try LoggingSystem.bootstrap(from: &env)
private let app = Application(env)
defer { app.shutdown() }
try configure(app)
try app.run()