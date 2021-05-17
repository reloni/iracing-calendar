import Vapor
import Leaf

extension MainController {
    struct SeriesViewContext: ViewContext {
        let title: String
        let series: [Serie]
        let navbarItems: [NavbarItem]
    }

    struct HomeViewContext: ViewContext {
        let title: String
        let navbarItems: [NavbarItem]
    }
}