import Foundation

public enum NumberFlowTrend: Equatable, Sendable {
    case auto
    case up
    case down
    case custom(@Sendable (Double, Double) -> Int)
    
    public static func == (lhs: NumberFlowTrend, rhs: NumberFlowTrend) -> Bool {
        switch (lhs, rhs) {
        case (.auto, .auto), (.up, .up), (.down, .down):
            return true
        case (.custom, .custom):
            return false
        default:
            return false
        }
    }
    
    func value(from oldValue: Double, to newValue: Double) -> Int {
        switch self {
        case .auto:
            let diff = newValue - oldValue
            if diff > 0 { return 1 }
            else if diff < 0 { return -1 }
            else { return 0 }
        case .up:
            return 1
        case .down:
            return -1
        case .custom(let calculator):
            return calculator(oldValue, newValue)
        }
    }
}

extension NumberFlowTrend {
    public static var `default`: NumberFlowTrend {
        .auto
    }
}
