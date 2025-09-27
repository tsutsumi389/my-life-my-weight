import SwiftUI
import Charts

enum GraphPeriod: String, CaseIterable {
    case oneMonth = "1ヶ月"
    case oneYear = "1年"
    case allTime = "全期間"

    var calendar: Calendar.Component {
        switch self {
        case .oneMonth:
            return .month
        case .oneYear:
            return .year
        case .allTime:
            return .year // Will be handled differently for all time
        }
    }

    var value: Int {
        switch self {
        case .oneMonth:
            return -1
        case .oneYear:
            return -1
        case .allTime:
            return 0 // Special case
        }
    }
}

struct WeightGraphView: View {
    @EnvironmentObject var weightStore: WeightStore
    @State private var selectedPeriod: GraphPeriod = .oneMonth

    private var filteredEntries: [WeightEntry] {
        let now = Date()
        let calendar = Calendar.current

        switch selectedPeriod {
        case .oneMonth:
            guard let oneMonthAgo = calendar.date(byAdding: .month, value: -1, to: now) else {
                return weightStore.entries
            }
            return weightStore.entries.filter { $0.date >= oneMonthAgo }
        case .oneYear:
            guard let oneYearAgo = calendar.date(byAdding: .year, value: -1, to: now) else {
                return weightStore.entries
            }
            return weightStore.entries.filter { $0.date >= oneYearAgo }
        case .allTime:
            return weightStore.entries
        }
    }

    private var sortedEntries: [WeightEntry] {
        filteredEntries.sorted { $0.date < $1.date }
    }

    private var yAxisRange: ClosedRange<Double> {
        guard !sortedEntries.isEmpty else { return 0...100 }

        let weights = sortedEntries.map { $0.weight }
        let minWeight = weights.min() ?? 0
        let maxWeight = weights.max() ?? 100

        let padding = (maxWeight - minWeight) * 0.1
        return (minWeight - padding)...(maxWeight + padding)
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                periodSelectionView

                if sortedEntries.isEmpty {
                    emptyStateView
                } else {
                    chartView
                }

                Spacer()
            }
            .padding()
        }
    }

    private var periodSelectionView: some View {
        Picker("期間", selection: $selectedPeriod) {
            ForEach(GraphPeriod.allCases, id: \.self) { period in
                Text(period.rawValue).tag(period)
            }
        }
        .pickerStyle(.segmented)
    }

    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "chart.line.uptrend.xyaxis")
                .font(.system(size: 60))
                .foregroundColor(.gray)

            Text("グラフデータがありません")
                .font(.headline)
                .foregroundColor(.gray)

            Text("体重を記録してグラフを表示しましょう")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var chartView: some View {
        Chart(sortedEntries) { entry in
            LineMark(
                x: .value("日付", entry.date),
                y: .value("体重", entry.weight)
            )
            .foregroundStyle(.green)
            .lineStyle(StrokeStyle(lineWidth: 2))

            PointMark(
                x: .value("日付", entry.date),
                y: .value("体重", entry.weight)
            )
            .foregroundStyle(.green)
            .symbolSize(30)
        }
        .chartYScale(domain: yAxisRange)
        .chartXAxis {
            AxisMarks(values: .automatic) { value in
                AxisGridLine()
                AxisTick()
                AxisValueLabel {
                    if let date = value.as(Date.self) {
                        Text(formatDateForAxis(date))
                            .font(.caption)
                    }
                }
            }
        }
        .chartYAxis {
            AxisMarks(position: .leading) { value in
                AxisGridLine()
                AxisTick()
                AxisValueLabel {
                    if let weight = value.as(Double.self) {
                        Text(String(format: "%.1f", weight))
                            .font(.caption)
                    }
                }
            }
        }
        .frame(height: 300)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(radius: 2)
    }


    private func formatDateForAxis(_ date: Date) -> String {
        let formatter = DateFormatter()
        switch selectedPeriod {
        case .oneMonth:
            formatter.dateFormat = "M/d"
        case .oneYear:
            formatter.dateFormat = "M月"
        case .allTime:
            if Calendar.current.dateInterval(of: .year, for: date) != nil {
                formatter.dateFormat = "yy年"
            } else {
                formatter.dateFormat = "M/d"
            }
        }
        return formatter.string(from: date)
    }
}


#Preview {
    WeightGraphView()
        .environmentObject({
            let store = WeightStore()
            // Add some sample data for preview
            let calendar = Calendar.current
            for i in 0..<30 {
                if let date = calendar.date(byAdding: .day, value: -i, to: Date()) {
                    let weight = 70.0 + Double.random(in: -5...5)
                    let entry = WeightEntry(weight: weight, date: date)
                    _ = store.addEntry(entry)
                }
            }
            return store
        }())
}
