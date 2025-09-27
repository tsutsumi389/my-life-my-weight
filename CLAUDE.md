# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**my-life-my-weight** is an iOS application built with SwiftUI and Swift 5.0, targeting iOS 26.0+. This is a personal weight tracking application with a clean, minimal architecture.

## Project Structure

```
my-life-my-weight/
├── my-life-my-weight/              # Main app target
│   ├── my_life_my_weightApp.swift  # App entry point
│   ├── ContentView.swift           # Main UI view
│   └── Assets.xcassets/            # App icons and colors
├── my-life-my-weightTests/         # Unit tests
└── my-life-my-weightUITests/       # UI tests
```

## Development Commands

### Building and Running
- **Build**: Use Xcode's Product → Build (⌘+B) or `xcodebuild -project my-life-my-weight.xcodeproj -scheme my-life-my-weight build`
- **Run**: Use Xcode's Product → Run (⌘+R) or run on simulator/device through Xcode

### Testing
- **Unit Tests**: Use Xcode's Product → Test (⌘+U) or `xcodebuild test -project my-life-my-weight.xcodeproj -scheme my-life-my-weight -destination 'platform=iOS Simulator,name=iPhone 15'`
- **UI Tests**: Included in the same test command above

### Code Analysis
- **Build for Analysis**: Product → Analyze (⌘+Shift+B) in Xcode
- **SwiftLint**: Not currently configured (consider adding for code style consistency)

## Architecture Notes

- **App Entry Point**: `my_life_my_weightApp.swift` contains the main `@main` App struct
- **UI Framework**: SwiftUI with iOS 26.0 deployment target
- **Testing Framework**: Uses Swift Testing framework (not XCTest)
- **Code Structure**: Simple SwiftUI app structure with ContentView as the main interface
- **Bundle Identifier**: `jp.ttm.my-life-my-weight`
- **Development Team**: NM566LR538

## Key Configuration

- **Swift Version**: 5.0
- **iOS Deployment Target**: 26.0
- **Supported Devices**: iPhone and iPad (Universal)
- **Orientation Support**: Portrait and Landscape on both iPhone and iPad
- **Preview Support**: Enabled for SwiftUI previews
- **String Catalogs**: Enabled for localization

## Development Notes

- The project uses modern Swift concurrency features (`SWIFT_APPROACHABLE_CONCURRENCY = YES`)
- Default actor isolation is set to `MainActor`
- String catalog symbol generation is enabled
- Asset symbol extensions are automatically generated
- The project is configured for automatic code signing

## Testing Framework

This project uses Swift Testing (not XCTest). Test files should:
- Import `Testing` framework
- Use `@Test` attribute for test functions
- Use `#expect(...)` for assertions instead of XCTest assertions
- Import the main module with `@testable import my_life_my_weight`