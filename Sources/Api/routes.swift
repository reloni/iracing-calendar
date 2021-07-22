import Vapor
import GoogleAuth

func routes(_ app: Application) throws {
    try app.register(collection: ApiController())
    try app.register(collection: GoogleAuthBackendController())
}