import Vapor

public struct NavbarItem: Codable {
    public enum Description: String, Codable {
        case favorites
        case allSeries
        case profile

        public var title: String {
            switch self {
                case .allSeries: return "All series"
                case .favorites: return "Favorites"
                case .profile: return "Profile"
            }
        }

        public var link: String {
            switch self {
                case .allSeries: return "all-series"
                case .favorites: return "favorite-series"
                case .profile: return "home"
            }
        }
    }

    public let isActive: Bool
    public let title: String
    public let link: String

    public init(description: Description,
                isActive: Bool) {
        self.isActive = isActive

        self.title = description.title
        self.link = description.link
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
    public init(_ serie: DbRacingSerie) {
        self.id = serie.id!
        self.name = serie.name
        self.homePage = serie.homePage
        self.logoUrl = serie.logoUrl
        self.weeks = serie.weeks.map(RacingWeekEntry.init)
        self.currentWeek = serie.weeks.first.map(RacingWeekEntry.init)
        self.isFavorite = true
    }

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