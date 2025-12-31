import UIKit

@MainActor
final class CharacterView: UIView {
    enum Content {
        case digit(DigitColumnView)
        case symbol(UILabel)
        case currencySymbol(UILabel, referenceFont: UIFont)
    }

    let key: NumberPartKey
    let partType: NumberPartType
    let content: Content

    private var fadeAnimator: UIViewPropertyAnimator?

    var isPresent: Bool = true {
        didSet {
            guard isPresent != oldValue else { return }
            updatePresence()
        }
    }

    init(key: NumberPartKey, partType: NumberPartType, content: Content) {
        self.key = key
        self.partType = partType
        self.content = content
        super.init(frame: .zero)
        setupView()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupView() {
        translatesAutoresizingMaskIntoConstraints = false
        setContentHuggingPriority(.required, for: .horizontal)
        setContentCompressionResistancePriority(.required, for: .horizontal)

        switch content {
        case .digit(let digitView):
            addContentView(digitView)

        case .symbol(let label):
            addContentView(label)

        case .currencySymbol(let label, let referenceFont):
            addCurrencyLabel(label, referenceFont: referenceFont)
        }
    }

    private func addContentView(_ view: UIView) {
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        NSLayoutConstraint.activate([
            view.leadingAnchor.constraint(equalTo: leadingAnchor),
            view.trailingAnchor.constraint(equalTo: trailingAnchor),
            view.topAnchor.constraint(equalTo: topAnchor),
            view.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
    }

    private func addCurrencyLabel(_ label: UILabel, referenceFont: UIFont) {
        label.translatesAutoresizingMaskIntoConstraints = false
        addSubview(label)

        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: leadingAnchor),
            label.trailingAnchor.constraint(equalTo: trailingAnchor),
            label.centerYAnchor.constraint(equalTo: centerYAnchor),
        ])

        let digitHeight = Self.measureHeight(for: referenceFont)
        let labelHeight = label.intrinsicContentSize.height
        let offsetY = -(digitHeight - labelHeight) * 0.15
        label.transform = CGAffineTransform(translationX: 0, y: offsetY)
    }

    private static func measureHeight(for font: UIFont) -> CGFloat {
        ("8" as NSString).size(withAttributes: [.font: font]).height
    }

    func fadeIn(duration: TimeInterval) {
        fadeAnimator?.stopAnimation(true)

        alpha = 0
        isHidden = false

        fadeAnimator = UIViewPropertyAnimator(duration: duration, curve: .easeOut) { [weak self] in
            self?.alpha = 1
        }
        fadeAnimator?.startAnimation()
    }

    func fadeOut(duration: TimeInterval, completion: (() -> Void)? = nil) {
        fadeAnimator?.stopAnimation(true)

        fadeAnimator = UIViewPropertyAnimator(duration: duration, curve: .easeIn) { [weak self] in
            self?.alpha = 0
        }

        fadeAnimator?.addCompletion { [weak self] position in
            if position == .end {
                self?.isHidden = true
                completion?()
            }
        }

        fadeAnimator?.startAnimation()
    }

    private func updatePresence() {
        if isPresent {
            isHidden = false
            alpha = 1
        } else {
            isHidden = true
            alpha = 0
        }
    }

    override var intrinsicContentSize: CGSize {
        switch content {
        case .digit(let digitView):
            return digitView.intrinsicContentSize
        case .symbol(let label):
            return label.intrinsicContentSize
        case .currencySymbol(let label, _):
            return label.intrinsicContentSize
        }
    }
}
