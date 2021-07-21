import Fluent
import Vapor
import Foundation

final public class DbRacingTrack: Model, Content {
    static public let schema = "tracks"

    @ID(key: .id)
    public var id: UUID?

    @Field(key: "name")
    public var name: String

    // @Siblings(through: RacingSeasonRacingSeriePivot.self, from: \.$season, to: \.$serie)
    // var series: [RacingSerie]

    public init() { }

    public init(id: UUID? = nil, name: String) {
        self.id = id
        self.name = name
    }
}