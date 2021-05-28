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
                        .field("seasonid", .uuid, .required, .references("seasons", "id"))
                        .create()
        
        return database.eventLoop.flatten([seasons, series])
    }

    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.eventLoop.flatten([
            database.schema("seasons").delete(),
            database.schema("series").delete(),
            database.schema("seasonseriepivot").delete()
        ])
    }
}