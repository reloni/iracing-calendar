import Vapor
import Fluent

struct Migration1: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        let seasons = database
                        .schema("seasons")
                        .id()
                        .field("name", .string, .required)
                        .field("isactive", .bool, .required)
                        .create()

        let series = database
                        .schema("series")
                        .id()
                        .field("name", .string, .required)
                        .field("homepage", .string, .required)
                        .field("logourl", .string, .required)
                        .create()

        let seasonSeriePivot = database.schema("seasonseriepivot")
                        .id()
                        .field("seasonid", .uuid, .required, .references("seasons", "id", onDelete: .cascade))
                        .field("serieid", .uuid, .required, .references("series", "id", onDelete: .cascade))
                        .create()
        
        return database.eventLoop.flatten([seasons, series, seasonSeriePivot])
    }

    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.eventLoop.flatten([
            database.schema("seasons").delete(),
            database.schema("series").delete(),
            database.schema("seasonseriepivot").delete()
        ])
    }
}