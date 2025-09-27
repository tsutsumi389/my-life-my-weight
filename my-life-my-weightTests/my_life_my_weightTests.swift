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
        // UserDefaultsから古いテストデータをクリア
        UserDefaults.standard.removeObject(forKey: "WeightEntries")
        let store = WeightStore()
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
}
