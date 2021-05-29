import Vapor

public struct NavbarItem: Codable {
    public let title: String
    public let link: String
    public let isActive: Bool

    public init(title: String,
                link: String,
                isActive: Bool) {
        self.title = title
        self.link = link
        self.isActive = isActive
    }
}

public struct Serie: Codable, Content {
    public let uuid: UUID
    public let name: String
    public let nextRace: String
    public let startDate: String
    public let length: String
    public let track: String
    public var isFavorite: Bool

    public init(uuid: UUID,
                name: String,
                nextRace: String,
                startDate: String,
                length: String,
                track: String,
                isFavorite: Bool) {
        self.uuid = uuid
        self.name = name
        self.nextRace = nextRace
        self.startDate = startDate
        self.length = length
        self.track = track
        self.isFavorite = isFavorite
    }
}

public struct RacingSeason: Codable, Content {
    public let id: UUID

    public let name: String

    public let series: [RacingSerie]
}

public struct RacingSerie: Codable, Content {
    public let id: UUID

    public let name: String

    public let homePage: String

    public let logoUrl: String

    public let weeks: [RacingWeekEntry]

    public let currentWeek: RacingWeekEntry = .init(id: UUID(), trackName: ":)")
}

public struct RacingWeekEntry: Codable, Content {

    public let id: UUID

    public let trackName: String
}