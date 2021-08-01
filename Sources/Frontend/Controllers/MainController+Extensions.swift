import Vapor
import Leaf
import Core

extension MainController {
    struct SeriesViewContext: ViewContext {
        let title: String
        let user: SessionUser?
        let series: [RacingSerie]
        let navbarItems: [NavbarItem]
    }

    struct HomeViewContext: ViewContext {
        let title: String
        let user: SessionUser?
        let navbarItems: [NavbarItem]
    }

    struct SerieDetailsContext: ViewContext {
        let id: UUID
        let title: String
        let user: SessionUser?
        let navbarItems: [NavbarItem]
    }
}