import SwiftUI

struct WeightHistoryView: View {
    @EnvironmentObject var weightStore: WeightStore
    @State private var showingEditSheet = false
    @State private var editingEntry: WeightEntry?

    var body: some View {
        NavigationView {
            Group {
                if weightStore.entries.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "chart.line.uptrend.xyaxis")
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
                } else {
                    List {
                        ForEach(weightStore.entries) { entry in
                            WeightHistoryRow(entry: entry) {
                                editingEntry = entry
                                showingEditSheet = true
                            }
                        }
                        .onDelete(perform: weightStore.deleteEntry)
                    }
                }
            }
            .navigationTitle("履歴")
            .toolbar {
                if !weightStore.entries.isEmpty {
                    EditButton()
                }
            }
            .sheet(isPresented: $showingEditSheet) {
                if let entry = editingEntry {
                    WeightEditView(entry: entry)
                        .environmentObject(weightStore)
                }
            }
        }
    }
}

struct WeightHistoryRow: View {
    let entry: WeightEntry
    let onEdit: () -> Void

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(entry.formattedWeight)
                        .font(.title2)
                        .fontWeight(.semibold)

                    Spacer()

                    Text(entry.shortDateString)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Text(entry.formattedDate)
                    .font(.caption)
                    .foregroundStyle(.secondary)

            }

            Spacer()

            Button(action: onEdit) {
                Image(systemName: "pencil")
                    .foregroundStyle(.blue)
            }
            .buttonStyle(BorderlessButtonStyle())
        }
        .padding(.vertical, 4)
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