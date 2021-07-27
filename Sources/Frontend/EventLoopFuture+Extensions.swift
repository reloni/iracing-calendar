import Vapor

extension EventLoopFuture where Value == ClientResponse {  
    func filterHttpError() -> EventLoopFuture<Value> {
        flatMap { response in
            if response.isSuccess {
                return self.eventLoop.makeSucceededFuture(response)
            } else {
                let error =  FrontendError.init(try? response.content.decode(FrontendError.ErrorResponse.self), 
                                                httpCode: response.status.code)
                return self.eventLoop.makeCompletedFuture(.failure(error))
            }
        }
    }
}