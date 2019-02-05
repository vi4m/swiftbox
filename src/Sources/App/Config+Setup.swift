import FluentProvider
import LeafProvider

extension Config {

    public func setupProviders() throws {
        try addProvider(FluentProvider.Provider.self)
        try addProvider(LeafProvider.Provider.self)
    }

    /// Add all models that should have their
    /// schemas prepared before the app boots
    public func setupPreparations() throws {
        preparations.append(Post.self)
    }
}

