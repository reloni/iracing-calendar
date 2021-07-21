import Fluent
import Vapor
import Foundation

final class DbAccessToken: Model, Content {
    static let schema = "accesstokens"

    @ID(key: .id)
    var id: UUID?

    @Field(key: "token")
    var token: String

    @Field(key: "expireat")
    var expireAt: Date

    @Parent(key: "userid")
    var user: DbUser

    init() { }

    init(id: UUID? = nil, token: String, expireAt: Date, user: DbUser) throws {
        self.id = id
        self.token = token
        self.expireAt = expireAt
        self.$user.id = try user.requireID()        
    }
}