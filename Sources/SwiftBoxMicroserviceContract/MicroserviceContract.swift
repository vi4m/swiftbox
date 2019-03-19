import Vapor

public struct InfoResponse: Content {
    public var title: String
    public var version: String
    public var domain: String

    public init(serviceMetadata: ServiceMetadata) {
        title = serviceMetadata.title
        version = serviceMetadata.version
        domain = serviceMetadata.domain
    }

    public init(title: String, version: String, domain: String) {
        self.title = title
        self.version = version
        self.domain = domain
    }
}

extension InfoResponse: Equatable {}

public final class MicroserviceContractController {
    let metadata: ServiceMetadata

    public init(projectPropertiesPath: String? = nil) {
        guard let path = projectPropertiesPath ?? ProcessInfo.processInfo.environment["PROJECT_PROPERTIES_PATH"] else {
            fatalError("PROJECT_PROPERTIES_PATH env must be set or passed directly!")
        }

        metadata = ServiceMetadataBuilder(projectPropertiesPath: path).metadata
    }

    public init(projectPropertiesContent: Data) {
        metadata = ServiceMetadataBuilder(projectPropertiesContents: projectPropertiesContent).metadata
    }

    private func ping(_: Request) throws -> String {
        return "pong"
    }

    private func info(_: Request) throws -> InfoResponse {
        return InfoResponse(serviceMetadata: metadata)
    }

    private func publicEndpoints(_: Request) throws -> String {
        return "Not implemented yet"
    }
}

extension MicroserviceContractController: RouteCollection {
    public func boot(router: Router) throws {
        let appId = metadata.taskId()
        let serviceId = metadata.serviceId

        router.get("/status/ping", use: ping)
        router.get("/status/ping/\(appId)", use: ping)
        router.get("/status/ping/\(serviceId)", use: ping)
        router.get("/status/info", use: info)
        router.get("/status/public-endpoints", use: publicEndpoints)
    }
}
