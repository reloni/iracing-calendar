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

public struct RacingSeason: Codable, Content {
    public let id: UUID
    public let name: String
    public let series: [RacingSerie]
}

extension RacingSeason {
    public init(_ season: DbRacingSeason, favoriteSeries: Set<UUID>) {
        self.id = season.id!
        self.name = season.name
        self.series = season.series.map {
            RacingSerie(id: $0.id!, 
                        name: $0.name, 
                        homePage: $0.homePage, 
                        logoUrl: $0.logoUrl, 
                        weeks: $0.weeks.map(RacingWeekEntry.init), 
                        currentWeek: $0.weeks.first.map(RacingWeekEntry.init), 
                        isFavorite: favoriteSeries.contains($0.id!))
        }
    }
}

public struct RacingSerie: Codable, Content {
    public let id: UUID
    public let name: String
    public let homePage: String
    public let logoUrl: String
    public let weeks: [RacingWeekEntry]
    public let currentWeek: RacingWeekEntry?
    public let isFavorite: Bool
}

extension RacingSerie {
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        homePage = try container.decode(String.self, forKey: .homePage)
        logoUrl = try container.decode(String.self, forKey: .logoUrl)
        weeks = try container.decode([RacingWeekEntry].self, forKey: .weeks)

        currentWeek = try container.decodeIfPresent(RacingWeekEntry.self, forKey: .currentWeek)
        isFavorite = try container.decode(Bool.self, forKey: .isFavorite)
    }
}

public struct RacingWeekEntry: Codable, Content {
    public let id: UUID
    public let trackName: String
}

extension RacingWeekEntry {
    init(_ week: DbRacingWeekEntry) {
        self.id = week.id!
        self.trackName = week.trackName
    }
}

public struct User: Codable, Content, Authenticatable {
    public let id: UUID
    public let name: String
    public let email: String
    public let pictureUrl: String?

    public init(id: UUID,
                name: String,
                email: String,
                pictureUrl: String?) {
        self.id = id
        self.name = name
        self.email = email
        self.pictureUrl = pictureUrl
    }
}