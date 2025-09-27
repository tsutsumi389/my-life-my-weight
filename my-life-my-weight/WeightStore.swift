import Foundation
import Combine
import SwiftUI

class WeightStore: ObservableObject {
    @Published var entries: [WeightEntry] = []

    private let userDefaults: UserDefaults
    private let storageKey = "WeightEntries"

    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
        loadEntries()
    }

    func addEntry(_ entry: WeightEntry) -> Bool {
        // Check if entry for this date already exists
        if let existingIndex = entries.firstIndex(where: { $0.isSameDay(as: entry.date) }) {
            // Update existing entry for the same date
            entries[existingIndex] = entry
        } else {
            // Add new entry
            entries.append(entry)
        }
        sortEntries()
        saveEntries()
        return true
    }

    func updateEntry(_ entry: WeightEntry) -> Bool {
        if let index = entries.firstIndex(where: { $0.id == entry.id }) {
            let originalDate = entries[index].date

            // Check if changing to a date that already has an entry
            if !Calendar.current.isDate(originalDate, inSameDayAs: entry.date) {
                if entries.contains(where: { $0.id != entry.id && $0.isSameDay(as: entry.date) }) {
                    return false // Cannot update to a date that already has an entry
                }
            }

            entries[index] = entry
            sortEntries()
            saveEntries()
            return true
        }
        return false
    }

    func canAddEntry(for date: Date) -> Bool {
        return !entries.contains { $0.isSameDay(as: date) }
    }

    func existingEntry(for date: Date) -> WeightEntry? {
        return entries.first { $0.isSameDay(as: date) }
    }

    func deleteEntry(_ entry: WeightEntry) {
        entries.removeAll { $0.id == entry.id }
        saveEntries()
    }

    func deleteEntry(at indexSet: IndexSet) {
        entries.remove(atOffsets: indexSet)
        saveEntries()
    }

    var latestEntry: WeightEntry? {
        entries.first
    }

    var weightDifference: Double? {
        guard entries.count >= 2 else { return nil }
        return entries[0].weight - entries[1].weight
    }

    private func sortEntries() {
        entries.sort { $0.date > $1.date }
    }

    private func saveEntries() {
        do {
            let data = try JSONEncoder().encode(entries)
            userDefaults.set(data, forKey: storageKey)
        } catch {
            print("Failed to save entries: \(error)")
        }
    }

    private func loadEntries() {
        guard let data = userDefaults.data(forKey: storageKey) else { return }

        do {
            entries = try JSONDecoder().decode([WeightEntry].self, from: data)
            sortEntries()
        } catch {
            print("Failed to load entries: \(error)")
        }
    }

    func deleteAllEntries() {
        entries.removeAll()
        saveEntries()
    }

    func importEntries(_ newEntries: [WeightEntry]) -> (imported: Int, updated: Int) {
        var importedCount = 0
        var updatedCount = 0

        for entry in newEntries {
            if let existingIndex = entries.firstIndex(where: { $0.isSameDay(as: entry.date) }) {
                entries[existingIndex] = entry
                updatedCount += 1
            } else {
                entries.append(entry)
                importedCount += 1
            }
        }

        sortEntries()
        saveEntries()
        return (imported: importedCount, updated: updatedCount)
    }
}