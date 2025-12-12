import UIKit

@MainActor
final class CharacterView: UIView {

    enum Content {
        case digit(DigitColumnView)
        case symbol(UILabel)
    }

    let key: NumberPartKey
    let content: Content
    private var fadeAnimator: UIViewPropertyAnimator?

    var isPresent: Bool = true {
        didSet {
            guard isPresent != oldValue else { return }
            updatePresence()
        }
    }

    init(key: NumberPartKey, content: Content) {
        self.key = key
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

        let contentView: UIView
        switch content {
        case .digit(let digitView):
            contentView = digitView
        case .symbol(let label):
            contentView = label
        }

        contentView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(contentView)

        NSLayoutConstraint.activate([
            contentView.leadingAnchor.constraint(equalTo: leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: trailingAnchor),
            contentView.topAnchor.constraint(equalTo: topAnchor),
            contentView.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])

        // Critical: Prevent compression of any character
        setContentHuggingPriority(.required, for: .horizontal)
        setContentCompressionResistancePriority(.required, for: .horizontal)
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
        }
    }
}
