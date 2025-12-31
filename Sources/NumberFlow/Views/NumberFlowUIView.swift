import UIKit

@MainActor
public final class NumberFlowUIView: UIView {
    public var data: NumberFlowData {
        didSet { updateValue(from: oldValue, to: data) }
    }

    public var animation: NumberFlowAnimation = .default
    public var trend: NumberFlowTrend = .default

    public var font: UIFont = .monospacedDigitSystemFont(ofSize: 17, weight: .regular) {
        didSet { updateFont() }
    }

    public var textColor: UIColor = .label {
        didSet { updateTextColor() }
    }

    public var currencySymbolScale: CGFloat = 1.0 {
        didSet { if currencySymbolScale != oldValue { rebuildCharacters() } }
    }

    public var symbolColor: UIColor? {
        didSet { updateTextColor() }
    }

    public var fractionColor: UIColor? {
        didSet { updateTextColor() }
    }

    private let stackView = UIStackView()
    private var characters: [NumberPartKey: CharacterView] = [:]

    public init(data: NumberFlowData) {
        self.data = data
        super.init(frame: .zero)
        setupView()
        initialRender()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupView() {
        isOpaque = false

        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .fill
        stackView.spacing = 0
        stackView.translatesAutoresizingMaskIntoConstraints = false

        addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            stackView.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor),
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])

        isAccessibilityElement = true
        accessibilityTraits = .staticText

        setContentHuggingPriority(.required, for: .horizontal)
        setContentHuggingPriority(.required, for: .vertical)
        setContentCompressionResistancePriority(.required, for: .horizontal)
    }

    private func initialRender() {
        for part in data.allParts {
            let charView = createCharacterView(for: part)
            characters[part.key] = charView
            stackView.addArrangedSubview(charView)
        }
        updateAccessibilityLabel()
    }

    private func rebuildCharacters() {
        for charView in characters.values {
            stackView.removeArrangedSubview(charView)
            charView.removeFromSuperview()
        }
        characters.removeAll()
        initialRender()
        invalidateIntrinsicContentSize()
    }

    private func updateValue(from oldData: NumberFlowData, to newData: NumberFlowData) {
        let oldKeys = Set(oldData.allParts.map(\.key))
        let newKeys = Set(newData.allParts.map(\.key))

        let removedKeys = oldKeys.subtracting(newKeys)
        let addedKeys = newKeys.subtracting(oldKeys)
        let existingKeys = oldKeys.intersection(newKeys)

        let direction = trend.value(from: oldData.numericValue, to: newData.numericValue)
        let shouldAnimate = animation.shouldAnimate

        if shouldAnimate {
            var initialFrames: [NumberPartKey: CGRect] = [:]
            for (key, charView) in characters {
                charView.layoutIfNeeded()
                initialFrames[key] = charView.frame
            }

            handleRemovedCharacters(removedKeys)
            handleAddedCharacters(newData, addedKeys)
            handleExistingCharacters(newData, existingKeys, direction: direction)
            reorderCharacters(newData)

            setNeedsLayout()
            layoutIfNeeded()

            for (key, charView) in characters {
                if let initialFrame = initialFrames[key] {
                    let finalFrame = charView.frame
                    let dx = initialFrame.minX - finalFrame.minX
                    let dy = initialFrame.minY - finalFrame.minY

                    if abs(dx) > 0.1 || abs(dy) > 0.1 {
                        charView.transform = CGAffineTransform(translationX: dx, y: dy)
                        animateTransformToIdentity(charView)
                    }
                } else if addedKeys.contains(key) {
                    let finalFrame = charView.frame
                    let offsetY = -CGFloat(direction) * finalFrame.height

                    charView.alpha = 0
                    charView.transform = CGAffineTransform(translationX: 0, y: offsetY)

                    animateTransformToIdentity(charView)
                    charView.fadeIn(duration: animation.opacityDuration)
                }
            }
        } else {
            handleRemovedCharacters(removedKeys)
            handleAddedCharacters(newData, addedKeys)
            handleExistingCharacters(newData, existingKeys, direction: direction)
            reorderCharacters(newData)
        }

        invalidateIntrinsicContentSize()
        updateAccessibilityLabel()
    }

    private func animateTransformToIdentity(_ view: UIView) {
        let timing: UITimingCurveProvider
        switch animation.timingCurve {
        case .spring:
            timing = UISpringTimingParameters(
                dampingRatio: animation.transformDampingRatio,
                initialVelocity: CGVector(dx: 0, dy: 0)
            )
        case .smooth:
            timing = UICubicTimingParameters(animationCurve: .easeOut)
        }

        let animator = UIViewPropertyAnimator(
            duration: animation.transformDuration,
            timingParameters: timing
        )

        animator.addAnimations {
            view.transform = .identity
        }

        animator.startAnimation()
    }

    private func handleRemovedCharacters(_ keys: Set<NumberPartKey>) {
        for key in keys {
            guard let charView = characters[key] else { continue }
            stackView.removeArrangedSubview(charView)
            charView.removeFromSuperview()
            characters.removeValue(forKey: key)
        }
    }

    private func handleAddedCharacters(_ newData: NumberFlowData, _ keys: Set<NumberPartKey>) {
        for key in keys {
            guard let part = newData.allParts.first(where: { $0.key == key }) else { continue }

            let charView = createCharacterView(for: part)
            characters[key] = charView
            stackView.addArrangedSubview(charView)
        }
    }

    private func handleExistingCharacters(
        _ newData: NumberFlowData,
        _ keys: Set<NumberPartKey>,
        direction: Int
    ) {
        for key in keys {
            guard let charView = characters[key],
                let newPart = newData.allParts.first(where: { $0.key == key })
            else { continue }

            if case .digit(let digitView) = charView.content,
                case .digit(let newDigitPart) = newPart
            {
                digitView.setDigit(newDigitPart.value, direction: direction, animation: animation)
            }
        }
    }

    private func reorderCharacters(_ newData: NumberFlowData) {
        let orderedKeys = newData.allParts.map(\.key)

        for (index, key) in orderedKeys.enumerated() {
            guard let charView = characters[key] else { continue }

            if stackView.arrangedSubviews.firstIndex(of: charView) != index {
                stackView.removeArrangedSubview(charView)
                stackView.insertArrangedSubview(charView, at: index)
            }
        }
    }

    private func createCharacterView(for part: NumberPart) -> CharacterView {
        switch part {
        case .digit(let digitPart):
            return createDigitView(for: digitPart, key: part.key)

        case .symbol(let symbolPart):
            return createSymbolView(for: symbolPart, key: part.key)
        }
    }

    private func createDigitView(for digitPart: DigitPart, key: NumberPartKey) -> CharacterView {
        let digitView = DigitColumnView()
        digitView.font = font
        digitView.textColor = colorForPartType(digitPart.type)
        digitView.setDigit(digitPart.value, direction: 0, animation: .init(isAnimated: false))
        return CharacterView(key: key, partType: digitPart.type, content: .digit(digitView))
    }

    private func createSymbolView(for symbolPart: SymbolPart, key: NumberPartKey) -> CharacterView {
        let label = makeSymbolLabel(text: symbolPart.value, type: symbolPart.type)
        if symbolPart.type == .prefix && currencySymbolScale != 1.0 {
            label.font = font.withSize(font.pointSize * currencySymbolScale)
            return CharacterView(key: key, partType: symbolPart.type, content: .currencySymbol(label, referenceFont: font))
        } else {
            label.font = font
            return CharacterView(key: key, partType: symbolPart.type, content: .symbol(label))
        }
    }

    private func makeSymbolLabel(text: String, type: NumberPartType) -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = text
        label.textColor = colorForPartType(type)
        label.textAlignment = .center
        label.adjustsFontForContentSizeCategory = false
        label.setContentCompressionResistancePriority(.required, for: .horizontal)
        label.setContentHuggingPriority(.required, for: .horizontal)
        return label
    }

    private func colorForPartType(_ type: NumberPartType) -> UIColor {
        switch type {
        case .integer:
            return textColor
        case .fraction:
            return fractionColor ?? textColor
        case .group, .decimal, .currency, .percent, .sign, .prefix, .suffix, .literal:
            return symbolColor ?? textColor
        }
    }

    private func updateFont() {
        for charView in characters.values {
            switch charView.content {
            case .digit(let digitView):
                digitView.font = font
            case .symbol(let label):
                label.font = font
            case .currencySymbol(let label, _):
                label.font = font.withSize(font.pointSize * currencySymbolScale)
            }
        }
        invalidateIntrinsicContentSize()
    }

    private func updateTextColor() {
        for charView in characters.values {
            let color = colorForPartType(charView.partType)
            switch charView.content {
            case .digit(let digitView):
                digitView.textColor = color
            case .symbol(let label):
                label.textColor = color
            case .currencySymbol(let label, _):
                label.textColor = color
            }
        }
    }

    private func updateAccessibilityLabel() {
        accessibilityLabel = data.valueAsString
    }

    public override var intrinsicContentSize: CGSize {
        stackView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
    }
}
