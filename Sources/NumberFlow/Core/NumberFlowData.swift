import Foundation

public enum NumberFlowValue {
    case double(Double)
    
    public var numeric: Double {
        switch self {
        case .double(let value):
            return value
        }
    }
}

public enum NumberPartType: Hashable, Sendable {
    case integer
    case fraction
    case group
    case decimal
    case currency
    case percent
    case sign
    case prefix
    case suffix
    case literal
}

public struct NumberPartKey: Hashable, Sendable, ExpressibleByStringLiteral {
    public let rawValue: String
    
    public init(_ rawValue: String) {
        self.rawValue = rawValue
    }
    
    public init(stringLiteral value: String) {
        self.rawValue = value
    }
}

public struct DigitPart: Hashable, Sendable {
    public let type: NumberPartType
    public let value: Int
    public let position: Int
    public let key: NumberPartKey
    
    public init(type: NumberPartType, value: Int, position: Int, key: NumberPartKey) {
        precondition((0...9).contains(value), "DigitPart value must be 0-9")
        precondition(type == .integer || type == .fraction, "DigitPart type must be .integer or .fraction")
        
        self.type = type
        self.value = value
        self.position = position
        self.key = key
    }
}

public struct SymbolPart: Hashable, Sendable {
    public let type: NumberPartType
    public let value: String
    public let key: NumberPartKey
    
    public init(type: NumberPartType, value: String, key: NumberPartKey) {
        self.type = type
        self.value = value
        self.key = key
    }
}

public enum NumberPart: Hashable, Sendable {
    case digit(DigitPart)
    case symbol(SymbolPart)
    
    public var key: NumberPartKey {
        switch self {
        case .digit(let digit): return digit.key
        case .symbol(let symbol): return symbol.key
        }
    }
    
    public var type: NumberPartType {
        switch self {
        case .digit(let digit): return digit.type
        case .symbol(let symbol): return symbol.type
        }
    }
}

public struct NumberFlowData: Hashable, Sendable {
    public let prefix: [NumberPart]
    public let integer: [NumberPart]
    public let fraction: [NumberPart]
    public let suffix: [NumberPart]
    public let valueAsString: String
    public let numericValue: Double
    
    public init(
        prefix: [NumberPart] = [],
        integer: [NumberPart] = [],
        fraction: [NumberPart] = [],
        suffix: [NumberPart] = [],
        valueAsString: String,
        numericValue: Double
    ) {
        self.prefix = prefix
        self.integer = integer
        self.fraction = fraction
        self.suffix = suffix
        self.valueAsString = valueAsString
        self.numericValue = numericValue
    }
}

extension NumberFlowData {
    public var allParts: [NumberPart] {
        prefix + integer + fraction + suffix
    }
    
    public var digitParts: [DigitPart] {
        allParts.compactMap { part in
            if case .digit(let digit) = part {
                return digit
            }
            return nil
        }
    }
    
    public var symbolParts: [SymbolPart] {
        allParts.compactMap { part in
            if case .symbol(let symbol) = part {
                return symbol
            }
            return nil
        }
    }
    
    public var numericParts: [NumberPart] {
        integer + fraction
    }
    
    public var isEmpty: Bool {
        allParts.isEmpty
    }
}

extension NumberFlowData: CustomStringConvertible {
    public var description: String {
        """
        NumberFlowData(value: \(numericValue), formatted: "\(valueAsString)", \
        parts: \(allParts.count))
        """
    }
}

#if DEBUG
extension NumberFlowData {
    public var debugDescription: String {
        let partsDesc = allParts.enumerated().map { index, part in
            let typeStr = "\(part.type)"
            let valueStr: String
            switch part {
            case .digit(let digit):
                valueStr = "\(digit.value) (pos: \(digit.position))"
            case .symbol(let symbol):
                valueStr = "\"\(symbol.value)\""
            }
            return "  [\(index)] \(typeStr): \(valueStr) (key: \(part.key.rawValue))"
        }.joined(separator: "\n")
        
        return """
        NumberFlowData {
          numericValue: \(numericValue)
          valueAsString: "\(valueAsString)"
          parts:
        \(partsDesc)
        }
        """
    }
}
#endif
