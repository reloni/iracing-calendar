import Fluent
import Vapor
import Foundation

final class DbUser: Model, Content {
    static let schema = "users"

    @ID(key: .id)
    var id: UUID?

    @Field(key: "name")
    var name: String

    @Field(key: "email")
    var email: String

    @Field(key: "pictureurl")
    var pictureUrl: String?

    @Siblings(
        through: DbUserRacingSeriePivot.self,
        from: \.$user,
        to: \.$serie)
    var series: [RacingSerie]

    init() { }

    init(id: UUID? = nil, name: String, email: String, pictureUrl: String?) {
        self.id = id
        self.name = name
        self.email = email
        self.pictureUrl = pictureUrl
    }
}