import Vapor
import Leaf

struct NavbarItem: Codable {
    let title: String
    let link: String
    let isActive: Bool
}

struct Serie: Codable {
    let name: String
    let nextRace: String
    let startDate: String
    let length: String
    let track: String
}

protocol ViewContext: Content {
    var title: String { get }
    var navbarItems: [NavbarItem] { get }
}

struct SeriesViewContext: ViewContext {
    let title: String
    let series: [Serie]
    let navbarItems: [NavbarItem]
}

struct HomeViewContext: ViewContext {
    let title: String
    let navbarItems: [NavbarItem]
}

func routes(_ app: Application) throws {
    try app.register(collection: MainController())
}