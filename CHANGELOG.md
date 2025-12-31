# Changelog

## 0.1.0

### Added

- `TimingCurve` enum with `.spring` (default) and `.smooth` options for controlling animation style
- `timingCurve` property on `NumberFlowAnimation` to switch between spring and ease-out animations
- `symbolColor` property for styling currency symbols, decimal points, group separators, and other symbols
- `fractionColor` property for styling digits after the decimal point
- SwiftUI modifiers: `.symbolColor(_:)` and `.fractionColor(_:)`

### Changed

- Both `symbolColor` and `fractionColor` are optional and fall back to `textColor` when nil
