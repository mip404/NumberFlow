# NumberFlow

An animated number counter component for iOS 17+, inspired by [number-flow](https://github.com/barvian/number-flow).

## Features

- Smooth digit scrolling animations
- Fade transitions for appearing/disappearing characters
- Layout animations when number width changes
- Full number formatting support (currency, percent, decimal)
- Customizable fonts and colors
- VoiceOver support
- Respects reduced motion preferences
- Pure Swift, zero dependencies

## Requirements

- iOS 17.0+
- Swift 6.0+
- Xcode 16.0+

## Installation

Add this package via Swift Package Manager:

```swift
dependencies: [
    .package(url: "https://github.com/user/NumberFlow", from: "1.0.0")
]
```

## Usage

### SwiftUI

```swift
import SwiftUI
import NumberFlow

struct ContentView: View {
    @State private var value: Double = 1234.56

    var body: some View {
        NumberFlowView(value: value)
    }
}
```

### UIKit

```swift
import UIKit
import NumberFlow

class ViewController: UIViewController {
    private var numberView: NumberFlowUIView!
    private let formatter = NumberFlowFormatter(style: .currency, currencyCode: "USD")

    override func viewDidLoad() {
        super.viewDidLoad()

        let data = formatter.data(for: .double(1234.56))
        numberView = NumberFlowUIView(data: data)
        numberView.font = .monospacedDigitSystemFont(ofSize: 32, weight: .bold)
        view.addSubview(numberView)
    }

    func updateValue(_ newValue: Double) {
        numberView.data = formatter.data(for: .double(newValue))
    }
}
```

## Configuration

### Formatting

```swift
// Currency
NumberFlowView(value: 1234.56, format: .currency(code: "USD"))

// Percent
NumberFlowView(value: 0.42, format: .percent())

// Custom decimal places
NumberFlowView(
    value: 123.456,
    format: NumberFlowFormat(
        style: .decimal,
        minimumFractionDigits: 2,
        maximumFractionDigits: 4
    )
)
```

### Animation

```swift
// Presets
NumberFlowView(value: value, animation: .default)
NumberFlowView(value: value, animation: .fast)
NumberFlowView(value: value, animation: .slow)

// Custom
NumberFlowView(
    value: value,
    animation: NumberFlowAnimation(
        transformDuration: 1.2,
        transformDampingRatio: 0.75,
        opacityDuration: 0.5
    )
)

// Disabled
NumberFlowView(value: value, animation: NumberFlowAnimation(isAnimated: false))
```

### Trend

Controls the direction digits scroll when changing.

```swift
// Auto-detect based on value change (default)
NumberFlowView(value: value, trend: .auto)

// Always scroll up or down
NumberFlowView(value: value, trend: .up)
NumberFlowView(value: value, trend: .down)
```

### Styling

The view uses `UIFont` and `UIColor` for styling:

```swift
NumberFlowView(
    value: value,
    font: .monospacedDigitSystemFont(ofSize: 48, weight: .bold),
    textColor: .systemBlue
)
```

Or use the modifier syntax:

```swift
NumberFlowView(value: value)
    .font(.monospacedDigitSystemFont(ofSize: 48, weight: .bold))
    .foregroundColor(.systemBlue)
```

## Credits

Inspired by [number-flow](https://number-flow.barvian.me/) by Maxwell Barvian.
