import Foundation

public struct ServiceMetadataBuilder {
    public var projectPropertiesPath: String?
    public var metadata: ServiceMetadata

    public init(projectPropertiesPath path: String) {
        let contents: Data
        do {
            contents = try Data(contentsOf: URL(fileURLWithPath: path))
        } catch {
            fatalError("Could not read project properties file: \(path), error: \(error)")
        }

        self.init(projectPropertiesContents: contents)
        projectPropertiesPath = path
    }

    public init(projectPropertiesContents: Data) {
        do {
            metadata = try JSONDecoder().decode(ServiceMetadata.self, from: projectPropertiesContents)
        } catch {
            fatalError("Project properties file has invalid format")
        }
    }
}

public struct ServiceMetadata: Codable {
    public var title: String
    public var version: String
    public var domain: String
    public var boundedContext: String
    public var serviceId: String

    public var builtBy: String?
    public var builtDate: String?
    public var builtHost: String?
    public var scmBranch: String?
    public var scmCommit: String?
    public var scmRepository: String?

    public func taskId() -> String {
        if let variable = ProcessInfo.processInfo.environment["MESOS_TASK_ID"] {
            return variable
        } else {
            return UUID().description
        }
    }
}
