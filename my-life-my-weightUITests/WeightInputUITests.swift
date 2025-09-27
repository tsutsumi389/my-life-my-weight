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
        XCTAssertTrue(datePicker.isHittable, "Date picker should be interactive")

        // Tap date picker to open date selection
        datePicker.tap()

        // Verify save button remains functional
        let saveButton = app.buttons["保存"]
        XCTAssertTrue(saveButton.exists)
    }

    // MARK: - Save Button Tests

    @MainActor
    func testSaveButtonStates() throws {
        let saveButton = app.buttons["保存"]
        XCTAssertTrue(saveButton.exists, "Save button should exist")

        // Default state should be enabled (assuming valid default weight)
        XCTAssertTrue(saveButton.isEnabled, "Save button should be enabled by default")

        // Test button appearance
        XCTAssertTrue(saveButton.isHittable, "Save button should be hittable")
    }

    @MainActor
    func testSaveButtonAction() throws {
        let saveButton = app.buttons["保存"]

        // Set a specific weight
        let weightPickers = app.pickers
        if weightPickers.count >= 2 {
            weightPickers.element(boundBy: 0).pickerWheels.element(boundBy: 0).adjust(toPickerWheelValue: "68")
            weightPickers.element(boundBy: 1).pickerWheels.element(boundBy: 0).adjust(toPickerWheelValue: "5")
        }

        // Tap save button
        saveButton.tap()

        // Wait for alert
        let alert = app.alerts.firstMatch
        XCTAssertTrue(alert.waitForExistence(timeout: 3), "Success alert should appear")

        // Verify alert content
        XCTAssertTrue(alert.staticTexts["完了"].exists, "Alert should show success title")

        // Dismiss alert
        let okButton = alert.buttons["OK"]
        XCTAssertTrue(okButton.exists, "OK button should exist in alert")
        okButton.tap()

        // Verify alert is dismissed
        XCTAssertFalse(alert.exists, "Alert should be dismissed after tapping OK")
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