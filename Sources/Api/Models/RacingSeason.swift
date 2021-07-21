import Fluent
import Vapor
import Foundation

final class DbRacingSeason: Model, Content {
    static let schema = "seasons"

    @ID(key: .id)
    var id: UUID?

    @Field(key: "name")
    var name: String

    @Field(key: "isactive")
    var isActive: Bool

    @Children(for: \.$season)
    var series: [DbRacingSerie]

    init() { }

    init(id: UUID? = nil, name: String) {
        self.id = id
        self.name = name
    }
}