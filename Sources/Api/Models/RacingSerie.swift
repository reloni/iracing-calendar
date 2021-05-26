import Fluent
import Vapor
import Foundation

final class RacingSerie: Model, Content {
    static let schema = "series"

    @ID(key: .id)
    var id: UUID?

    @Field(key: "name")
    var name: String

    @Field(key: "homepage")
    var homePage: String

    @Field(key: "logourl")
    var logoUrl: String

    init() { }

    init(id: UUID? = nil, name: String, homePage: String, logoUrl: String) {
        self.id = id
        self.name = name
        self.homePage = homePage
        self.logoUrl = logoUrl
    }
}