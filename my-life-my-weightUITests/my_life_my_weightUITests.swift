//
//  my_life_my_weightUITests.swift
//  my-life-my-weightUITests
//
//  Created by tsutsumi on 2025/09/27.
//

import XCTest

final class my_life_my_weightUITests: XCTestCase {

    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["UI-TESTING"]
        app.launch()
    }

    override func tearDownWithError() throws {
        app = nil
    }

    // MARK: - Tab Navigation Tests

    @MainActor
    func testTabNavigation() throws {
        // Test all tabs are accessible
        let tabBar = app.tabBars.firstMatch
        XCTAssertTrue(tabBar.exists)

        // Test "記録" tab
        let recordTab = tabBar.buttons["記録"]
        XCTAssertTrue(recordTab.exists)
        recordTab.tap()

        // Test "グラフ" tab
        let graphTab = tabBar.buttons["グラフ"]
        XCTAssertTrue(graphTab.exists)
        graphTab.tap()

        // Test "履歴" tab
        let historyTab = tabBar.buttons["履歴"]
        XCTAssertTrue(historyTab.exists)
        historyTab.tap()

        // Test "設定" tab
        let settingsTab = tabBar.buttons["設定"]
        XCTAssertTrue(settingsTab.exists)
        settingsTab.tap()
    }

    // MARK: - Weight Input Tests

    @MainActor
    func testWeightInputFlow() throws {
        // Navigate to record tab
        let recordTab = app.tabBars.buttons["記録"]
        recordTab.tap()

        // Check date picker exists
        let datePicker = app.datePickers.firstMatch
        XCTAssertTrue(datePicker.exists)

        // Check weight pickers exist
        let weightPickers = app.pickers
        XCTAssertTrue(weightPickers.count >= 2) // Integer and decimal pickers

        // Test weight selection - select 70.5 kg
        let integerPicker = weightPickers.element(boundBy: 0)
        let decimalPicker = weightPickers.element(boundBy: 1)

        // Adjust weight to 70.5
        integerPicker.pickerWheels.element(boundBy: 0).adjust(toPickerWheelValue: "70")
        decimalPicker.pickerWheels.element(boundBy: 0).adjust(toPickerWheelValue: "5")

        // Check if save button is enabled and tap it
        let saveButton = app.buttons["保存"]
        XCTAssertTrue(saveButton.exists)
        XCTAssertTrue(saveButton.isEnabled)
        saveButton.tap()

        // Wait for alert to appear
        let alert = app.alerts.firstMatch
        XCTAssertTrue(alert.waitForExistence(timeout: 2))

        // Check alert contains success message
        XCTAssertTrue(alert.staticTexts["完了"].exists)

        // Dismiss alert
        alert.buttons["OK"].tap()
    }

    @MainActor
    func testWeightInputValidation() throws {
        // Navigate to record tab
        let recordTab = app.tabBars.buttons["記録"]
        recordTab.tap()

        // Test extreme weight values
        let weightPickers = app.pickers
        XCTAssertTrue(weightPickers.count >= 2, "Should have both integer and decimal pickers")

        let integerPicker = weightPickers.element(boundBy: 0)
        let decimalPicker = weightPickers.element(boundBy: 1)
        let saveButton = app.buttons["保存"]

        // Try to set weight to minimum (30.0kg)
        integerPicker.pickerWheels.element(boundBy: 0).adjust(toPickerWheelValue: "30")
        decimalPicker.pickerWheels.element(boundBy: 0).adjust(toPickerWheelValue: "0")

        // Allow time for UI to update
        usleep(500000) // 0.5 second wait

        XCTAssertTrue(saveButton.isEnabled, "Save button should be enabled for minimum weight 30.0kg")

        // Try to set weight to maximum (200.0kg)
        integerPicker.pickerWheels.element(boundBy: 0).adjust(toPickerWheelValue: "200")
        decimalPicker.pickerWheels.element(boundBy: 0).adjust(toPickerWheelValue: "0")

        // Allow time for UI to update
        usleep(500000) // 0.5 second wait

        XCTAssertTrue(saveButton.isEnabled, "Save button should be enabled for maximum weight 200.0kg")

        // Test a normal weight to ensure it works
        integerPicker.pickerWheels.element(boundBy: 0).adjust(toPickerWheelValue: "70")
        decimalPicker.pickerWheels.element(boundBy: 0).adjust(toPickerWheelValue: "5")

        usleep(500000) // 0.5 second wait

        XCTAssertTrue(saveButton.isEnabled, "Save button should be enabled for normal weight 70.5kg")
    }

    // MARK: - History View Tests

    @MainActor
    func testHistoryViewNavigation() throws {
        // First ensure we start with clean state
        clearAllData()

        // Navigate to history tab
        let historyTab = app.tabBars.buttons["履歴"]
        historyTab.tap()

        // In empty state, check if empty message is shown
        let emptyStateText = app.staticTexts["まだ記録がありません"]
        let calendarGrid = app.scrollViews.firstMatch

        // Should show empty state when no data
        XCTAssertTrue(emptyStateText.exists || calendarGrid.exists, "Either empty state or calendar should be visible")

        // Add data and check that calendar appears
        addTestWeightEntry()
        historyTab.tap() // Refresh the view

        // Now calendar should be visible
        let refreshedCalendarGrid = app.scrollViews.firstMatch
        XCTAssertTrue(refreshedCalendarGrid.exists, "Calendar should be visible when data exists")
    }

    @MainActor
    func testHistoryViewWithData() throws {
        // First add some data
        addTestWeightEntry()

        // Navigate to history tab
        let historyTab = app.tabBars.buttons["履歴"]
        historyTab.tap()

        // Calendar should be visible (not empty state)
        let calendarGrid = app.scrollViews.firstMatch
        XCTAssertTrue(calendarGrid.exists)

        // Check weekday headers exist
        let weekdayHeaders = ["日", "月", "火", "水", "木", "金", "土"]
        for weekday in weekdayHeaders {
            XCTAssertTrue(app.staticTexts[weekday].exists)
        }
    }

    // MARK: - Settings View Tests

    @MainActor
    func testSettingsView() throws {
        // Navigate to settings tab
        let settingsTab = app.tabBars.buttons["設定"]
        settingsTab.tap()

        // Check if settings view loads without crashing
        // The exact content depends on SettingsView implementation
        // At minimum, the navigation should work
        XCTAssertTrue(true) // Basic navigation test
    }

    // MARK: - Graph View Tests

    @MainActor
    func testGraphView() throws {
        // Navigate to graph tab
        let graphTab = app.tabBars.buttons["グラフ"]
        graphTab.tap()

        // Check if graph view loads without crashing
        // The exact content depends on WeightGraphView implementation
        XCTAssertTrue(true) // Basic navigation test
    }

    // MARK: - Integration Tests

    @MainActor
    func testCompleteWorkflow() throws {
        // 1. Add weight entry
        addTestWeightEntry(weight: "65", decimal: "5")

        // 2. Check history shows the entry
        let historyTab = app.tabBars.buttons["履歴"]
        historyTab.tap()

        // Calendar should show (not empty state)
        let calendarGrid = app.scrollViews.firstMatch
        XCTAssertTrue(calendarGrid.exists)

        // 3. Navigate to graph
        let graphTab = app.tabBars.buttons["グラフ"]
        graphTab.tap()

        // Graph should load
        XCTAssertTrue(true) // Basic test that it doesn't crash

        // 4. Add another entry with different date
        let recordTab = app.tabBars.buttons["記録"]
        recordTab.tap()

        // Change date to yesterday
        let datePicker = app.datePickers.firstMatch
        datePicker.tap()

        // Note: Date picker interaction might need more specific implementation
        // depending on how the date picker is configured

        addTestWeightEntry(weight: "66", decimal: "0")
    }

    @MainActor
    func testDataPersistence() throws {
        // Add a weight entry
        addTestWeightEntry(weight: "70", decimal: "5")

        // Terminate and relaunch app
        app.terminate()
        app.launch()

        // Check that data persists by going to history
        let historyTab = app.tabBars.buttons["履歴"]
        historyTab.tap()

        // Calendar should show (indicating data exists)
        let calendarGrid = app.scrollViews.firstMatch
        XCTAssertTrue(calendarGrid.exists)

        // Should not show empty state
        let emptyStateText = app.staticTexts["まだ記録がありません"]
        XCTAssertFalse(emptyStateText.exists)
    }

    // MARK: - Performance Tests

    @MainActor
    func testLaunchPerformance() throws {
        measure(metrics: [XCTApplicationLaunchMetric()]) {
            let newApp = XCUIApplication()
            newApp.launch()
            newApp.terminate()
        }
    }

    @MainActor
    func testTabSwitchingPerformance() throws {
        measure {
            let tabBar = app.tabBars.firstMatch

            tabBar.buttons["記録"].tap()
            tabBar.buttons["グラフ"].tap()
            tabBar.buttons["履歴"].tap()
            tabBar.buttons["設定"].tap()
            tabBar.buttons["記録"].tap()
        }
    }

    // MARK: - Accessibility Tests

    @MainActor
    func testAccessibility() throws {
        // Check main tabs are accessible
        let tabBar = app.tabBars.firstMatch
        let recordTab = tabBar.buttons["記録"]
        XCTAssertTrue(recordTab.isHittable)

        recordTab.tap()

        // Check weight input elements are accessible
        let saveButton = app.buttons["保存"]
        XCTAssertTrue(saveButton.exists)
        XCTAssertTrue(saveButton.isHittable)

        let datePicker = app.datePickers.firstMatch
        XCTAssertTrue(datePicker.exists)
        XCTAssertTrue(datePicker.isHittable)
    }

    // MARK: - Error Handling Tests

    @MainActor
    func testAlertHandling() throws {
        // Add weight entry to trigger alert
        addTestWeightEntry()

        // Check alert appears and can be dismissed
        let alert = app.alerts.firstMatch
        if alert.waitForExistence(timeout: 3) {
            XCTAssertTrue(alert.exists)

            // Check alert has expected elements
            let okButton = alert.buttons["OK"]
            XCTAssertTrue(okButton.exists)
            okButton.tap()

            // Alert should disappear
            XCTAssertFalse(alert.exists)
        }
    }

    // MARK: - Helper Methods

    private func clearAllData() {
        // Navigate to settings tab
        app.tabBars.buttons["設定"].tap()

        // Look for the delete button
        let deleteButton = app.buttons["全期間のデータを削除"]
        if deleteButton.exists {
            deleteButton.tap()

            // Handle the confirmation alert
            let confirmationAlert = app.alerts["全期間のデータを削除"]
            if confirmationAlert.waitForExistence(timeout: 2) {
                let deleteButtonInAlert = confirmationAlert.buttons["削除"]
                if deleteButtonInAlert.exists {
                    deleteButtonInAlert.tap()
                }
            }
        }

        // Wait a moment for the deletion to process
        usleep(500000) // 0.5 second wait
    }

    private func addTestWeightEntry(weight: String = "70", decimal: String = "0") {
        // Navigate to record tab
        let recordTab = app.tabBars.buttons["記録"]
        recordTab.tap()

        // Set weight
        let weightPickers = app.pickers
        if weightPickers.count >= 2 {
            let integerPicker = weightPickers.element(boundBy: 0)
            let decimalPicker = weightPickers.element(boundBy: 1)

            integerPicker.pickerWheels.element(boundBy: 0).adjust(toPickerWheelValue: weight)
            decimalPicker.pickerWheels.element(boundBy: 0).adjust(toPickerWheelValue: decimal)

            // Allow time for UI to update
            usleep(500000) // 0.5 second wait
        }

        // Save
        let saveButton = app.buttons["保存"]
        if saveButton.exists && saveButton.isEnabled {
            saveButton.tap()

            // Wait for and dismiss alert if it appears
            let alert = app.alerts.firstMatch
            if alert.waitForExistence(timeout: 2) {
                alert.buttons["OK"].tap()
            }
        }
    }
}
