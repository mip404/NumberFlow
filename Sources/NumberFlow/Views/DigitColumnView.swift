import UIKit

@MainActor
final class DigitColumnView: UIView {

    private let containerView = UIView()
    private let stackView = UIStackView()
    private var digitLabels: [UILabel] = []
    private var maskLayer: CAGradientLayer?
    private var heightConstraint: NSLayoutConstraint?
    private var widthConstraint: NSLayoutConstraint?

    private var currentDigit: Int = 0
    private var animator: UIViewPropertyAnimator?

    var font: UIFont = .monospacedDigitSystemFont(ofSize: 17, weight: .regular) {
        didSet {
            digitLabels.forEach { $0.font = font }
            // Force layout to get accurate size for new font
            if let firstLabel = digitLabels.first {
                firstLabel.sizeToFit()
                let size = firstLabel.intrinsicContentSize
                heightConstraint?.constant = size.height
                widthConstraint?.constant = size.width
            }
            invalidateIntrinsicContentSize()
            setNeedsLayout()
        }
    }

    var textColor: UIColor = .label {
        didSet {
            digitLabels.forEach { $0.textColor = textColor }
        }
    }

    init() {
        super.init(frame: .zero)
        setupView()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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

        for value in 0...9 {
            let label = UILabel()
            label.text = "\(value)"
            label.textAlignment = .center
            label.font = font
            label.textColor = textColor
            label.adjustsFontForContentSizeCategory = false

            // Critical: Ensure all digits have exact same width
            label.setContentCompressionResistancePriority(.required, for: .horizontal)
            label.setContentHuggingPriority(.required, for: .horizontal)

            digitLabels.append(label)
            stackView.addArrangedSubview(label)
        }

        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            stackView.topAnchor.constraint(equalTo: containerView.topAnchor),
            stackView.heightAnchor.constraint(equalTo: containerView.heightAnchor, multiplier: 10),
        ])

        setContentHuggingPriority(.required, for: .horizontal)
        setContentCompressionResistancePriority(.required, for: .horizontal)

        // Constrain this view's height to show only one digit at a time
        // Force layout to get accurate size
        if let firstLabel = digitLabels.first {
            firstLabel.sizeToFit()
            let size = firstLabel.intrinsicContentSize
            heightConstraint = heightAnchor.constraint(equalToConstant: size.height)
            heightConstraint?.priority = .required
            heightConstraint?.isActive = true

            // Constrain width to be exactly one digit wide for consistency
            widthConstraint = widthAnchor.constraint(equalToConstant: size.width)
            widthConstraint?.priority = .required
            widthConstraint?.isActive = true
        }

        setupMask()
    }

    private func setupMask() {
        let gradientMask = CAGradientLayer()
        gradientMask.colors = [
            UIColor.clear.cgColor,
            UIColor.black.cgColor,
            UIColor.black.cgColor,
            UIColor.clear.cgColor,
        ]
        gradientMask.locations = [0.0, 0.2, 0.8, 1.0]
        gradientMask.startPoint = CGPoint(x: 0.5, y: 0.0)
        gradientMask.endPoint = CGPoint(x: 0.5, y: 1.0)

        containerView.layer.mask = gradientMask
        maskLayer = gradientMask
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        maskLayer?.frame = containerView.bounds

        updateTransform(animated: false)
    }

    func setDigit(_ newDigit: Int, trend: NumberFlowTrend, animation: NumberFlowAnimation) {
        let clamped = max(0, min(9, newDigit))

        guard clamped != currentDigit else { return }

        let oldDigit = currentDigit
        currentDigit = clamped

        let shouldAnimate = animation.shouldAnimate

        if shouldAnimate {
            animateToDigit(from: oldDigit, to: clamped, trend: trend, animation: animation)
        } else {
            updateTransform(animated: false)
        }
    }

    private func animateToDigit(
        from oldDigit: Int,
        to newDigit: Int,
        trend: NumberFlowTrend,
        animation: NumberFlowAnimation
    ) {
        animator?.stopAnimation(true)

        let rawDelta = newDigit - oldDigit
        let computedTrend = trend.value(from: Double(oldDigit), to: Double(newDigit))

        let delta: Int
        if computedTrend > 0 && rawDelta < 0 {
            delta = 10 + rawDelta
        } else if computedTrend < 0 && rawDelta > 0 {
            delta = rawDelta - 10
        } else {
            delta = rawDelta
        }

        let digitHeight = bounds.height
        let targetOffset = CGFloat(newDigit) * digitHeight
        let currentOffset = CGFloat(oldDigit) * digitHeight

        stackView.transform = CGAffineTransform(translationX: 0, y: -currentOffset)

        animator = UIViewPropertyAnimator(
            duration: animation.effectiveSpinDuration,
            curve: .easeOut
        )

        animator?.addAnimations { [weak self] in
            guard let self else { return }
            self.stackView.transform = CGAffineTransform(translationX: 0, y: -targetOffset)
        }

        animator?.startAnimation()
    }

    private func updateTransform(animated: Bool) {
        let digitHeight = bounds.height
        let offset = CGFloat(currentDigit) * digitHeight

        if animated {
            UIView.animate(
                withDuration: 0.3,
                delay: 0,
                options: [.curveEaseInOut],
                animations: { [weak self] in
                    self?.stackView.transform = CGAffineTransform(translationX: 0, y: -offset)
                }
            )
        } else {
            stackView.transform = CGAffineTransform(translationX: 0, y: -offset)
        }
    }

    override var intrinsicContentSize: CGSize {
        // Monospaced fonts ensure all digits have the same width
        let width = digitLabels.first?.intrinsicContentSize.width ?? 0
        let height = digitLabels.first?.intrinsicContentSize.height ?? 0
        return CGSize(width: width, height: height)
    }
}
