import Fluent
import Vapor
import Foundation

final public class DbUser: Model, Content {
    static public let schema = "users"

    @ID(key: .id)
    public var id: UUID?

    @Field(key: "name")
    public var name: String

    @Field(key: "email")
    public var email: String

    @Field(key: "pictureurl")
    public var pictureUrl: String?

    @Children(for: \.$user)
    public var tokens: [DbAccessToken]

    @Siblings(
        through: DbUserRacingSeriePivot.self,
        from: \.$user,
        to: \.$serie)
    public var series: [DbRacingSerie]

    public init() { }

    public init(id: UUID? = nil, name: String, email: String, pictureUrl: String?) {
        self.id = id
        self.name = name
        self.email = email
        self.pictureUrl = pictureUrl
    }
}