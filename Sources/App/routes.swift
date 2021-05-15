import Vapor
import Leaf

func routes(_ app: Application) throws {
    app.get { req in
        return "It works!"
    }
    
    app.get("series") { req -> EventLoopFuture<View> in
        return req.view.render("series-table", ["name": "Leaf"])
    }
}
