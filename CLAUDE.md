# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**my-life-my-weight** is an iOS application built with SwiftUI and Swift 5.0, targeting iOS 26.0+. This is a personal weight tracking application with a clean, minimal architecture.

## Project Structure

```
my-life-my-weight/
├── my-life-my-weight/              # Main app target
│   ├── my_life_my_weightApp.swift  # App entry point
│   ├── ContentView.swift           # Main UI view with tab navigation
│   ├── WeightInputView.swift       # Weight input screen with date picker
│   ├── WeightHistoryView.swift     # Weight history list view
│   ├── WeightGraphView.swift       # Weight graph visualization
│   ├── WeightEditView.swift        # Edit existing weight entries
│   ├── SettingsView.swift          # App settings and data management
│   ├── WeightEntry.swift           # Weight entry data model
│   ├── WeightStore.swift           # Data persistence layer
│   └── Assets.xcassets/            # App icons and colors
├── my-life-my-weightTests/         # Unit tests (Swift Testing)
└── my-life-my-weightUITests/       # UI tests (XCTest)
    ├── my_life_my_weightUITests.swift
    ├── WeightInputUITests.swift
    ├── WeightHistoryUITests.swift
    └── DataImportUITests.swift
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
- **Testing Framework**:
  - Unit tests: Swift Testing framework (not XCTest)
  - UI tests: XCTest framework
- **Data Model**: `WeightEntry` struct with date normalization (stores only date, not time)
- **Data Persistence**: `WeightStore` uses UserDefaults with JSON encoding for local storage
- **UI Architecture**: Tab-based navigation with four main tabs:
  - 記録 (Record): Weight input with custom date picker
  - 履歴 (History): List view of weight entries
  - グラフ (Graph): Weight visualization with Charts framework
  - 設定 (Settings): Data import/export and app settings
- **Data Flow**: Uses `@StateObject` and `@EnvironmentObject` for state management
- **Date Handling**: Enforces one entry per day using `Calendar.current.startOfDay`
- **Localization**: Japanese locale (ja_JP) for date pickers and formatting
- **Bundle Identifier**: `jp.ttm.my-life-my-weight`
- **Development Team**: NM566LR538

### UI Components

#### WeightInputView
- Custom date picker displayed as a button showing "yyyy年M月d日(曜)" format
- Date selection opens a modal sheet with graphical calendar picker
- Sheet auto-closes when a date is selected
- Custom weight picker with integer and decimal (0.1kg precision) wheels
- Weight range: 30.0kg - 200.0kg
- Supports initialDate and initialWeight parameters for external initialization
- Accessibility identifiers: "DateButton" for date button, "DatePickerSheet" for modal

#### DatePickerSheet
- Modal sheet with graphical date picker (.graphical style)
- Japanese locale support
- Auto-dismiss on date selection via onChange modifier
- Cancel button for dismissal without selection
- Medium presentation detent

#### WeightPickerView
- Dual picker wheel design (integer + decimal)
- Visual styling with rounded background and shadow
- Real-time weight validation

#### WeightHistoryView
- List-based display of weight entries
- Swipe-to-delete functionality
- Navigation to edit view for existing entries
- Empty state messaging

#### WeightGraphView
- Chart visualization using Swift Charts
- Period selection (1 month, 3 months, 6 months, 1 year)
- Dynamic data filtering based on selected period

### Date Input UI Implementation

The date input uses a custom button-based interface instead of the standard compact DatePicker:

1. **Date Display Button**: Shows formatted date with weekday in parentheses
2. **Sheet Presentation**: Tapping the button presents a modal sheet
3. **Graphical Picker**: Sheet contains a full calendar-style date picker
4. **Auto-Close Behavior**: Sheet automatically dismisses when user selects a date
5. **Cancel Option**: Users can dismiss without selecting via cancel button

This design provides better UX than compact DatePicker by:
- Showing weekday information prominently
- Using familiar calendar interface
- Auto-closing on selection (reducing taps)
- Clear visual hierarchy

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

This project uses two testing frameworks:

### Unit Tests (my-life-my-weightTests/)
Uses Swift Testing framework (not XCTest):
- Import `Testing` framework
- Use `@Test` attribute for test functions
- Use `#expect(...)` for assertions instead of XCTest assertions
- Import the main module with `@testable import my_life_my_weight`

### UI Tests (my-life-my-weightUITests/)
Uses XCTest framework:
- Import `XCTest` framework
- Test classes inherit from `XCTestCase`
- Use `XCTAssertTrue()`, `XCTAssertFalse()`, etc. for assertions
- Use `@MainActor` attribute for test functions
- Launch app with `UI-TESTING` argument for test environment

#### UI Test Best Practices for Date Input
When testing the custom date picker button:
- Look for buttons containing "年", "月", and "日" characters
- Use accessibility identifier "DateButton" for more reliable element finding
- Check for sheet presentation using `app.sheets.firstMatch`
- Look for navigation bar with title "日付を選択"
- Verify date format matches "yyyy年M月d日(曜)" pattern
- Allow sufficient wait time (1 second) for sheet animations

Example:
```swift
let dateButtons = app.buttons.allElementsBoundByIndex.filter { button in
    button.label.contains("年") && button.label.contains("月") && button.label.contains("日")
}
// Or use accessibility identifier:
let dateButton = app.buttons["DateButton"]
```

## Accessibility

The app implements accessibility features for testing and VoiceOver support:

- **DateButton**: Accessibility identifier for the date selection button in WeightInputView
- **DatePickerSheet**: Accessibility identifier for the date picker modal sheet
- All interactive elements are properly labeled for screen readers
- Button states (enabled/disabled) are clearly indicated visually and programmatically

## Common Development Patterns

### Adding a New View
1. Create SwiftUI View file in main target
2. Add to ContentView navigation if needed
3. Inject `@EnvironmentObject var weightStore: WeightStore` if data access is needed
4. Create corresponding UI test file in my-life-my-weightUITests/
5. Add unit tests in my-life-my-weightTests/ for business logic

### Modifying Date Input UI
The date input system consists of:
- Button in WeightInputView showing formatted date
- Sheet presentation controlled by `showingDatePicker` state
- DatePickerSheet component with graphical calendar
- onChange modifier that auto-dismisses sheet on selection

When modifying, ensure:
- Date format remains "yyyy年M月d日(EEEEE)" for Japanese weekday
- Accessibility identifiers are preserved for testing
- Sheet auto-close behavior is maintained
- UI tests are updated to match new behavior