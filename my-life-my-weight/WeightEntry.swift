import Foundation

struct WeightEntry: Identifiable, Codable {
    let id = UUID()
    var weight: Double
    var date: Date
    var note: String

    init(weight: Double, date: Date = Date(), note: String = "") {
        self.weight = weight
        self.date = date
        self.note = note
    }
}

extension WeightEntry {
    var formattedWeight: String {
        String(format: "%.1f kg", weight)
    }

    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "ja_JP")
        return formatter.string(from: date)
    }

    var shortDateString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "M/d"
        return formatter.string(from: date)
    }
}