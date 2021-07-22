import Vapor

public func checkEnvironmentVariables<T: CaseIterable>(for app: Application, tag: EnvironmentTag<T>) {
    let notExistedVars = tag.variables.compactMap { envVar -> String? in
        return Environment.get(envVar) == nil ? envVar : nil
    }

    notExistedVars.forEach {
        app.logger.critical("Env var \($0) not existed")
    }

    if notExistedVars.count > 0 {
        fatalError()
    }
}