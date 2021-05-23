import Vapor
import Leaf

extension MainController {
    struct SeriesViewContext: ViewContext {
        let title: String
        let user: SessionUser?
        let series: [Serie]
        let navbarItems: [NavbarItem]
    }

    struct HomeViewContext: ViewContext {
        let title: String
        let user: SessionUser?
        let navbarItems: [NavbarItem]
    }
}