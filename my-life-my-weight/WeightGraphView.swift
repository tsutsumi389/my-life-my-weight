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

                VStack {
                    if !sortedEntries.isEmpty {
                        Text("表示データ数: \(sortedEntries.count)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .padding(.bottom, 8)
                    }

                    if sortedEntries.isEmpty {
                        emptyChartView
                    } else {
                        chartView
                    }
                }
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

    private var emptyChartView: some View {
        Chart {
            // Empty chart with period-appropriate X axis
        }
        .chartXScale(domain: xAxisRange)
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
            AxisMarks(values: [60, 70, 80, 90]) { value in
                AxisGridLine()
                AxisTick()
                AxisValueLabel {
                    if let weight = value.as(Double.self) {
                        Text(String(format: "%.0f", weight))
                            .font(.caption)
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(radius: 2)
        .overlay(
            VStack(spacing: 16) {
                Image(systemName: "chart.line.uptrend.xyaxis")
                    .font(.system(size: 40))
                    .foregroundColor(.gray)

                Text("この期間にデータがありません")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
        )
        .id(selectedPeriod)
    }

    private var xAxisRange: ClosedRange<Date> {
        let now = Date()
        let calendar = Calendar.current

        switch selectedPeriod {
        case .oneMonth:
            let oneMonthAgo = calendar.date(byAdding: .month, value: -1, to: now) ?? now
            return oneMonthAgo...now
        case .oneYear:
            let oneYearAgo = calendar.date(byAdding: .year, value: -1, to: now) ?? now
            return oneYearAgo...now
        case .allTime:
            if let earliestDate = weightStore.entries.map({ $0.date }).min() {
                return earliestDate...now
            } else {
                let oneYearAgo = calendar.date(byAdding: .year, value: -1, to: now) ?? now
                return oneYearAgo...now
            }
        }
    }

    private var chartView: some View {
        Chart(sortedEntries, id: \.id) { entry in
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
        .chartXScale(domain: xAxisRange)
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
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(radius: 2)
        .animation(.none, value: selectedPeriod)
        .id(selectedPeriod)
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
        .environmentObject(WeightStore())
}
