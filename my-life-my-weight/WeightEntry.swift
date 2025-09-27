import Foundation

struct WeightEntry: Identifiable, Codable {
    let id = UUID()
    var weight: Double
    var date: Date

    init(weight: Double, date: Date = Date()) {
        self.weight = weight
        self.date = Calendar.current.startOfDay(for: date)
    }
}

extension WeightEntry {
    var formattedWeight: String {
        String(format: "%.1f kg", weight)
    }

    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.locale = Locale(identifier: "ja_JP")
        return formatter.string(from: date)
    }

    var shortDateString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "M/d"
        return formatter.string(from: date)
    }

    var dateOnly: Date {
        Calendar.current.startOfDay(for: date)
    }

    func isSameDay(as other: WeightEntry) -> Bool {
        Calendar.current.isDate(date, inSameDayAs: other.date)
    }

    func isSameDay(as date: Date) -> Bool {
        Calendar.current.isDate(self.date, inSameDayAs: date)
    }
}