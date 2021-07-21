import Fluent
import Vapor
import Foundation

final class DbRacingTrack: Model, Content {
    static let schema = "tracks"

    @ID(key: .id)
    var id: UUID?

    @Field(key: "name")
    var name: String

    // @Siblings(through: RacingSeasonRacingSeriePivot.self, from: \.$season, to: \.$serie)
    // var series: [RacingSerie]

    init() { }

    init(id: UUID? = nil, name: String) {
        self.id = id
        self.name = name
    }
}