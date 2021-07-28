import Vapor 

extension RouteCollection {
    public func navBarItems(_ req: Request, activeItem: NavbarItem.Description?) -> [NavbarItem] {
        let isAuthenticated = req.session.user != nil
        return [
            isAuthenticated ? .init(description: .favorites, isActive: activeItem == .favorites) : nil,
            .init(description: .allSeries, isActive: activeItem == .allSeries),
            isAuthenticated ? .init(description: .profile, isActive: activeItem == .profile) : nil
        ].compactMap { $0 }
    }
}