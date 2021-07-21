import Fluent
import Vapor
import Foundation

final public class DbAccessToken: Model, Content {
    static public let schema = "accesstokens"

    @ID(key: .id)
    public var id: UUID?

    @Field(key: "token")
    public var token: String

    @Field(key: "expireat")
    public var expireAt: Date

    @Parent(key: "userid")
    public var user: DbUser

    public init() { }

    public init(id: UUID? = nil, token: String, expireAt: Date, user: DbUser) throws {
        self.id = id
        self.token = token
        self.expireAt = expireAt
        self.$user.id = try user.requireID()        
    }
}