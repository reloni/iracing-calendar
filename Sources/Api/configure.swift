import Vapor
import Fluent
import FluentMySQLDriver

import Core

// configures your application
public func configure(_ app: Application) throws {
    checkEnvironmentVariables(for: app, tag: Environment.api)

    app.jwt.google.applicationIdentifier = Environment.api.cases.googleClientId.value

    var tls = TLSConfiguration.makeClientConfiguration()
    tls.certificateVerification = .none
    let config = 
        MySQLConfiguration(
            hostname: Environment.api.cases.databaseHost.value!, 
            port: Environment.api.cases.databasePort.value.flatMap(Int.init(_:))!, 
            username: Environment.api.cases.databaseUserName.value!, 
            password: Environment.api.cases.databasePassword.value!, 
            database: Environment.api.cases.databaseName.value!, 
            tlsConfiguration: tls
        )

    app.databases.use(.mysql(configuration: config), as: .mysql)

    app.migrations.add(
        Migration1()
    )
    try app.autoMigrate().wait()

    // register routes
    try routes(app)
}