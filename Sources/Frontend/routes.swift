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
    var series: [Serie] { get }
    var navbarItems: [NavbarItem] { get }
}

struct SeriesViewContext: ViewContext {
    let title: String
    let series: [Serie]
    let navbarItems: [NavbarItem]
}

func routes(_ app: Application) throws {
    app.get { req in 
        return "Home"
    }

    app.get("home") { req in 
        return "Home"
    }
    
    app.get("favorite-series") { req -> EventLoopFuture<View> in
        let context = SeriesViewContext(
            title: "Favorite series",
            series: [
                .init(name: "Porsche iRacing Cup", nextRace: "2 minutes", startDate: "11 May", length: "16 laps", track: "Hockenheimring Baden-Württemberg - Grand Prix"),
                .init(name: "VRS GT Sprint Series", nextRace: "12 minutes", startDate: "11 May", length: "40 mins", track: "Okayama International Circuit - Full Course"),
                .init(name: "IMSA Michelin Pilot Challenge", nextRace: "67 minutes", startDate: "11 May", length: "30 mins", track: "Mid-Ohio Sports Car Course - Full Course"),
                .init(name: "IMSA Hagerty iRacing Series", nextRace: "112 minutes", startDate: "11 May", length: "45 mins", track: "Mid-Ohio Sports Car Course - Full Course"),
                .init(name: "Pure Driving School European Sprint Series", nextRace: "15 minutes", startDate: "11 May", length: "60 mins", track: "Silverstone Circuit - Grand Prix")
            ],
            navbarItems: [
                .init(title: "Favorites", link: "favorite-series", isActive: true),
                .init(title: "All series", link: "home", isActive: false),
                .init(title: "Profile", link: "home", isActive: false),
            ]
            )
        return req.view.render("favorite-series", context)
    }
}