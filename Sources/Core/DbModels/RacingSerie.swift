import Fluent
import Vapor
import Foundation

final public class DbRacingSerie: Model, Content {
    static public let schema = "series"

    @ID(key: .id)
    public var id: UUID?

    @Field(key: "name")
    public var name: String

    @Field(key: "homepage")
    public var homePage: String

    @Field(key: "logourl")
    public var logoUrl: String

    @Parent(key: "seasonid")
    public var season: DbRacingSeason

    @Children(for: \.$serie)
    public var weeks: [DbRacingWeekEntry]

    public init() { }

    public init(id: UUID? = nil, season: DbRacingSeason, name: String, homePage: String, logoUrl: String) throws {
        self.id = id
        self.$season.id = try season.requireID()
        self.name = name
        self.homePage = homePage
        self.logoUrl = logoUrl
    }
}