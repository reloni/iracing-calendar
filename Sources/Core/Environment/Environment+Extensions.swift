import Vapor

extension Environment {
    public static var local: Environment {
        .custom(name: "local")
    }
}