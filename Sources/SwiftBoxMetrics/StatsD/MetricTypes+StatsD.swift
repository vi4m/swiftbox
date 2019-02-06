import Foundation

public protocol StatsDMetric: Metric {
    func getStatsDLine() -> String
}

extension TimerMetric: StatsDMetric {
    public func getStatsDLine() -> String {
        return "\(self.name):\(self.value)|ms"
    }
}

extension CounterMetric: StatsDMetric {
    public func getStatsDLine() -> String {
        return "\(self.name):\(self.value)|c"
    }
}

extension GaugeMetric: StatsDMetric {
    public func getStatsDLine() -> String {
        return "\(self.name):\(self.type.rawValue)\(self.value)|g"
    }
}