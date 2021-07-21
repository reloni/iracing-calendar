import Fluent
import Vapor
import Foundation

final class DbRacingSerie: Model, Content {
    static let schema = "series"

    @ID(key: .id)
    var id: UUID?

    @Field(key: "name")
    var name: String

    @Field(key: "homepage")
    var homePage: String

    @Field(key: "logourl")
    var logoUrl: String

    @Parent(key: "seasonid")
    var season: DbRacingSeason

    @Children(for: \.$serie)
    var weeks: [DbRacingWeekEntry]

    init() { }

    init(id: UUID? = nil, season: DbRacingSeason, name: String, homePage: String, logoUrl: String) throws {
        self.id = id
        self.$season.id = try season.requireID()
        self.name = name
        self.homePage = homePage
        self.logoUrl = logoUrl
    }
}