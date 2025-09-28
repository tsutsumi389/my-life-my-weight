import SwiftUI

struct WeightHistoryView: View {
    @EnvironmentObject var weightStore: WeightStore
    @State private var showingEditSheet = false
    @State private var editingEntry: WeightEntry?
    @State private var currentDate = Date()

    // Callback for when a date is selected (for navigation to record tab)
    let onDateSelected: ((Date, Double?) -> Void)?

    private let calendar = Calendar.current

    init(onDateSelected: ((Date, Double?) -> Void)? = nil) {
        self.onDateSelected = onDateSelected
    }
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy年M月"
        return formatter
    }()

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Month navigation header
                HStack {
                    Button(action: previousMonth) {
                        Image(systemName: "chevron.left")
                            .font(.title2)
                            .foregroundStyle(.blue)
                    }

                    Spacer()

                    Text(dateFormatter.string(from: currentDate))
                        .font(.title2)
                        .fontWeight(.semibold)

                    Spacer()

                    Button(action: nextMonth) {
                        Image(systemName: "chevron.right")
                            .font(.title2)
                            .foregroundStyle(.blue)
                    }
                }
                .padding()
                .background(Color(.systemBackground))

                if weightStore.entries.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "calendar")
                            .font(.system(size: 60))
                            .foregroundStyle(.secondary)

                        Text("まだ記録がありません")
                            .font(.title2)
                            .foregroundStyle(.secondary)

                        Text("「記録」タブから体重を記録してみましょう")
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    CalendarGridView(
                        currentDate: currentDate,
                        entries: weightStore.entries,
                        onDateTap: { date in
                            let existingEntry = weightStore.existingEntry(for: date)

                            if let onDateSelected = onDateSelected {
                                // Navigate to record tab with selected date and weight
                                onDateSelected(date, existingEntry?.weight)
                            } else if let entry = existingEntry {
                                // Fallback to edit sheet if no navigation callback
                                editingEntry = entry
                                showingEditSheet = true
                            }
                        }
                    )
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showingEditSheet) {
                if let entry = editingEntry {
                    WeightEditView(entry: entry)
                        .environmentObject(weightStore)
                }
            }
        }
    }

    private func previousMonth() {
        withAnimation(.easeInOut(duration: 0.3)) {
            currentDate = calendar.date(byAdding: .month, value: -1, to: currentDate) ?? currentDate
        }
    }

    private func nextMonth() {
        withAnimation(.easeInOut(duration: 0.3)) {
            currentDate = calendar.date(byAdding: .month, value: 1, to: currentDate) ?? currentDate
        }
    }
}

struct CalendarGridView: View {
    let currentDate: Date
    let entries: [WeightEntry]
    let onDateTap: (Date) -> Void

    private let calendar = Calendar.current
    private let columns = Array(repeating: GridItem(.flexible()), count: 7)

    private var monthDates: [Date] {
        guard let monthRange = calendar.range(of: .day, in: .month, for: currentDate),
              let firstOfMonth = calendar.dateInterval(of: .month, for: currentDate)?.start else {
            return []
        }

        let firstWeekday = calendar.component(.weekday, from: firstOfMonth)
        var dates: [Date] = []

        // Add empty dates for days before the first day of the month
        for _ in 1..<firstWeekday {
            dates.append(Date.distantPast)
        }

        // Add all days of the month
        for day in monthRange {
            if let date = calendar.date(byAdding: .day, value: day - 1, to: firstOfMonth) {
                dates.append(date)
            }
        }

        return dates
    }

    private func entryForDate(_ date: Date) -> WeightEntry? {
        entries.first { calendar.isDate($0.date, inSameDayAs: date) }
    }

    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 8) {
                // Weekday headers
                ForEach(["日", "月", "火", "水", "木", "金", "土"], id: \.self) { weekday in
                    Text(weekday)
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundStyle(.secondary)
                        .frame(height: 30)
                }

                // Calendar dates
                ForEach(monthDates, id: \.timeIntervalSince1970) { date in
                    CalendarDayView(
                        date: date,
                        entry: entryForDate(date),
                        isCurrentMonth: date != Date.distantPast,
                        onTap: { onDateTap(date) }
                    )
                }
            }
            .padding()
        }
    }
}

struct CalendarDayView: View {
    let date: Date
    let entry: WeightEntry?
    let isCurrentMonth: Bool
    let onTap: () -> Void

    private let calendar = Calendar.current

    var body: some View {
        Button(action: isCurrentMonth ? onTap : {}) {
            VStack(spacing: 4) {
                if isCurrentMonth {
                    Text("\(calendar.component(.day, from: date))")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundStyle(entry != nil ? .primary : .secondary)

                    if let entry = entry {
                        Text(String(format: "%.1f", entry.weight))
                            .font(.caption2)
                            .fontWeight(.semibold)
                            .foregroundStyle(.white)
                            .padding(.horizontal, 4)
                            .padding(.vertical, 2)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(.blue)
                            )
                    } else {
                        Spacer()
                            .frame(height: 16)
                    }
                } else {
                    Spacer()
                        .frame(height: 40)
                }
            }
            .frame(width: 44, height: 44)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(entry != nil ? Color(.systemGray6) : Color.clear)
            )
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(!isCurrentMonth)
    }
}

#Preview {
    let store = WeightStore()
    store.entries = [
        WeightEntry(weight: 70.5, date: Date()),
        WeightEntry(weight: 71.2, date: Calendar.current.date(byAdding: .day, value: -1, to: Date()) ?? Date()),
        WeightEntry(weight: 69.8, date: Calendar.current.date(byAdding: .day, value: -2, to: Date()) ?? Date())
    ]

    return WeightHistoryView()
        .environmentObject(store)
}
