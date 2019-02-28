import Vapor


public struct InfoResponse: Content {
    public var title: String
    public var version: String
    public var domain: String

    public init(serviceMetadata: ServiceMetadata) {
        self.title = serviceMetadata.title
        self.version = serviceMetadata.version
        self.domain = serviceMetadata.domain
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

        self.metadata = ServiceMetadataBuilder(projectPropertiesPath: path).metadata
    }

    public init(projectPropertiesContent: Data) {
        self.metadata = ServiceMetadataBuilder(projectPropertiesContents: projectPropertiesContent).metadata
    }

    private func ping(_: Request) throws -> String {
        return "pong"
    }

    private func info(_: Request) throws -> InfoResponse {
        return InfoResponse(serviceMetadata: self.metadata)
    }

    private func publicEndpoints(_: Request) throws -> String {
        return "Not implemented yet"
    }
}

extension MicroserviceContractController: RouteCollection {
    public func boot(router: Router) throws {
        let appId = self.metadata.taskId()
        let serviceId = self.metadata.serviceId

        router.get("/status/ping", use: self.ping)
        router.get("/status/ping/\(appId)", use: self.ping)
        router.get("/status/ping/\(serviceId)", use: self.ping)
        router.get("/status/info", use: self.info)
        router.get("/status/public-endpoints", use: self.publicEndpoints)
    }
}
