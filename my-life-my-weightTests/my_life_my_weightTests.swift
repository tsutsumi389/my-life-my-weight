//
//  my_life_my_weightTests.swift
//  my-life-my-weightTests
//
//  Created by tsutsumi on 2025/09/27.
//

import Testing
import Foundation
@testable import my_life_my_weight

struct WeightEntryTests {

    @Test func testWeightEntryInit() {
        let weight = 70.5
        let date = Date()
        let entry = WeightEntry(weight: weight, date: date)

        #expect(entry.weight == weight)
        #expect(Calendar.current.isDate(entry.date, inSameDayAs: date))
    }

    @Test func testWeightEntryInitWithoutDate() {
        let weight = 65.0
        let entry = WeightEntry(weight: weight)

        #expect(entry.weight == weight)
        #expect(Calendar.current.isDate(entry.date, inSameDayAs: Date()))
    }

    @Test func testDateNormalization() {
        let calendar = Calendar.current
        let date = Date()
        let specificTime = calendar.date(bySettingHour: 15, minute: 30, second: 45, of: date)!
        let entry = WeightEntry(weight: 70.0, date: specificTime)

        let expectedDate = calendar.startOfDay(for: specificTime)
        #expect(entry.date == expectedDate)
    }

    @Test func testFormattedWeight() {
        let entry = WeightEntry(weight: 70.5)
        #expect(entry.formattedWeight == "70.5 kg")

        let entryWithZero = WeightEntry(weight: 70.0)
        #expect(entryWithZero.formattedWeight == "70.0 kg")
    }

    @Test func testFormattedDate() {
        let calendar = Calendar.current
        let date = calendar.date(from: DateComponents(year: 2025, month: 9, day: 27))!
        let entry = WeightEntry(weight: 70.0, date: date)

        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.locale = Locale(identifier: "ja_JP")
        let expectedDate = formatter.string(from: date)

        #expect(entry.formattedDate == expectedDate)
    }

    @Test func testShortDateString() {
        let calendar = Calendar.current
        let date = calendar.date(from: DateComponents(year: 2025, month: 9, day: 27))!
        let entry = WeightEntry(weight: 70.0, date: date)

        #expect(entry.shortDateString == "9/27")
    }

    @Test func testDateOnly() {
        let calendar = Calendar.current
        let date = Date()
        let specificTime = calendar.date(bySettingHour: 15, minute: 30, second: 45, of: date)!
        let entry = WeightEntry(weight: 70.0, date: specificTime)

        let expectedDate = calendar.startOfDay(for: specificTime)
        #expect(entry.dateOnly == expectedDate)
    }

    @Test func testIsSameDayWithWeightEntry() {
        let calendar = Calendar.current
        let today = Date()
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: today)!
        let todayLater = calendar.date(bySettingHour: 23, minute: 59, second: 59, of: today)!

        let entry1 = WeightEntry(weight: 70.0, date: today)
        let entry2 = WeightEntry(weight: 71.0, date: todayLater)
        let entry3 = WeightEntry(weight: 72.0, date: tomorrow)

        #expect(entry1.isSameDay(as: entry2))
        #expect(!entry1.isSameDay(as: entry3))
    }

    @Test func testIsSameDayWithDate() {
        let calendar = Calendar.current
        let today = Date()
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: today)!
        let todayLater = calendar.date(bySettingHour: 23, minute: 59, second: 59, of: today)!

        let entry = WeightEntry(weight: 70.0, date: today)

        #expect(entry.isSameDay(as: todayLater))
        #expect(!entry.isSameDay(as: tomorrow))
    }

    @Test func testCodable() throws {
        let originalEntry = WeightEntry(weight: 75.5, date: Date())

        let encoder = JSONEncoder()
        let data = try encoder.encode(originalEntry)

        let decoder = JSONDecoder()
        let decodedEntry = try decoder.decode(WeightEntry.self, from: data)

        #expect(decodedEntry.weight == originalEntry.weight)
        #expect(decodedEntry.date == originalEntry.date)
    }
}

struct WeightStoreTests {

    func createTestStore() -> WeightStore {
        // テスト専用のUserDefaultsを作成（UUIDを使って確実に独立させる）
        let testSuiteName = "test-weightstore-\(UUID().uuidString)"
        let testDefaults = UserDefaults(suiteName: testSuiteName)!

        // 念のため既存データをクリア
        testDefaults.removeObject(forKey: "WeightEntries")

        let store = WeightStore(userDefaults: testDefaults)
        return store
    }

    @Test func testInitialState() {
        let store = createTestStore()
        #expect(store.entries.isEmpty)
        #expect(store.latestEntry == nil)
        #expect(store.weightDifference == nil)
    }

    @Test func testAddEntry() {
        let store = createTestStore()
        let entry = WeightEntry(weight: 70.0)

        let result = store.addEntry(entry)

        #expect(result == true)
        #expect(store.entries.count == 1)
        #expect(store.entries.first?.weight == 70.0)
        #expect(store.latestEntry?.weight == 70.0)
    }

    @Test func testAddMultipleEntries() {
        let store = createTestStore()
        let calendar = Calendar.current
        let today = Date()
        let yesterday = calendar.date(byAdding: .day, value: -1, to: today)!

        let entry1 = WeightEntry(weight: 70.0, date: yesterday)
        let entry2 = WeightEntry(weight: 71.0, date: today)

        store.addEntry(entry1)
        store.addEntry(entry2)

        #expect(store.entries.count == 2)
        #expect(store.entries.first?.weight == 71.0)
        #expect(store.entries.last?.weight == 70.0)
    }

    @Test func testAddEntryForSameDate() {
        let store = createTestStore()
        let date = Date()
        let entry1 = WeightEntry(weight: 70.0, date: date)
        let entry2 = WeightEntry(weight: 71.0, date: date)

        store.addEntry(entry1)
        store.addEntry(entry2)

        #expect(store.entries.count == 1)
        #expect(store.entries.first?.weight == 71.0)
    }

    @Test func testUpdateEntryNotFound() {
        let store = createTestStore()
        let nonExistentEntry = WeightEntry(weight: 70.0)

        let result = store.updateEntry(nonExistentEntry)

        #expect(result == false)
        #expect(store.entries.isEmpty)
    }

    @Test func testCanAddEntry() {
        let store = createTestStore()
        let date = Date()

        #expect(store.canAddEntry(for: date) == true)

        store.addEntry(WeightEntry(weight: 70.0, date: date))

        #expect(store.canAddEntry(for: date) == false)
    }

    @Test func testExistingEntry() {
        let store = createTestStore()
        let date = Date()
        let entry = WeightEntry(weight: 70.0, date: date)

        #expect(store.existingEntry(for: date) == nil)

        store.addEntry(entry)

        let existingEntry = store.existingEntry(for: date)
        #expect(existingEntry != nil)
        #expect(existingEntry?.weight == 70.0)
    }

    @Test func testDeleteEntry() {
        let store = createTestStore()
        let entry = WeightEntry(weight: 70.0)
        store.addEntry(entry)

        #expect(store.entries.count == 1)

        store.deleteEntry(entry)

        #expect(store.entries.isEmpty)
    }

    @Test func testDeleteEntryAtIndexSet() {
        let store = createTestStore()
        let calendar = Calendar.current
        let today = Date()
        let yesterday = calendar.date(byAdding: .day, value: -1, to: today)!

        store.addEntry(WeightEntry(weight: 70.0, date: yesterday))
        store.addEntry(WeightEntry(weight: 71.0, date: today))

        #expect(store.entries.count == 2)

        store.deleteEntry(at: IndexSet(integer: 0))

        #expect(store.entries.count == 1)
        #expect(store.entries.first?.weight == 70.0)
    }

    @Test func testWeightDifference() {
        let store = createTestStore()
        let calendar = Calendar.current
        let today = Date()
        let yesterday = calendar.date(byAdding: .day, value: -1, to: today)!

        #expect(store.weightDifference == nil)

        store.addEntry(WeightEntry(weight: 70.0, date: yesterday))
        #expect(store.weightDifference == nil)

        store.addEntry(WeightEntry(weight: 71.5, date: today))
        #expect(store.weightDifference == 1.5)
    }

    @Test func testDeleteAllEntries() {
        let store = createTestStore()
        let calendar = Calendar.current
        let today = Date()
        let yesterday = calendar.date(byAdding: .day, value: -1, to: today)!

        store.addEntry(WeightEntry(weight: 70.0, date: yesterday))
        store.addEntry(WeightEntry(weight: 71.0, date: today))

        #expect(store.entries.count == 2)

        store.deleteAllEntries()

        #expect(store.entries.isEmpty)
    }

    @Test func testSortingByDate() {
        let store = createTestStore()
        let calendar = Calendar.current
        let today = Date()
        let yesterday = calendar.date(byAdding: .day, value: -1, to: today)!
        let dayBeforeYesterday = calendar.date(byAdding: .day, value: -2, to: today)!

        store.addEntry(WeightEntry(weight: 70.0, date: dayBeforeYesterday))
        store.addEntry(WeightEntry(weight: 72.0, date: today))
        store.addEntry(WeightEntry(weight: 71.0, date: yesterday))

        #expect(store.entries.count == 3)
        #expect(store.entries[0].weight == 72.0)
        #expect(store.entries[1].weight == 71.0)
        #expect(store.entries[2].weight == 70.0)
    }

    @Test func testImportEntriesWithNewEntries() {
        let store = createTestStore()
        let calendar = Calendar.current
        let today = Date()
        let yesterday = calendar.date(byAdding: .day, value: -1, to: today)!

        let entry1 = WeightEntry(weight: 70.0, date: yesterday)
        let entry2 = WeightEntry(weight: 71.0, date: today)
        let newEntries = [entry1, entry2]

        let result = store.importEntries(newEntries)

        #expect(result.imported == 2)
        #expect(result.updated == 0)
        #expect(store.entries.count == 2)
        #expect(store.entries[0].weight == 71.0)
        #expect(store.entries[1].weight == 70.0)
    }

    @Test func testImportEntriesWithExistingEntries() {
        let store = createTestStore()
        let calendar = Calendar.current
        let today = Date()
        let yesterday = calendar.date(byAdding: .day, value: -1, to: today)!

        store.addEntry(WeightEntry(weight: 70.0, date: yesterday))
        store.addEntry(WeightEntry(weight: 71.0, date: today))

        let updatedEntry1 = WeightEntry(weight: 69.5, date: yesterday)
        let updatedEntry2 = WeightEntry(weight: 71.5, date: today)
        let updateEntries = [updatedEntry1, updatedEntry2]

        let result = store.importEntries(updateEntries)

        #expect(result.imported == 0)
        #expect(result.updated == 2)
        #expect(store.entries.count == 2)
        #expect(store.entries[0].weight == 71.5)
        #expect(store.entries[1].weight == 69.5)
    }

    @Test func testImportEntriesMixedNewAndUpdate() {
        let store = createTestStore()
        let calendar = Calendar.current
        let today = Date()
        let yesterday = calendar.date(byAdding: .day, value: -1, to: today)!
        let dayBeforeYesterday = calendar.date(byAdding: .day, value: -2, to: today)!

        store.addEntry(WeightEntry(weight: 70.0, date: yesterday))

        let updateEntry = WeightEntry(weight: 69.5, date: yesterday)
        let newEntry1 = WeightEntry(weight: 71.0, date: today)
        let newEntry2 = WeightEntry(weight: 68.0, date: dayBeforeYesterday)
        let mixedEntries = [updateEntry, newEntry1, newEntry2]

        let result = store.importEntries(mixedEntries)

        #expect(result.imported == 2)
        #expect(result.updated == 1)
        #expect(store.entries.count == 3)
        #expect(store.entries[0].weight == 71.0)
        #expect(store.entries[1].weight == 69.5)
        #expect(store.entries[2].weight == 68.0)
    }

    @Test func testImportEntriesEmptyArray() {
        let store = createTestStore()
        store.addEntry(WeightEntry(weight: 70.0))

        let result = store.importEntries([])

        #expect(result.imported == 0)
        #expect(result.updated == 0)
        #expect(store.entries.count == 1)
    }

    @Test func testImportEntriesSortsCorrectly() {
        let store = createTestStore()
        let calendar = Calendar.current
        let today = Date()
        let yesterday = calendar.date(byAdding: .day, value: -1, to: today)!
        let dayBeforeYesterday = calendar.date(byAdding: .day, value: -2, to: today)!

        let entry1 = WeightEntry(weight: 68.0, date: dayBeforeYesterday)
        let entry2 = WeightEntry(weight: 71.0, date: today)
        let entry3 = WeightEntry(weight: 70.0, date: yesterday)
        let entriesInRandomOrder = [entry2, entry1, entry3]

        let result = store.importEntries(entriesInRandomOrder)

        #expect(result.imported == 3)
        #expect(store.entries.count == 3)
        #expect(store.entries[0].weight == 71.0)
        #expect(store.entries[1].weight == 70.0)
        #expect(store.entries[2].weight == 68.0)
    }
}

struct DataImportTests {

    func parseWeightEntry(from line: String) -> WeightEntry? {
        let components = line.components(separatedBy: " ")
        guard components.count == 2 else { return nil }

        let dateString = components[0]
        let weightString = components[1]

        // 厳密な日付形式チェック（yyyy/MM/dd）
        guard isValidDateFormat(dateString) else { return nil }

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy/MM/dd"
        dateFormatter.isLenient = false

        guard let date = dateFormatter.date(from: dateString),
              let weight = Double(weightString) else {
            return nil
        }

        return WeightEntry(weight: weight, date: date)
    }

    func isValidDateFormat(_ dateString: String) -> Bool {
        // 正確にyyyy/MM/dd形式かチェック（10文字、スラッシュの位置など）
        guard dateString.count == 10 else { return false }

        let components = dateString.components(separatedBy: "/")
        guard components.count == 3 else { return false }

        let year = components[0]
        let month = components[1]
        let day = components[2]

        // 年は4桁、月と日は2桁である必要がある
        guard year.count == 4,
              month.count == 2,
              day.count == 2 else { return false }

        // すべて数字である必要がある
        guard year.allSatisfy(\.isNumber),
              month.allSatisfy(\.isNumber),
              day.allSatisfy(\.isNumber) else { return false }

        // 基本的な範囲チェック
        guard let yearInt = Int(year),
              let monthInt = Int(month),
              let dayInt = Int(day) else { return false }

        guard yearInt >= 1900 && yearInt <= 2100,
              monthInt >= 1 && monthInt <= 12,
              dayInt >= 1 && dayInt <= 31 else { return false }

        return true
    }

    @Test func testParseValidWeightEntry() {
        let validLine = "2024/01/15 65.2"
        let entry = parseWeightEntry(from: validLine)

        #expect(entry != nil)
        #expect(entry?.weight == 65.2)

        let calendar = Calendar.current
        let expectedDate = calendar.date(from: DateComponents(year: 2024, month: 1, day: 15))!
        #expect(Calendar.current.isDate(entry!.date, inSameDayAs: expectedDate))
    }

    @Test func testParseValidWeightEntryWithInteger() {
        let validLine = "2024/12/25 70"
        let entry = parseWeightEntry(from: validLine)

        #expect(entry != nil)
        #expect(entry?.weight == 70.0)

        let calendar = Calendar.current
        let expectedDate = calendar.date(from: DateComponents(year: 2024, month: 12, day: 25))!
        #expect(Calendar.current.isDate(entry!.date, inSameDayAs: expectedDate))
    }

    @Test func testParseInvalidDateFormat() {
        let invalidLines = [
            "24/01/15 65.2",          // 年が2桁
            "2024-01-15 65.2",        // ハイフン区切り
            "2024/1/15 65.2",         // 月が1桁
            "2024/01/5 65.2",         // 日が1桁
            "invalid-date 65.2",      // 完全に無効
            "2024/13/01 65.2",        // 無効な月
            "2024/01/32 65.2",        // 無効な日
            "1899/01/01 65.2",        // 年が範囲外（下限）
            "2101/01/01 65.2"         // 年が範囲外（上限）
        ]

        for line in invalidLines {
            let entry = parseWeightEntry(from: line)
            #expect(entry == nil, "Should be nil for line: \(line)")
        }
    }

    @Test func testParseInvalidWeightFormat() {
        let invalidLines = [
            "2024/01/15 invalid-weight",
            "2024/01/15 65.2.3",
            "2024/01/15 ",
            "2024/01/15 65,2"
        ]

        for line in invalidLines {
            let entry = parseWeightEntry(from: line)
            #expect(entry == nil, "Should be nil for line: \(line)")
        }
    }

    @Test func testParseInvalidLineFormat() {
        let invalidLines = [
            "2024/01/15",             // 体重なし
            "65.2",                   // 日付なし
            "2024/01/15 65.2 extra",  // 余分な要素
            "",                       // 空文字
            "   ",                    // 空白のみ
            "2024/01/15  65.2",       // ダブルスペース
            "2024/01/15\t65.2"        // タブ区切り
        ]

        for line in invalidLines {
            let entry = parseWeightEntry(from: line)
            #expect(entry == nil, "Should be nil for line: \(line)")
        }
    }

    @Test func testParseMultipleValidEntries() {
        let validLines = [
            "2024/01/15 65.2",
            "2024/01/16 64.8",
            "2024/01/17 65.0",
            "2024/01/18 64.5"
        ]

        let entries = validLines.compactMap { parseWeightEntry(from: $0) }

        #expect(entries.count == 4)
        #expect(entries[0].weight == 65.2)
        #expect(entries[1].weight == 64.8)
        #expect(entries[2].weight == 65.0)
        #expect(entries[3].weight == 64.5)
    }

    @Test func testParseBoundaryValues() {
        let boundaryLines = [
            "2024/01/01 0.1",
            "2024/12/31 999.9",
            "2000/01/01 50.0",
            "2099/12/31 100.0"
        ]

        for line in boundaryLines {
            let entry = parseWeightEntry(from: line)
            #expect(entry != nil, "Should not be nil for line: \(line)")
        }
    }

    @Test func testParseWithLeadingTrailingSpaces() {
        let lineWithSpaces = "  2024/01/15 65.2  "
        let trimmedLine = lineWithSpaces.trimmingCharacters(in: .whitespacesAndNewlines)
        let entry = parseWeightEntry(from: trimmedLine)

        #expect(entry != nil)
        #expect(entry?.weight == 65.2)
    }
}

struct WeightInputViewTests {

    @Test func testWeightInputViewInitWithoutParameters() {
        let inputView = WeightInputView()

        #expect(inputView.initialDate == nil)
        #expect(inputView.initialWeight == nil)
    }

    @Test func testWeightInputViewInitWithDate() {
        let testDate = Calendar.current.date(from: DateComponents(year: 2024, month: 1, day: 15))!
        let inputView = WeightInputView(initialDate: testDate)

        #expect(inputView.initialDate != nil)
        #expect(Calendar.current.isDate(inputView.initialDate!, inSameDayAs: testDate))
        #expect(inputView.initialWeight == nil)
    }

    @Test func testWeightInputViewInitWithWeight() {
        let testWeight = 65.5
        let inputView = WeightInputView(initialWeight: testWeight)

        #expect(inputView.initialDate == nil)
        #expect(inputView.initialWeight == testWeight)
    }

    @Test func testWeightInputViewInitWithDateAndWeight() {
        let testDate = Calendar.current.date(from: DateComponents(year: 2024, month: 1, day: 15))!
        let testWeight = 65.5
        let inputView = WeightInputView(initialDate: testDate, initialWeight: testWeight)

        #expect(inputView.initialDate != nil)
        #expect(Calendar.current.isDate(inputView.initialDate!, inSameDayAs: testDate))
        #expect(inputView.initialWeight == testWeight)
    }
}

struct WeightHistoryViewTests {

    @Test func testWeightHistoryViewInitWithoutCallback() {
        let historyView = WeightHistoryView()

        #expect(historyView.onDateSelected == nil)
    }

    @Test func testWeightHistoryViewInitWithCallback() {
        var capturedDate: Date?
        var capturedWeight: Double?

        let callback: (Date, Double?) -> Void = { date, weight in
            capturedDate = date
            capturedWeight = weight
        }

        let historyView = WeightHistoryView(onDateSelected: callback)

        #expect(historyView.onDateSelected != nil)

        // Test callback functionality
        let testDate = Date()
        let testWeight = 70.5
        historyView.onDateSelected?(testDate, testWeight)

        #expect(capturedDate != nil)
        #expect(Calendar.current.isDate(capturedDate!, inSameDayAs: testDate))
        #expect(capturedWeight == testWeight)
    }

    @Test func testWeightHistoryViewCallbackWithNilWeight() {
        var capturedDate: Date?
        var capturedWeight: Double?

        let callback: (Date, Double?) -> Void = { date, weight in
            capturedDate = date
            capturedWeight = weight
        }

        let historyView = WeightHistoryView(onDateSelected: callback)

        let testDate = Date()
        historyView.onDateSelected?(testDate, nil)

        #expect(capturedDate != nil)
        #expect(Calendar.current.isDate(capturedDate!, inSameDayAs: testDate))
        #expect(capturedWeight == nil)
    }
}

struct WeightGraphViewTests {

    func createTestStore(withEntryCount count: Int) -> WeightStore {
        let testSuiteName = "test-graphview-\(UUID().uuidString)"
        let testDefaults = UserDefaults(suiteName: testSuiteName)!
        testDefaults.removeObject(forKey: "WeightEntries")

        let store = WeightStore(userDefaults: testDefaults)
        let calendar = Calendar.current
        let today = Date()

        for i in 0..<count {
            let date = calendar.date(byAdding: .day, value: -i, to: today)!
            let weight = 70.0 + Double(i) * 0.1
            store.addEntry(WeightEntry(weight: weight, date: date))
        }

        return store
    }

    @Test func testOneMonthPeriodShowsLast30Entries() {
        // Create store with 50 entries
        let store = createTestStore(withEntryCount: 50)

        #expect(store.entries.count == 50)

        // Simulate the filtering logic from WeightGraphView for oneMonth period
        let sortedAllEntries = store.entries.sorted { $0.date > $1.date }
        let filteredEntries = Array(sortedAllEntries.prefix(30))

        #expect(filteredEntries.count == 30)

        // Verify the entries are the most recent 30
        // The most recent entry should have the earliest date offset (0 days ago)
        let firstEntry = filteredEntries.first!
        let lastEntry = filteredEntries.last!

        #expect(firstEntry.date >= lastEntry.date)
    }

    @Test func testOneMonthPeriodWithFewerThan30Entries() {
        // Create store with only 20 entries
        let store = createTestStore(withEntryCount: 20)

        #expect(store.entries.count == 20)

        // Simulate the filtering logic
        let sortedAllEntries = store.entries.sorted { $0.date > $1.date }
        let filteredEntries = Array(sortedAllEntries.prefix(30))

        // Should return all 20 entries
        #expect(filteredEntries.count == 20)
    }

    @Test func testOneMonthPeriodWithNoEntries() {
        // Create empty store
        let testSuiteName = "test-graphview-empty-\(UUID().uuidString)"
        let testDefaults = UserDefaults(suiteName: testSuiteName)!
        testDefaults.removeObject(forKey: "WeightEntries")
        let store = WeightStore(userDefaults: testDefaults)

        #expect(store.entries.isEmpty)

        // Simulate the filtering logic
        let sortedAllEntries = store.entries.sorted { $0.date > $1.date }
        let filteredEntries = Array(sortedAllEntries.prefix(30))

        #expect(filteredEntries.isEmpty)
    }

    @Test func testOneYearPeriodShowsLast365Entries() {
        // Create store with 500 entries (more than 365)
        let store = createTestStore(withEntryCount: 500)

        #expect(store.entries.count == 500)

        // Simulate the filtering logic from WeightGraphView for oneYear period
        let sortedAllEntries = store.entries.sorted { $0.date > $1.date }
        let filteredEntries = Array(sortedAllEntries.prefix(365))

        #expect(filteredEntries.count == 365)

        // Verify the entries are the most recent 365
        let firstEntry = filteredEntries.first!
        let lastEntry = filteredEntries.last!

        #expect(firstEntry.date >= lastEntry.date)
    }

    @Test func testOneYearPeriodWithFewerThan365Entries() {
        // Create store with only 200 entries
        let store = createTestStore(withEntryCount: 200)

        #expect(store.entries.count == 200)

        // Simulate the filtering logic
        let sortedAllEntries = store.entries.sorted { $0.date > $1.date }
        let filteredEntries = Array(sortedAllEntries.prefix(365))

        // Should return all 200 entries
        #expect(filteredEntries.count == 200)
    }

    @Test func testAllTimePeriodShowsAllEntries() {
        let store = createTestStore(withEntryCount: 100)

        // Simulate the filtering logic for allTime period
        let filteredEntries = store.entries

        #expect(filteredEntries.count == 100)
    }
}

struct CalendarNavigationTests {

    @Test func testCalendarToRecordTabNavigation() {
        // Test data preparation
        let testDate = Calendar.current.date(from: DateComponents(year: 2024, month: 1, day: 15))!
        let testWeight = 65.5

        // Test that callback parameters are correctly passed
        var receivedDate: Date?
        var receivedWeight: Double?

        let onDateSelected: (Date, Double?) -> Void = { date, weight in
            receivedDate = date
            receivedWeight = weight
        }

        // Simulate calendar date selection
        onDateSelected(testDate, testWeight)

        #expect(receivedDate != nil)
        #expect(Calendar.current.isDate(receivedDate!, inSameDayAs: testDate))
        #expect(receivedWeight == testWeight)

        // Test WeightInputView initialization with received parameters
        let inputView = WeightInputView(initialDate: receivedDate, initialWeight: receivedWeight)

        #expect(inputView.initialDate != nil)
        #expect(Calendar.current.isDate(inputView.initialDate!, inSameDayAs: testDate))
        #expect(inputView.initialWeight == testWeight)
    }

    @Test func testCalendarToRecordTabNavigationWithoutExistingWeight() {
        let testDate = Calendar.current.date(from: DateComponents(year: 2024, month: 1, day: 15))!

        var receivedDate: Date?
        var receivedWeight: Double?

        let onDateSelected: (Date, Double?) -> Void = { date, weight in
            receivedDate = date
            receivedWeight = weight
        }

        // Simulate calendar date selection without existing weight
        onDateSelected(testDate, nil)

        #expect(receivedDate != nil)
        #expect(Calendar.current.isDate(receivedDate!, inSameDayAs: testDate))
        #expect(receivedWeight == nil)

        // Test WeightInputView initialization
        let inputView = WeightInputView(initialDate: receivedDate, initialWeight: receivedWeight)

        #expect(inputView.initialDate != nil)
        #expect(Calendar.current.isDate(inputView.initialDate!, inSameDayAs: testDate))
        #expect(inputView.initialWeight == nil)
    }
}
