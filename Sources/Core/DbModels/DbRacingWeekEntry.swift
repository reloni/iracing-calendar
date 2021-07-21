import Fluent
import Vapor
import Foundation

final public class DbRacingWeekEntry: Model, Content {
    static public let schema = "weekentries"

    @ID(key: .id)
    public var id: UUID?

    @Field(key: "trackname")
    public var trackName: String

    @Parent(key: "serieid")
    public var serie: DbRacingSerie

    // @Siblings(through: RacingWeekRacingTrackPivot.self, from: \.$season, to: \.$serie)
    // var track: [RacingSerie]

    public init() { }

    public init(id: UUID? = nil, trackName: String) {
        self.id = id
        self.trackName = trackName
    }
}