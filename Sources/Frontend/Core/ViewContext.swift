import Vapor
import Leaf

protocol ViewContext: Content {
    var title: String { get }
    var navbarItems: [NavbarItem] { get }
    var user: SessionUser? { get }
}