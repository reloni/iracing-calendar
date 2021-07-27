import Vapor

extension ClientResponse {
    public var isSuccess: Bool {
        200..<300 ~= status.code
    }
}