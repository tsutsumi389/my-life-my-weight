import Foundation
import Combine
import SwiftUI

class WeightStore: ObservableObject {
    @Published var entries: [WeightEntry] = []

    private let userDefaults = UserDefaults.standard
    private let storageKey = "WeightEntries"

    init() {
        loadEntries()
    }

    func addEntry(_ entry: WeightEntry) {
        entries.append(entry)
        sortEntries()
        saveEntries()
    }

    func updateEntry(_ entry: WeightEntry) {
        if let index = entries.firstIndex(where: { $0.id == entry.id }) {
            entries[index] = entry
            sortEntries()
            saveEntries()
        }
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
}