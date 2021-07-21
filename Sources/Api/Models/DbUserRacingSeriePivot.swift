import Fluent
import Foundation

final class DbUserRacingSeriePivot: Model {
    static let schema = "userseriepivot"
    
    @ID
    var id: UUID?
    
    @Parent(key: "userid")
    var user: DbUser
    
    @Parent(key: "serieid")
    var serie: DbRacingSerie
    
    init() {}
    
    init(
        id: UUID? = nil,
        user: DbRacingSeason,
        serie: DbRacingSerie
    ) throws {
        self.id = id
        self.$user.id = try user.requireID()
        self.$serie.id = try serie.requireID()
    }
}