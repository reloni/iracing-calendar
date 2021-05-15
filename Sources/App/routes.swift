import Vapor
import Leaf

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
}

struct SeriesViewContext: ViewContext {
    let title: String
    let series: [Serie]
}

func routes(_ app: Application) throws {
    app.get { req in
        return "It works!"
    }
    
    app.get("series") { req -> EventLoopFuture<View> in
        let context = SeriesViewContext(
            title: "Current series",
            series: [
                .init(name: "Porsche iRacing Cup", nextRace: "2 minutes", startDate: "11 May", length: "16 laps", track: "Hockenheimring Baden-Württemberg - Grand Prix"),
                .init(name: "VRS GT Sprint Series", nextRace: "12 minutes", startDate: "11 May", length: "40 mins", track: "Okayama International Circuit - Full Course"),
                .init(name: "IMSA Michelin Pilot Challenge", nextRace: "67 minutes", startDate: "11 May", length: "30 mins", track: "Mid-Ohio Sports Car Course - Full Course"),
                .init(name: "IMSA Hagerty iRacing Series", nextRace: "112 minutes", startDate: "11 May", length: "45 mins", track: "Mid-Ohio Sports Car Course - Full Course"),
                .init(name: "Pure Driving School European Sprint Series", nextRace: "15 minutes", startDate: "11 May", length: "60 mins", track: "Silverstone Circuit - Grand Prix")
            ]
            )
        return req.view.render("series-table", context)
    }
}