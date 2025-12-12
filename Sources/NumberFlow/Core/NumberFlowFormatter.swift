import Foundation

public struct NumberFlowFormatter {
    private let formatter: NumberFormatter

    public init(
        locale: Locale = .current,
        style: NumberFormatter.Style = .decimal,
        minimumFractionDigits: Int? = nil,
        maximumFractionDigits: Int? = nil,
        currencyCode: String? = nil
    ) {
        let f = NumberFormatter()
        f.locale = locale
        f.numberStyle = style

        if let currencyCode {
            f.currencyCode = currencyCode
        }

        if let min = minimumFractionDigits {
            f.minimumFractionDigits = min
        }

        if let max = maximumFractionDigits {
            f.maximumFractionDigits = max
        }

        self.formatter = f
    }

    public func data(for value: NumberFlowValue) -> NumberFlowData {
        let numeric = value.numeric
        let formatted = formatter.string(from: NSNumber(value: numeric)) ?? String(numeric)

        let decimalSeparator = formatter.decimalSeparator ?? "."
        let groupingSeparator = formatter.groupingSeparator ?? ","

        var prefixParts: [NumberPart] = []
        var suffixParts: [NumberPart] = []

        enum Raw {
            case digit(Int)
            case symbol(NumberPartType, String)
        }

        var integerRaw: [Raw] = []
        var fractionRaw: [Raw] = []

        var seenInteger = false
        var seenDecimal = false

        var counts: [NumberPartType: Int] = [:]
        func key(_ type: NumberPartType) -> NumberPartKey {
            let index = counts[type, default: 0]
            counts[type] = index + 1
            return NumberPartKey("\(type):\(index)")
        }

        let chars = Array(formatted)

        for char in chars {
            let s = String(char)

            if char.isNumber {
                let digit = Int(String(char))!
                if seenDecimal {
                    fractionRaw.append(.digit(digit))
                } else {
                    integerRaw.append(.digit(digit))
                }
                seenInteger = true
                continue
            }

            if s == decimalSeparator {
                seenDecimal = true
                fractionRaw.append(.symbol(.decimal, s))
                continue
            }

            if s == groupingSeparator {
                integerRaw.append(.symbol(.group, s))
                continue
            }

            if s == "-" || s == "+" {
                let symbol = SymbolPart(type: .sign, value: s, key: key(.sign))
                if !seenInteger && !seenDecimal {
                    prefixParts.append(.symbol(symbol))
                } else {
                    suffixParts.append(.symbol(symbol))
                }
                continue
            }

            if !seenInteger && !seenDecimal {
                let symbol = SymbolPart(type: .prefix, value: s, key: key(.prefix))
                prefixParts.append(.symbol(symbol))
            } else {
                let symbol = SymbolPart(type: .suffix, value: s, key: key(.suffix))
                suffixParts.append(.symbol(symbol))
            }
        }

        var integerParts: [NumberPart] = []
        var fractionParts: [NumberPart] = []

        var nextIntegerPos = 0
        for index in stride(from: integerRaw.count - 1, through: 0, by: -1) {
            switch integerRaw[index] {
            case .digit(let d):
                let pos = nextIntegerPos
                nextIntegerPos += 1
                let digit = DigitPart(
                    type: .integer,
                    value: d,
                    position: pos,
                    key: key(.integer)
                )
                integerParts.insert(.digit(digit), at: 0)
            case .symbol(let type, let value):
                let symbol = SymbolPart(type: type, value: value, key: key(type))
                integerParts.insert(.symbol(symbol), at: 0)
            }
        }

        var nextFractionPos = -1
        for raw in fractionRaw {
            switch raw {
            case .digit(let d):
                let pos = nextFractionPos
                nextFractionPos -= 1
                let digit = DigitPart(
                    type: .fraction,
                    value: d,
                    position: pos,
                    key: key(.fraction)
                )
                fractionParts.append(.digit(digit))
            case .symbol(let type, let value):
                let symbol = SymbolPart(type: type, value: value, key: key(type))
                fractionParts.append(.symbol(symbol))
            }
        }

        return NumberFlowData(
            prefix: prefixParts,
            integer: integerParts,
            fraction: fractionParts,
            suffix: suffixParts,
            valueAsString: formatted,
            numericValue: numeric
        )
    }
}
