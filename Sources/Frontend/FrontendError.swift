import Vapor

struct FrontendError: DebuggableError {
    struct ErrorResponse: Codable {
        let error: Bool
        let reason: String
    }

    var identifier: String {
        return UUID().uuidString
    }

    var reason: String {
        "HttpCode: \(httpCode). \(errorResponse?.reason ?? "Unknown")"
    }

    var source: ErrorSource?
    var stackTrace: StackTrace?

    private let httpCode: UInt
    private let errorResponse: ErrorResponse?

    init(
        _ errorResponse: ErrorResponse?,
        httpCode: UInt,
        file: String = #file,
        function: String = #function,
        line: UInt = #line,
        column: UInt = #column,
        stackTrace: StackTrace? = .capture()
    ) {
        self.errorResponse = errorResponse
        self.httpCode = httpCode

        self.source = .init(
            file: file,
            function: function,
            line: line,
            column: column
        )
        self.stackTrace = stackTrace
    }
}