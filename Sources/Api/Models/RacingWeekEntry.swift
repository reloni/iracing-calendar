import Fluent
import Vapor
import Foundation

final class DbRacingWeekEntry: Model, Content {
    static let schema = "weekentries"

    @ID(key: .id)
    var id: UUID?

    @Field(key: "trackname")
    var trackName: String

    @Parent(key: "serieid")
    var serie: DbRacingSerie

    // @Siblings(through: RacingWeekRacingTrackPivot.self, from: \.$season, to: \.$serie)
    // var track: [RacingSerie]

    init() { }

    init(id: UUID? = nil, trackName: String) {
        self.id = id
        self.trackName = trackName
    }
}