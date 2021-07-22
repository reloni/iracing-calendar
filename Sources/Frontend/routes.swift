import Vapor
import GoogleAuth

func routes(_ app: Application) throws {
    try app.register(collection: MainController())
    try app.register(collection: GoogleAuthFrontendController())
}