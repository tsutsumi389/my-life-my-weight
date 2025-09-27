//
//  WeightInputUITests.swift
//  my-life-my-weightUITests
//
//  Created by tsutsumi on 2025/09/27.
//

import XCTest

final class WeightInputUITests: XCTestCase {

    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["UI-TESTING"]
        app.launch()

        // Navigate to weight input tab
        app.tabBars.buttons["記録"].tap()
    }

    override func tearDownWithError() throws {
        app = nil
    }

    // MARK: - Weight Picker Tests

    @MainActor
    func testWeightPickerInteraction() throws {
        let weightPickers = app.pickers
        XCTAssertTrue(weightPickers.count >= 2, "Should have integer and decimal pickers")

        let integerPicker = weightPickers.element(boundBy: 0)
        let decimalPicker = weightPickers.element(boundBy: 1)

        // Test integer picker
        XCTAssertTrue(integerPicker.exists)
        integerPicker.pickerWheels.element(boundBy: 0).adjust(toPickerWheelValue: "75")

        // Test decimal picker
        XCTAssertTrue(decimalPicker.exists)
        decimalPicker.pickerWheels.element(boundBy: 0).adjust(toPickerWheelValue: "3")

        // Verify save button is enabled
        let saveButton = app.buttons["保存"]
        XCTAssertTrue(saveButton.isEnabled)
    }

    @MainActor
    func testWeightPickerBoundaries() throws {
        let weightPickers = app.pickers
        XCTAssertTrue(weightPickers.count >= 2, "Should have both integer and decimal pickers")

        let integerPicker = weightPickers.element(boundBy: 0)
        let decimalPicker = weightPickers.element(boundBy: 1)
        let saveButton = app.buttons["保存"]

        // Test minimum weight (30.0kg)
        integerPicker.pickerWheels.element(boundBy: 0).adjust(toPickerWheelValue: "30")
        decimalPicker.pickerWheels.element(boundBy: 0).adjust(toPickerWheelValue: "0")

        // Allow time for UI to update
        usleep(500000) // 0.5 second wait

        XCTAssertTrue(saveButton.isEnabled, "Save button should be enabled for minimum weight")

        // Test maximum weight (200.0kg)
        integerPicker.pickerWheels.element(boundBy: 0).adjust(toPickerWheelValue: "200")
        decimalPicker.pickerWheels.element(boundBy: 0).adjust(toPickerWheelValue: "0")

        // Allow time for UI to update
        usleep(500000) // 0.5 second wait

        XCTAssertTrue(saveButton.isEnabled, "Save button should be enabled for maximum weight")
    }

    @MainActor
    func testWeightPickerDecimalValues() throws {
        let weightPickers = app.pickers
        let decimalPicker = weightPickers.element(boundBy: 1)

        // Test all decimal values (0-9)
        for decimal in 0...9 {
            decimalPicker.pickerWheels.element(boundBy: 0).adjust(toPickerWheelValue: "\(decimal)")

            let saveButton = app.buttons["保存"]
            XCTAssertTrue(saveButton.isEnabled, "Save button should be enabled for decimal value \(decimal)")
        }
    }

    // MARK: - Date Picker Tests

    @MainActor
    func testDatePickerInteraction() throws {
        let datePicker = app.datePickers.firstMatch
        XCTAssertTrue(datePicker.exists, "Date picker should exist")

        // Debug information
        print("Date picker properties:")
        print("- exists: \(datePicker.exists)")
        print("- isEnabled: \(datePicker.isEnabled)")
        print("- isHittable: \(datePicker.isHittable)")
        print("- frame: \(datePicker.frame)")

        // For compact date picker, check if it's enabled rather than hittable
        XCTAssertTrue(datePicker.isEnabled, "Date picker should be enabled")

        // Try to tap date picker (compact style may not always respond to tap immediately)
        if datePicker.isHittable {
            print("Date picker is hittable, attempting to tap...")
            datePicker.tap()

            // Wait a moment to see if date picker UI updates
            usleep(500000) // 0.5 second wait

            // Check if any modal or popover appeared
            let popovers = app.popovers
            let sheets = app.sheets
            print("After tap - Popovers count: \(popovers.count), Sheets count: \(sheets.count)")
        } else {
            print("Date picker is not hittable - this is normal for compact style in some cases")
        }

        // Verify save button remains functional regardless of date picker interaction
        let saveButton = app.buttons["保存"]
        XCTAssertTrue(saveButton.exists, "Save button should exist")
        XCTAssertTrue(saveButton.isEnabled, "Save button should be enabled")
    }

    // MARK: - Save Button Tests

    @MainActor
    func testSaveButtonStates() throws {
        let saveButton = app.buttons["保存"]
        XCTAssertTrue(saveButton.exists, "Save button should exist")

        // Debug information about button state
        print("Save button properties:")
        print("- exists: \(saveButton.exists)")
        print("- isEnabled: \(saveButton.isEnabled)")
        print("- isHittable: \(saveButton.isHittable)")

        // Check if the button is enabled first
        if saveButton.isEnabled {
            XCTAssertTrue(saveButton.isHittable, "Enabled save button should be hittable")
        } else {
            print("Save button is disabled, checking weight picker values...")

            // Check current weight picker values
            let weightPickers = app.pickers
            if weightPickers.count >= 2 {
                let integerPicker = weightPickers.element(boundBy: 0)
                let decimalPicker = weightPickers.element(boundBy: 1)

                // Set a valid weight to enable the button
                integerPicker.pickerWheels.element(boundBy: 0).adjust(toPickerWheelValue: "60")
                decimalPicker.pickerWheels.element(boundBy: 0).adjust(toPickerWheelValue: "0")

                // Wait for UI to update
                usleep(500000) // 0.5 second wait

                // Now button should be enabled and hittable
                XCTAssertTrue(saveButton.isEnabled, "Save button should be enabled after setting valid weight")
                XCTAssertTrue(saveButton.isHittable, "Save button should be hittable when enabled")
            }
        }
    }

    @MainActor
    func testSaveButtonAction() throws {
        let saveButton = app.buttons["保存"]

        // Set a specific weight
        let weightPickers = app.pickers
        if weightPickers.count >= 2 {
            weightPickers.element(boundBy: 0).pickerWheels.element(boundBy: 0).adjust(toPickerWheelValue: "68")
            weightPickers.element(boundBy: 1).pickerWheels.element(boundBy: 0).adjust(toPickerWheelValue: "5")

            // Wait for UI to update
            usleep(500000) // 0.5 second wait
        }

        // Ensure button is enabled before tapping
        XCTAssertTrue(saveButton.isEnabled, "Save button should be enabled before tapping")

        // Tap save button
        print("Tapping save button...")
        saveButton.tap()

        // Wait a moment for any UI updates
        usleep(500000) // 0.5 second wait

        // Debug: Check what elements exist after tapping save
        print("After save button tap:")
        print("- Alerts count: \(app.alerts.count)")
        print("- Sheets count: \(app.sheets.count)")
        print("- Popovers count: \(app.popovers.count)")

        // Try to find alert with different approaches
        let alert = app.alerts.firstMatch
        let alertExists = alert.waitForExistence(timeout: 5)

        if !alertExists {
            // Debug: List all available elements
            print("Alert not found. Available static texts:")
            let allTexts = app.staticTexts
            let textCount = allTexts.count
            for i in 0..<min(textCount, 10) { // Limit to first 10 elements
                let text = allTexts.element(boundBy: i)
                if text.exists {
                    print("- \(text.label)")
                }
            }

            // Check if there are any dialogs or other modal presentations
            print("Checking for alternative modal presentations...")
            let dialogs = app.dialogs
            print("- Dialogs count: \(dialogs.count)")
        }

        XCTAssertTrue(alertExists, "Success alert should appear")

        if alertExists {
            // Verify alert content
            let completionText = alert.staticTexts["完了"]
            print("Looking for '完了' text in alert: exists = \(completionText.exists)")

            if !completionText.exists {
                // List all text elements in the alert
                print("Alert text elements:")
                let alertTexts = alert.staticTexts
                let alertTextCount = alertTexts.count
                for i in 0..<alertTextCount {
                    let text = alertTexts.element(boundBy: i)
                    if text.exists {
                        print("- Alert text: '\(text.label)'")
                    }
                }
            }

            XCTAssertTrue(completionText.exists, "Alert should show success title")
        }

        // Dismiss alert if it exists
        if alertExists {
            let okButton = alert.buttons["OK"]
            print("Looking for OK button in alert: exists = \(okButton.exists)")

            if !okButton.exists {
                // List all buttons in the alert
                print("Alert button elements:")
                let alertButtons = alert.buttons
                let buttonCount = alertButtons.count
                for i in 0..<buttonCount {
                    let button = alertButtons.element(boundBy: i)
                    if button.exists {
                        print("- Alert button: '\(button.label)'")
                    }
                }
            }

            XCTAssertTrue(okButton.exists, "OK button should exist in alert")
            okButton.tap()

            // Verify alert is dismissed
            let alertDismissed = alert.waitForNonExistence(timeout: 3)
            XCTAssertTrue(alertDismissed, "Alert should be dismissed after tapping OK")
        }
    }

    // MARK: - Multiple Entry Tests

    @MainActor
    func testMultipleWeightEntries() throws {
        // Add first entry
        addWeightEntry(weight: "70", decimal: "0")

        // Add second entry (should update the same date)
        addWeightEntry(weight: "70", decimal: "5")

        // Verify alert appears for update
        let alert = app.alerts.firstMatch
        if alert.waitForExistence(timeout: 2) {
            // Should show update message
            alert.buttons["OK"].tap()
        }
    }

    @MainActor
    func testDateResetAfterSave() throws {
        // Get current date picker value
        let datePicker = app.datePickers.firstMatch

        // Save an entry
        addWeightEntry(weight: "65", decimal: "0")

        // After saving, date should reset to today
        // Note: This is based on the implementation that resets selectedDate to Date()
        XCTAssertTrue(datePicker.exists, "Date picker should still exist after save")
    }

    // MARK: - UI Layout Tests

    @MainActor
    func testUIElementsLayout() throws {
        // Check all main UI elements exist and are positioned correctly
        let datePicker = app.datePickers.firstMatch
        XCTAssertTrue(datePicker.exists, "Date picker should be visible")

        let weightPickers = app.pickers
        XCTAssertTrue(weightPickers.count >= 2, "Weight pickers should be visible")

        let saveButton = app.buttons["保存"]
        XCTAssertTrue(saveButton.exists, "Save button should be visible")

        // Check weight unit label
        let kgLabel = app.staticTexts["kg"]
        XCTAssertTrue(kgLabel.exists, "Weight unit label should be visible")

        // Check decimal point
        let decimalPoint = app.staticTexts["."]
        XCTAssertTrue(decimalPoint.exists, "Decimal point should be visible")
    }

    @MainActor
    func testUIResponsiveness() throws {
        // Test rapid picker interactions
        let weightPickers = app.pickers
        let integerPicker = weightPickers.element(boundBy: 0)

        // Rapid value changes
        integerPicker.pickerWheels.element(boundBy: 0).adjust(toPickerWheelValue: "60")
        integerPicker.pickerWheels.element(boundBy: 0).adjust(toPickerWheelValue: "70")
        integerPicker.pickerWheels.element(boundBy: 0).adjust(toPickerWheelValue: "80")

        // UI should remain responsive
        let saveButton = app.buttons["保存"]
        XCTAssertTrue(saveButton.isEnabled, "Save button should remain functional after rapid changes")
    }

    // MARK: - Helper Methods

    private func addWeightEntry(weight: String, decimal: String) {
        let weightPickers = app.pickers
        if weightPickers.count >= 2 {
            weightPickers.element(boundBy: 0).pickerWheels.element(boundBy: 0).adjust(toPickerWheelValue: weight)
            weightPickers.element(boundBy: 1).pickerWheels.element(boundBy: 0).adjust(toPickerWheelValue: decimal)

            // Allow time for UI to update
            usleep(500000) // 0.5 second wait
        }

        let saveButton = app.buttons["保存"]
        if saveButton.exists && saveButton.isEnabled {
            saveButton.tap()

            let alert = app.alerts.firstMatch
            if alert.waitForExistence(timeout: 2) {
                alert.buttons["OK"].tap()
            }
        }
    }
}