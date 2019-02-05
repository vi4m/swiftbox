import XCTest
import HTTP
import Vapor

import SwiftBoxMicroserviceContract

internal extension Application {
    static func testable(args: [String]) throws -> Application {
        let config = Config.default()
        var services = Services.default()
        var env = Environment.testing
        env.arguments = args

        let sampleProjectProperties =
                "{\"boundedContext\": \"test\"," +
                 "\"domain\": \"tech\"," +
                 "\"title\": \"test-service\"," +
                 "\"version\": \"1.0\"," +
                 "\"serviceId\": \"test.id\"," +
                 "\"scmRepository\": \"https://stash.allegrogroup.com/projects/TECHAPPENGINE/repos/test/browse\"}"

        services.register(Router.self) { _ -> EngineRouter in
            let router = EngineRouter.default()
            try router.register(
                    collection: MicroServiceContractController(projectPropertiesContent: sampleProjectProperties.data(using: .utf8)!)
            )
            return router
        }

        let app = try Application(config: config, environment: env, services: services)
        return app
    }

    func sendRequest(request: Request) throws -> Response {
        let responder = try self.make(Responder.self)
        return try responder.respond(to: request).wait()
    }

    func sendRequest(request: HTTPRequest) throws -> Response {
        return try sendRequest(request: Request(http: request, using: self))
    }
}


internal class ServerTestCase: XCTestCase {
    let app = try! Application.testable(args: ["serve", "-p", "8888"])

    override func setUp() {
        do {
            try app.asyncRun().wait()
        } catch {
            fatalError("Failed to launch server.")
        }

    }

    override func tearDown() {
        try? app.runningServer?.close().wait()
    }
}