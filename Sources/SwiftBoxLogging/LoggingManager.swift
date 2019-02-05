import Logging

public enum Logging {
    private static var _factory: (String) -> Logger = { _ in
        PrintLogger()
    }

    public static func bootstrap(_ factory: @escaping (String) -> Logger) {
        self._factory = factory
    }

    public static func make(_ label: String) -> Logger {
        return self._factory(label)
    }
}
