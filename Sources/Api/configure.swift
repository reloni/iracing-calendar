import Vapor
import Fluent
import FluentPostgresDriver
import Core

// configures your application
public func configure(_ app: Application) throws {
    checkEnvironmentVariables(for: app, tag: Environment.api)

    app.jwt.google.applicationIdentifier = Environment.api.cases.googleClientId.value

    var config = PostgresConfiguration(
        hostname: Environment.api.cases.databaseHost.value!,
        port: Environment.api.cases.databasePort.value.flatMap(Int.init(_:))!,
        username: Environment.api.cases.databaseUserName.value!,
        password: Environment.api.cases.databasePassword.value!,
        database: Environment.api.cases.databaseName.value!
    )
    config.searchPath = [Environment.api.cases.databaseSearchPath.value!]
    app.databases.use(.postgres(configuration: config), as: .psql)

    app.migrations.add(
        Migration1()
    )
    try app.autoMigrate().wait()

    // register routes
    try routes(app)
}