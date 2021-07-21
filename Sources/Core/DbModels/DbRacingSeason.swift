import Fluent
import Vapor
import Foundation

final public class DbRacingSeason: Model, Content {
    static public let schema = "seasons"

    @ID(key: .id)
    public var id: UUID?

    @Field(key: "name")
    public var name: String

    @Field(key: "isactive")
    public var isActive: Bool

    @Children(for: \.$season)
    public var series: [DbRacingSerie]

    public init() { }

    public init(id: UUID? = nil, name: String) {
        self.id = id
        self.name = name
    }
}