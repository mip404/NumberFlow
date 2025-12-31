# NumberFlow

An animated number counter component for iOS 17+

<table>
  <tr>
    <td><img src="https://github.com/user-attachments/assets/5c2d7064-6840-498d-96d4-65751ea96a80" width="250"></td>
    <td><img src="https://github.com/user-attachments/assets/839b88a1-df94-43df-b46c-b014fc3005a6" width="250"></td>
    <td><img src="https://github.com/user-attachments/assets/7cd2185e-6cf8-408f-a204-aa5151b978e2" width="250"></td>
  </tr>
</table>


## Features

- Smooth digit scrolling animations
- Fade transitions for appearing/disappearing characters
- Layout animations when number width changes
- Full number formatting support (currency, percent, decimal)
- Customizable fonts and colors
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
    .package(url: "https://github.com/mip404/NumberFlow", from: "1.0.0")
]
```

## Usage

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
