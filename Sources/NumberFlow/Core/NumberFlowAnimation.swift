import UIKit

public enum TimingCurve: Equatable, Sendable {
    case spring
    case smooth
}

public struct NumberFlowAnimation: Equatable, Sendable {
    public var transformDuration: TimeInterval
    public var transformDampingRatio: CGFloat
    public var spinDuration: TimeInterval?
    public var spinDampingRatio: CGFloat?
    public var opacityDuration: TimeInterval
    public var isAnimated: Bool
    public var respectsReducedMotion: Bool
    public var timingCurve: TimingCurve

    public init(
        transformDuration: TimeInterval = 0.9,
        transformDampingRatio: CGFloat = 0.85,
        spinDuration: TimeInterval? = nil,
        spinDampingRatio: CGFloat? = nil,
        opacityDuration: TimeInterval = 0.45,
        isAnimated: Bool = true,
        respectsReducedMotion: Bool = true,
        timingCurve: TimingCurve = .spring
    ) {
        self.transformDuration = transformDuration
        self.transformDampingRatio = transformDampingRatio
        self.spinDuration = spinDuration
        self.spinDampingRatio = spinDampingRatio
        self.opacityDuration = opacityDuration
        self.isAnimated = isAnimated
        self.respectsReducedMotion = respectsReducedMotion
        self.timingCurve = timingCurve
    }

    public var effectiveSpinDuration: TimeInterval {
        spinDuration ?? transformDuration
    }

    public var effectiveSpinDampingRatio: CGFloat {
        spinDampingRatio ?? transformDampingRatio
    }

    @MainActor
    public var shouldAnimate: Bool {
        guard isAnimated else { return false }
        if respectsReducedMotion && UIAccessibility.isReduceMotionEnabled {
            return false
        }
        return true
    }
}

extension NumberFlowAnimation {
    public static var `default`: NumberFlowAnimation {
        NumberFlowAnimation()
    }

    public static var fast: NumberFlowAnimation {
        NumberFlowAnimation(
            transformDuration: 0.5,
            transformDampingRatio: 0.9,
            opacityDuration: 0.25
        )
    }

    public static var slow: NumberFlowAnimation {
        NumberFlowAnimation(
            transformDuration: 1.5,
            transformDampingRatio: 0.75,
            opacityDuration: 0.75
        )
    }
}
