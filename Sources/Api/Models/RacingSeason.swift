import Fluent
import Vapor
import Foundation

final class RacingSeason: Model, Content {
    static let schema = "seasons"

    @ID(key: .id)
    var id: UUID?

    @Field(key: "name")
    var name: String

    @Field(key: "isactive")
    var isActive: Bool

    @Siblings(through: RacingSeasonRacingSeriePivot.self, from: \.$season, to: \.$serie)
    var series: [RacingSerie]

    init() { }

    init(id: UUID? = nil, name: String) {
        self.id = id
        self.name = name
    }
}