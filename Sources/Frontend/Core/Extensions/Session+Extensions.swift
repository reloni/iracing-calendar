import Vapor

extension Session {
    var user: SessionUser? {
        get {
            decode(SessionUser.self, key: "user")
        }
        set {
            encode(key: "user", value: newValue)
        }
    }
}

extension Session {
    func encode<T: Encodable>(key: String, value: T) {
        self.data[key] = (try? JSONEncoder().encode(value))
                            .map { String(data: $0, encoding: .utf8) } ?? nil
    }

    func decode<T: Decodable>(_ type: T.Type, key: String) -> T? {
        guard let data = self.data[key]?.data(using: .utf8) else { return nil }
        return try? JSONDecoder().decode(type, from: data)   
    }
}