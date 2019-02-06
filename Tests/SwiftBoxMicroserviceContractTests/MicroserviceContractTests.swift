import XCTest
import HTTP
import Vapor

import SwiftBoxMicroserviceContract

class MicroserviceContractTests: XCTestCase {

    func testServiceMetadataBuilder() throws {
        let sampleProjectProperties =
                "{\"boundedContext\": \"test\"," +
                        "\"domain\": \"tech\"," +
                        "\"title\": \"test\"," +
                        "\"version\": \"1.0\"," +
                        "\"serviceId\": \"test.id\"," +
                        "\"scmRepository\": \"https://stash.allegrogroup.com/projects/TECHAPPENGINE/repos/test/browse\"}"

        let filePath = "/tmp/project-properties-test.json"
        try sampleProjectProperties.write(toFile: filePath, atomically: false, encoding: .utf8)

        let builder = ServiceMetadataBuilder(projectPropertiesPath: filePath)
        let metadata = builder.metadata

        XCTAssertEqual(metadata.boundedContext, "test")
        XCTAssertEqual(metadata.domain, "tech")
        XCTAssertEqual(metadata.title, "test")
        XCTAssertEqual(metadata.version, "1.0")
        XCTAssertEqual(metadata.serviceId, "test.id")
        XCTAssertEqual(metadata.scmRepository, "https://stash.allegrogroup.com/projects/TECHAPPENGINE/repos/test/browse")
    }

    static var allTests: [(String, (MicroserviceContractTests) -> () throws -> Void)] {
        return [
            ("testServiceMetadataBuilder", testServiceMetadataBuilder),
        ]
    }
}

class MicroserviceContractEndpointTests: ServerTestCase {
    func testPing() throws {
        let request = HTTPRequest(method: .GET, url: "/status/ping")
        let response = try app.sendRequest(request: request)

        XCTAssertEqual(response.http.status, .ok)
        XCTAssertEqual(response.http.body.description, "pong")
    }

    func testPingByServiceId() throws {
        let request = HTTPRequest(method: .GET, url: "/status/ping/test.id")
        let response = try app.sendRequest(request: request)
        XCTAssertEqual(response.http.status, .ok)
        XCTAssertEqual(response.http.body.description, "pong")
    }

    func testPingByWrongServiceId() throws {
        let request = HTTPRequest(method: .GET, url: "/status/ping/someothername")
        let response = try app.sendRequest(request: request)
        XCTAssertEqual(response.http.status, .notFound)
    }

    func testStatusInfo() throws {
        let request = HTTPRequest(method: .GET, url: "/status/info")
        let response = try app.sendRequest(request: request)

        let expectedResponse = InfoResponse(title: "test-service", version: "1.0", domain: "tech")
        let responseData = try JSONDecoder().decode(InfoResponse.self, from: response.http.body.data!)

        XCTAssertEqual(expectedResponse, responseData)
    }

    func testPublicEndpoints() throws {
        let request = HTTPRequest(method: .GET, url: "/status/public-endpoints")
        let response = try app.sendRequest(request: request)

        XCTAssertEqual(response.http.status, .ok)
        XCTAssertEqual(response.http.body.description, "Not implemented yet")
    }

    static var allTests: [(String, (MicroserviceContractEndpointTests) -> () throws -> Void)] {
        return [
            ("testPing", testPing),
            ("testPingByServiceId", testPingByServiceId),
            ("testPingByWrongServiceId", testPingByWrongServiceId),
            ("testStatusInfo", testStatusInfo),
            ("testPublicEndpoints", testPublicEndpoints),
        ]
    }
}


