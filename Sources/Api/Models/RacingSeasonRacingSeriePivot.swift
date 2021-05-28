import Fluent
import Foundation

final class RacingSeasonRacingSeriePivot: Model {
    static let schema = "seasonseriepivot"
    
    @ID
    var id: UUID?
    
    @Parent(key: "seasonid")
    var season: RacingSeason
    
    @Parent(key: "serieid")
    var serie: RacingSerie
    
    init() {}
    
    init(
        id: UUID? = nil,
        season: RacingSeason,
        serie: RacingSerie
    ) throws {
        self.id = id
        self.$season.id = try season.requireID()
        self.$serie.id = try serie.requireID()
    }
}
