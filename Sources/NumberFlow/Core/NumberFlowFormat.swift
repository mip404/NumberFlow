import Foundation

public struct NumberFlowFormat: Equatable, Sendable {
    public var locale: Locale
    public var style: NumberFormatter.Style
    public var currencyCode: String?
    public var minimumFractionDigits: Int?
    public var maximumFractionDigits: Int?
    public var prefix: String?
    public var suffix: String?
    
    public init(
        locale: Locale = .current,
        style: NumberFormatter.Style = .decimal,
        currencyCode: String? = nil,
        minimumFractionDigits: Int? = nil,
        maximumFractionDigits: Int? = nil,
        prefix: String? = nil,
        suffix: String? = nil
    ) {
        self.locale = locale
        self.style = style
        self.currencyCode = currencyCode
        self.minimumFractionDigits = minimumFractionDigits
        self.maximumFractionDigits = maximumFractionDigits
        self.prefix = prefix
        self.suffix = suffix
    }
}

extension NumberFlowFormat {
    public static var `default`: NumberFlowFormat {
        NumberFlowFormat()
    }
    
    public static func currency(
        code: String,
        locale: Locale = .current,
        minimumFractionDigits: Int? = 2,
        maximumFractionDigits: Int? = 2,
        prefix: String? = nil,
        suffix: String? = nil
    ) -> NumberFlowFormat {
        NumberFlowFormat(
            locale: locale,
            style: .currency,
            currencyCode: code,
            minimumFractionDigits: minimumFractionDigits,
            maximumFractionDigits: maximumFractionDigits,
            prefix: prefix,
            suffix: suffix
        )
    }
    
    public static func percent(
        locale: Locale = .current,
        minimumFractionDigits: Int? = 0,
        maximumFractionDigits: Int? = 2
    ) -> NumberFlowFormat {
        NumberFlowFormat(
            locale: locale,
            style: .percent,
            minimumFractionDigits: minimumFractionDigits,
            maximumFractionDigits: maximumFractionDigits
        )
    }
}
