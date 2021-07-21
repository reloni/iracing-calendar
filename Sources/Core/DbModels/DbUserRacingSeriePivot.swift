import Fluent
import Foundation

final public  class DbUserRacingSeriePivot: Model {
    static public let schema = "userseriepivot"
    
    @ID
    public var id: UUID?
    
    @Parent(key: "userid")
    public var user: DbUser
    
    @Parent(key: "serieid")
    public var serie: DbRacingSerie
    
    public init() {}
    
    public init(
        id: UUID? = nil,
        user: DbRacingSeason,
        serie: DbRacingSerie
    ) throws {
        self.id = id
        self.$user.id = try user.requireID()
        self.$serie.id = try serie.requireID()
    }
}