NumberFlow for iOS

A smooth, animated number counter component for iOS 17+, inspired by [number-flow](https://github.com/barvian/number-flow).

Features

- Smooth spring-based digit animations
- Fade in/out transitions for appearing/disappearing characters
- Smart layout animations when number width changes
- Fully customizable fonts and colors
- Accessible with proper VoiceOver support
- Respects reduced motion preferences
- Full number formatting support (currency, percent, decimal)
- Pure Swift, no dependencies

Installation

Add this package as a dependency in your Swift Package Manager:

dependencies: [
    .package(url: "your-repo-url", from: "1.0.0")
]


Basic Usage

SwiftUI

import SwiftUI
import NumberFlow

struct ContentView: View {
    @State private var value: Double = 1234.56
    
    var body: some View {
        NumberFlowView(value: value)
            .font(.monospacedDigitSystemFont(ofSize: 32, weight: .bold))
    }
}


UIKit

import UIKit
import NumberFlow

class ViewController: UIViewController {
    let numberView: NumberFlowUIView
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let formatter = NumberFlowFormatter(
            style: .currency,
            currencyCode: "USD"
        )
        let data = formatter.data(for: .double(1234.56))
        
        numberView = NumberFlowUIView(data: data)
        numberView.font = .monospacedDigitSystemFont(ofSize: 32, weight: .bold)
        
        view.addSubview(numberView)
    }
    
    func updateValue(_ newValue: Double) {
        let formatter = NumberFlowFormatter(
            style: .currency,
            currencyCode: "USD"
        )
        numberView.data = formatter.data(for: .double(newValue))
    }
}


Configuration

Formatting

// Currency
NumberFlowView(
    value: 1234.56,
    format: .currency(code: "USD")
)

// Percent
NumberFlowView(
    value: 0.42,
    format: .percent()
)

// Custom decimal places
NumberFlowView(
    value: 123.456789,
    format: NumberFlowFormat(
        style: .decimal,
        minimumFractionDigits: 2,
        maximumFractionDigits: 4
    )
)


Animation

// Default animation (smooth spring)
NumberFlowView(value: value)
    .animation(.default)

// Fast animation
NumberFlowView(value: value)
    .animation(.fast)

// Custom animation
NumberFlowView(value: value)
    .animation(NumberFlowAnimation(
        transformDuration: 1.2,
        transformDampingRatio: 0.75,
        opacityDuration: 0.5
    ))

// Disable animation
NumberFlowView(value: value)
    .animation(NumberFlowAnimation(isAnimated: false))


Trend (Animation Direction)

// Auto (default) - digits animate based on increase/decrease
NumberFlowView(value: value)
    .trend(.auto)

// Always animate up
NumberFlowView(value: value)
    .trend(.up)

// Always animate down
NumberFlowView(value: value)
    .trend(.down)

// Custom trend calculation
NumberFlowView(value: value)
    .trend(.custom { oldValue, newValue in
        // Return 1 for up, -1 for down, 0 for neutral
        return oldValue < newValue ? 1 : -1
    })


Styling

NumberFlowView(value: value)
    .font(.monospacedDigitSystemFont(ofSize: 48, weight: .bold))
    .foregroundColor(.blue)

Examples

See NumberFlowView.swift for extensive SwiftUI previews including:
- Basic counters
- Currency formatting
- Animated transitions
- Trend variants
- Dark mode support
- Custom styling

License

MIT License - See LICENSE file for details

Credits

Inspired by NumberFlow for React by Maxwell Barvian
