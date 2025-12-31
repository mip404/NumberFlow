#if canImport(SwiftUI)
    import SwiftUI
    import UIKit

    extension UIFont {
        static func roundedSystemFont(ofSize size: CGFloat, weight: UIFont.Weight) -> UIFont {
            let descriptor = UIFont.systemFont(ofSize: size, weight: weight).fontDescriptor
                .withDesign(.rounded)!
                .addingAttributes([
                    .featureSettings: [
                        [
                            UIFontDescriptor.FeatureKey.type: kNumberSpacingType,
                            UIFontDescriptor.FeatureKey.selector: kMonospacedNumbersSelector,
                        ]
                    ]
                ])
            return UIFont(descriptor: descriptor, size: size)
        }
    }

    public struct NumberFlowView: UIViewRepresentable {
        public typealias UIViewType = NumberFlowUIView

        private let value: Double
        private let format: NumberFlowFormat
        private let animation: NumberFlowAnimation
        private let trend: NumberFlowTrend
        private let font: UIFont
        private let textColor: UIColor
        private let symbolColor: UIColor?
        private let fractionColor: UIColor?
        private let currencySymbolScale: CGFloat

        public init(
            value: Double,
            format: NumberFlowFormat = .default,
            animation: NumberFlowAnimation = .default,
            trend: NumberFlowTrend = .default,
            font: UIFont = .monospacedDigitSystemFont(ofSize: 17, weight: .regular),
            textColor: UIColor = .label,
            symbolColor: UIColor? = nil,
            fractionColor: UIColor? = nil,
            currencySymbolScale: CGFloat = 1.0
        ) {
            self.value = value
            self.format = format
            self.animation = animation
            self.trend = trend
            self.font = font
            self.textColor = textColor
            self.symbolColor = symbolColor
            self.fractionColor = fractionColor
            self.currencySymbolScale = currencySymbolScale
        }

        public func makeUIView(context: Context) -> NumberFlowUIView {
            let formatter = NumberFlowFormatter(
                locale: format.locale,
                style: format.style,
                minimumFractionDigits: format.minimumFractionDigits,
                maximumFractionDigits: format.maximumFractionDigits,
                currencyCode: format.currencyCode
            )

            let data = formatter.data(for: .double(value))
            let view = NumberFlowUIView(data: data)
            view.animation = animation
            view.trend = trend
            view.font = font
            view.textColor = textColor
            view.symbolColor = symbolColor
            view.fractionColor = fractionColor
            view.currencySymbolScale = currencySymbolScale

            return view
        }

        public func updateUIView(_ uiView: NumberFlowUIView, context: Context) {
            let formatter = NumberFlowFormatter(
                locale: format.locale,
                style: format.style,
                minimumFractionDigits: format.minimumFractionDigits,
                maximumFractionDigits: format.maximumFractionDigits,
                currencyCode: format.currencyCode
            )

            uiView.animation = animation
            uiView.trend = trend
            uiView.font = font
            uiView.textColor = textColor
            uiView.symbolColor = symbolColor
            uiView.fractionColor = fractionColor
            uiView.currencySymbolScale = currencySymbolScale
            uiView.data = formatter.data(for: .double(value))
        }
    }

    extension NumberFlowView {
        public func animation(_ animation: NumberFlowAnimation) -> NumberFlowView {
            NumberFlowView(
                value: value,
                format: format,
                animation: animation,
                trend: trend,
                font: font,
                textColor: textColor,
                symbolColor: symbolColor,
                fractionColor: fractionColor,
                currencySymbolScale: currencySymbolScale
            )
        }

        public func trend(_ trend: NumberFlowTrend) -> NumberFlowView {
            NumberFlowView(
                value: value,
                format: format,
                animation: animation,
                trend: trend,
                font: font,
                textColor: textColor,
                symbolColor: symbolColor,
                fractionColor: fractionColor,
                currencySymbolScale: currencySymbolScale
            )
        }

        public func font(_ font: UIFont) -> NumberFlowView {
            NumberFlowView(
                value: value,
                format: format,
                animation: animation,
                trend: trend,
                font: font,
                textColor: textColor,
                symbolColor: symbolColor,
                fractionColor: fractionColor,
                currencySymbolScale: currencySymbolScale
            )
        }

        public func foregroundColor(_ color: UIColor) -> NumberFlowView {
            NumberFlowView(
                value: value,
                format: format,
                animation: animation,
                trend: trend,
                font: font,
                textColor: color,
                symbolColor: symbolColor,
                fractionColor: fractionColor,
                currencySymbolScale: currencySymbolScale
            )
        }

        public func symbolColor(_ color: UIColor?) -> NumberFlowView {
            NumberFlowView(
                value: value,
                format: format,
                animation: animation,
                trend: trend,
                font: font,
                textColor: textColor,
                symbolColor: color,
                fractionColor: fractionColor,
                currencySymbolScale: currencySymbolScale
            )
        }

        public func fractionColor(_ color: UIColor?) -> NumberFlowView {
            NumberFlowView(
                value: value,
                format: format,
                animation: animation,
                trend: trend,
                font: font,
                textColor: textColor,
                symbolColor: symbolColor,
                fractionColor: color,
                currencySymbolScale: currencySymbolScale
            )
        }

        public func currencySymbolScale(_ scale: CGFloat) -> NumberFlowView {
            NumberFlowView(
                value: value,
                format: format,
                animation: animation,
                trend: trend,
                font: font,
                textColor: textColor,
                symbolColor: symbolColor,
                fractionColor: fractionColor,
                currencySymbolScale: scale
            )
        }
    }

    #Preview("Basic") {
        BasicPreview()
    }

    private struct BasicPreview: View {
        @State private var value1: Double = 42
        @State private var value2: Double = 1234.56
        @State private var value3: Double = 987654.321

        var body: some View {
            VStack(spacing: 48) {
                VStack(spacing: 12) {
                    NumberFlowView(
                        value: value1,
                        font: .roundedSystemFont(ofSize: 56, weight: .medium)
                    )

                    HStack(spacing: 12) {
                        Button("Random") { value1 = Double.random(in: 0...999) }
                            .buttonStyle(.bordered)
                        Button("+10") { value1 += 10 }
                            .buttonStyle(.bordered)
                        Button("-10") { value1 = max(0, value1 - 10) }
                            .buttonStyle(.bordered)
                    }
                }

                VStack(spacing: 12) {
                    NumberFlowView(
                        value: value2,
                        format: .currency(code: "USD"),
                        font: .roundedSystemFont(ofSize: 48, weight: .semibold)
                    )

                    HStack(spacing: 12) {
                        Button("Random") { value2 = Double.random(in: 0...9999) }
                            .buttonStyle(.bordered)
                        Button("+100") { value2 += 100 }
                            .buttonStyle(.bordered)
                        Button("-100") { value2 = max(0, value2 - 100) }
                            .buttonStyle(.bordered)
                    }
                }

                VStack(spacing: 12) {
                    NumberFlowView(
                        value: value3,
                        format: NumberFlowFormat(
                            style: .decimal,
                            minimumFractionDigits: 2,
                            maximumFractionDigits: 3
                        ),
                        font: .roundedSystemFont(ofSize: 40, weight: .regular)
                    )

                    HStack(spacing: 12) {
                        Button("Random") { value3 = Double.random(in: 0...999_999_999) }
                            .buttonStyle(.bordered)
                        Button("+1K") { value3 += 1000 }
                            .buttonStyle(.bordered)
                        Button("-1K") { value3 = max(0, value3 - 1000) }
                            .buttonStyle(.bordered)
                    }
                }
            }
            .padding()
        }
    }

    #Preview("Animated Counter") {
        AnimatedCounterPreview()
    }

    private struct AnimatedCounterPreview: View {
        @State private var value: Double = 0

        var body: some View {
            VStack(spacing: 40) {
                NumberFlowView(
                    value: value,
                    format: .currency(code: "USD"),
                    animation: .default,
                    font: .roundedSystemFont(ofSize: 56, weight: .bold)
                )

                VStack(spacing: 16) {
                    HStack(spacing: 16) {
                        Button("Random") {
                            value = Double.random(in: 0...9999)
                        }
                        .buttonStyle(.borderedProminent)

                        Button("Reset") {
                            value = 0
                        }
                        .buttonStyle(.bordered)
                    }

                    HStack(spacing: 16) {
                        Button("+1000") {
                            value += 1000
                        }
                        .buttonStyle(.bordered)

                        Button("+100") {
                            value += 100
                        }
                        .buttonStyle(.bordered)

                        Button("-100") {
                            value = max(0, value - 100)
                        }
                        .buttonStyle(.bordered)

                        Button("-1000") {
                            value = max(0, value - 1000)
                        }
                        .buttonStyle(.bordered)
                    }
                }
            }
            .padding()
        }
    }

    #Preview("Trend Variants") {
        TrendVariantsPreview()
    }

    private struct TrendVariantsPreview: View {
        @State private var value: Double = 500

        var body: some View {
            VStack(spacing: 40) {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Auto (default)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    NumberFlowView(
                        value: value,
                        trend: .auto,
                        font: .roundedSystemFont(ofSize: 48, weight: .semibold)
                    )
                }

                VStack(alignment: .leading, spacing: 12) {
                    Text("Always Up")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    NumberFlowView(
                        value: value,
                        trend: .up,
                        font: .roundedSystemFont(ofSize: 48, weight: .semibold)
                    )
                }

                VStack(alignment: .leading, spacing: 12) {
                    Text("Always Down")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    NumberFlowView(
                        value: value,
                        trend: .down,
                        font: .roundedSystemFont(ofSize: 48, weight: .semibold)
                    )
                }

                HStack(spacing: 16) {
                    Button("Random") {
                        value = Double.random(in: 0...999)
                    }
                    .buttonStyle(.borderedProminent)

                    Button("+50") {
                        value += 50
                    }
                    .buttonStyle(.bordered)

                    Button("-50") {
                        value = max(0, value - 50)
                    }
                    .buttonStyle(.bordered)
                }
            }
            .padding()
        }
    }

    #Preview("Dark Mode") {
        DarkModePreview()
    }

    private struct DarkModePreview: View {
        @State private var value: Double = 1234.56

        var body: some View {
            VStack(spacing: 40) {
                NumberFlowView(
                    value: value,
                    format: .currency(code: "USD"),
                    font: .roundedSystemFont(ofSize: 56, weight: .bold),
                    textColor: .white
                )

                HStack(spacing: 16) {
                    Button("Random") {
                        value = Double.random(in: 0...9999)
                    }
                    .buttonStyle(.bordered)

                    Button("+250") {
                        value += 250
                    }
                    .buttonStyle(.bordered)

                    Button("-250") {
                        value = max(0, value - 250)
                    }
                    .buttonStyle(.bordered)
                }
                .tint(.white)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.black)
            .environment(\.colorScheme, .dark)
        }
    }

    #Preview("Custom Styling") {
        CustomStylingPreview()
    }

    private struct CustomStylingPreview: View {
        @State private var value1: Double = 98765.43
        @State private var value2: Double = 42

        var body: some View {
            VStack(spacing: 48) {
                VStack(spacing: 16) {
                    NumberFlowView(
                        value: value1,
                        format: NumberFlowFormat(
                            style: .decimal,
                            minimumFractionDigits: 2,
                            maximumFractionDigits: 2
                        )
                    )
                    .font(.system(size: 56, weight: .black, design: .rounded))
                    .foregroundColor(.purple)

                    HStack(spacing: 12) {
                        Button("Random") { value1 = Double.random(in: 0...99999) }
                            .buttonStyle(.bordered)
                        Button("+500") { value1 += 500 }
                            .buttonStyle(.bordered)
                        Button("-500") { value1 = max(0, value1 - 500) }
                            .buttonStyle(.bordered)
                    }
                }

                VStack(spacing: 16) {
                    NumberFlowView(
                        value: value2,
                        animation: .fast,
                        font: .roundedSystemFont(ofSize: 72, weight: .ultraLight),
                        textColor: .blue
                    )

                    HStack(spacing: 12) {
                        Button("Random") { value2 = Double.random(in: 0...999) }
                            .buttonStyle(.bordered)
                        Button("+5") { value2 += 5 }
                            .buttonStyle(.bordered)
                        Button("-5") { value2 = max(0, value2 - 5) }
                            .buttonStyle(.bordered)
                    }
                }
            }
            .padding()
        }
    }

    #Preview("Currency Formats") {
        CurrencyFormatsPreview()
    }

    private struct CurrencyFormatsPreview: View {
        @State private var value: Double = 1234.56

        var body: some View {
            ScrollView {
                VStack(spacing: 32) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("USD")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        NumberFlowView(
                            value: value,
                            format: .currency(code: "USD"),
                            font: .roundedSystemFont(ofSize: 48, weight: .semibold),
                            currencySymbolScale: 0.65
                        )
                    }

                    Divider()

                    VStack(alignment: .leading, spacing: 8) {
                        Text("EUR")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        NumberFlowView(
                            value: value,
                            format: .currency(code: "EUR"),
                            font: .roundedSystemFont(ofSize: 48, weight: .semibold),
                            currencySymbolScale: 1
                        )
                    }

                    Divider()

                    VStack(alignment: .leading, spacing: 8) {
                        Text("INR")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        NumberFlowView(
                            value: value,
                            format: .currency(code: "INR"),
                            font: .roundedSystemFont(ofSize: 48, weight: .semibold),
                            currencySymbolScale: 0.65
                        )
                    }

                    Divider()

                    HStack(spacing: 16) {
                        Button("Random") {
                            value = Double.random(in: 0...9999)
                        }
                        .buttonStyle(.borderedProminent)

                        Button("+100") {
                            value += 100
                        }
                        .buttonStyle(.bordered)

                        Button("-100") {
                            value = max(0, value - 100)
                        }
                        .buttonStyle(.bordered)
                    }
                }
                .padding()
            }
        }
    }

    #Preview("Timing Curves") {
        TimingCurvesPreview()
    }

    private struct TimingCurvesPreview: View {
        @State private var value: Double = 1234.56

        var body: some View {
            VStack(spacing: 40) {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Spring (default)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    NumberFlowView(
                        value: value,
                        format: .currency(code: "USD"),
                        animation: .default,
                        font: .roundedSystemFont(ofSize: 48, weight: .semibold)
                    )
                }

                VStack(alignment: .leading, spacing: 12) {
                    Text("Smooth (no spring)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    NumberFlowView(
                        value: value,
                        format: .currency(code: "USD"),
                        animation: NumberFlowAnimation(timingCurve: .smooth),
                        font: .roundedSystemFont(ofSize: 48, weight: .semibold)
                    )
                }

                HStack(spacing: 16) {
                    Button("Random") {
                        value = Double.random(in: 0...9999)
                    }
                    .buttonStyle(.borderedProminent)

                    Button("+100") {
                        value += 100
                    }
                    .buttonStyle(.bordered)

                    Button("-100") {
                        value = max(0, value - 100)
                    }
                    .buttonStyle(.bordered)
                }
            }
            .padding()
        }
    }

    #Preview("Secondary Colors") {
        SecondaryColorsPreview()
    }

    private struct SecondaryColorsPreview: View {
        @State private var value: Double = 1234.56

        var body: some View {
            VStack(spacing: 40) {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Default (all same color)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    NumberFlowView(
                        value: value,
                        format: .currency(code: "USD"),
                        font: .roundedSystemFont(ofSize: 48, weight: .semibold)
                    )
                }

                VStack(alignment: .leading, spacing: 12) {
                    Text("With secondary symbol & fraction")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    NumberFlowView(
                        value: value,
                        format: .currency(code: "USD"),
                        font: .roundedSystemFont(ofSize: 48, weight: .semibold)
                    )
                    .symbolColor(.secondaryLabel)
                    .fractionColor(.secondaryLabel)
                }

                VStack(alignment: .leading, spacing: 12) {
                    Text("Tertiary symbol & fraction")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    NumberFlowView(
                        value: value,
                        format: .currency(code: "USD"),
                        font: .roundedSystemFont(ofSize: 48, weight: .semibold)
                    )
                    .symbolColor(.tertiaryLabel)
                    .fractionColor(.tertiaryLabel)
                }

                HStack(spacing: 16) {
                    Button("Random") {
                        value = Double.random(in: 0...9999)
                    }
                    .buttonStyle(.borderedProminent)

                    Button("+100") {
                        value += 100
                    }
                    .buttonStyle(.bordered)

                    Button("-100") {
                        value = max(0, value - 100)
                    }
                    .buttonStyle(.bordered)
                }
            }
            .padding()
        }
    }

#endif
