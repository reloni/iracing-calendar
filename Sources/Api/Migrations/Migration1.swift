import Vapor
import Fluent

struct Migration1: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database.schema("series")
            .id()
            .field("name", .string, .required)
            .field("homepage", .string, .required)
            .field("logourl", .string, .required)
            .create()
    }

    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema("series").delete()
    }
}