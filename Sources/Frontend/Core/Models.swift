import Vapor

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
    var isFavorite: Bool
}