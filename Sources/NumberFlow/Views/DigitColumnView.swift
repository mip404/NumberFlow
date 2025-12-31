import UIKit

@MainActor
final class DigitColumnView: UIView {

    private let digitsPerCycle = 10
    private let cycles = 3
    private var totalCount: Int { digitsPerCycle * cycles }
    private var middleCycleOffset: Int { digitsPerCycle }

    private let containerView = UIView()
    private let stackView = UIStackView()
    private var digitLabels: [UILabel] = []

    private var maskLayer: CAGradientLayer?

    private var currentIndex: Int = 10
    private var animator: UIViewPropertyAnimator?

    private var currentDigit: Int {
        (currentIndex % digitsPerCycle + digitsPerCycle) % digitsPerCycle
    }

    var font: UIFont = .monospacedDigitSystemFont(ofSize: 17, weight: .regular) {
        didSet { applyFontAndResize() }
    }

    var textColor: UIColor = .label {
        didSet { digitLabels.forEach { $0.textColor = textColor } }
    }

    init() {
        super.init(frame: .zero)
        setupView()
        applyFontAndResize()
        recenterWithoutAnimation()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setDigit(_ newDigit: Int, direction: Int, animation: NumberFlowAnimation) {
        let clamped = max(0, min(9, newDigit))

        layoutIfNeeded()

        if bounds.height <= 0 {
            currentIndex = middleCycleOffset + clamped
            updateTransform(animated: false)
            return
        }

        finishAndSyncIfAnimating()

        if clamped == currentDigit { return }

        recenterWithoutAnimation()

        let oldDigit = currentDigit
        let rawDelta = clamped - oldDigit
        let delta = computeDelta(rawDelta: rawDelta, direction: direction)
        let targetIndex = currentIndex + delta

        guard animation.shouldAnimate else {
            currentIndex = middleCycleOffset + clamped
            updateTransform(animated: false)
            return
        }

        animateToIndex(targetIndex, animation: animation) { [weak self] in
            guard let self else { return }
            self.currentIndex = targetIndex
            self.recenterWithoutAnimation()
        }
    }

    private func setupView() {
        translatesAutoresizingMaskIntoConstraints = false
        isOpaque = false
        clipsToBounds = true

        containerView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(containerView)

        NSLayoutConstraint.activate([
            containerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            containerView.topAnchor.constraint(equalTo: topAnchor),
            containerView.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])

        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .fillEqually
        stackView.spacing = 0
        stackView.translatesAutoresizingMaskIntoConstraints = false

        containerView.addSubview(stackView)

        digitLabels.removeAll(keepingCapacity: true)
        for _ in 0..<cycles {
            for value in 0...9 {
                let label = UILabel()
                label.text = "\(value)"
                label.textAlignment = .center
                label.adjustsFontForContentSizeCategory = false
                label.setContentCompressionResistancePriority(.required, for: .horizontal)
                label.setContentHuggingPriority(.required, for: .horizontal)
                digitLabels.append(label)
                stackView.addArrangedSubview(label)
            }
        }

        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            stackView.topAnchor.constraint(equalTo: containerView.topAnchor),
            stackView.heightAnchor.constraint(equalTo: containerView.heightAnchor,
                                              multiplier: CGFloat(totalCount)),
        ])

        setContentHuggingPriority(.required, for: .horizontal)
        setContentCompressionResistancePriority(.required, for: .horizontal)

        let g = CAGradientLayer()
        g.colors = [
            UIColor.clear.cgColor,
            UIColor.black.cgColor,
            UIColor.black.cgColor,
            UIColor.clear.cgColor,
        ]
        g.locations = [0.0, 0.2, 0.8, 1.0]
        g.startPoint = CGPoint(x: 0.5, y: 0.0)
        g.endPoint = CGPoint(x: 0.5, y: 1.0)

        containerView.layer.mask = g
        maskLayer = g
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        maskLayer?.frame = containerView.bounds
        updateTransform(animated: false)
    }

    private func applyFontAndResize() {
        digitLabels.forEach {
            $0.font = font
            $0.textColor = textColor
        }

        invalidateIntrinsicContentSize()
        setNeedsLayout()
    }

    private func measureDigitSize() -> CGSize {
        let s = "8" as NSString
        let raw = s.size(withAttributes: [.font: font])
        return CGSize(width: ceil(raw.width), height: ceil(raw.height))
    }

    override var intrinsicContentSize: CGSize {
        measureDigitSize()
    }

    private func computeDelta(rawDelta: Int, direction: Int) -> Int {
        guard rawDelta != 0 else { return 0 }

        if direction > 0 {
            return rawDelta >= 0 ? rawDelta : (rawDelta + digitsPerCycle)
        } else if direction < 0 {
            return rawDelta <= 0 ? rawDelta : (rawDelta - digitsPerCycle)
        } else {
            if abs(rawDelta) <= digitsPerCycle / 2 {
                return rawDelta
            } else {
                return rawDelta > 0 ? (rawDelta - digitsPerCycle) : (rawDelta + digitsPerCycle)
            }
        }
    }

    private func finishAndSyncIfAnimating() {
        guard let animator else { return }
        animator.stopAnimation(false)
        animator.finishAnimation(at: .current)
        self.animator = nil
        syncIndexFromCurrentTransform()
    }

    private func syncIndexFromCurrentTransform() {
        let ty = stackView.transform.ty
        let index = Int(round((-ty) / bounds.height))
        currentIndex = max(0, min(totalCount - 1, index))
    }

    private func recenterWithoutAnimation() {
        currentIndex = middleCycleOffset + currentDigit
        updateTransform(animated: false)
    }

    private func updateTransform(animated: Bool) {
        guard bounds.height > 0 else { return }
        let y = -CGFloat(currentIndex) * bounds.height

        if animated {
            UIView.animate(withDuration: 0.25, delay: 0, options: [.curveEaseInOut]) {
                self.stackView.transform = CGAffineTransform(translationX: 0, y: y)
            }
        } else {
            stackView.transform = CGAffineTransform(translationX: 0, y: y)
        }
    }

    private func animateToIndex(_ index: Int,
                                animation: NumberFlowAnimation,
                                completion: @escaping () -> Void) {
        let y = -CGFloat(index) * bounds.height

        let timing: UITimingCurveProvider
        switch animation.timingCurve {
        case .spring:
            timing = UISpringTimingParameters(dampingRatio: animation.effectiveSpinDampingRatio)
        case .smooth:
            timing = UICubicTimingParameters(animationCurve: .easeOut)
        }

        let a = UIViewPropertyAnimator(duration: animation.effectiveSpinDuration,
                                       timingParameters: timing)
        animator = a

        a.addAnimations { [weak self] in
            self?.stackView.transform = CGAffineTransform(translationX: 0, y: y)
        }
        a.addCompletion { pos in
            if pos == .end { completion() }
        }
        a.startAnimation()
    }
}

