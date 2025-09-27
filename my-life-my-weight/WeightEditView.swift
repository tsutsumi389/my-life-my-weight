import SwiftUI

struct WeightEditView: View {
    @EnvironmentObject var weightStore: WeightStore
    @Environment(\.dismiss) private var dismiss

    @State private var weightText: String
    @State private var selectedDate: Date
    @State private var note: String
    @State private var showingAlert = false
    @State private var alertMessage = ""

    private let entry: WeightEntry

    init(entry: WeightEntry) {
        self.entry = entry
        self._weightText = State(initialValue: String(format: "%.1f", entry.weight))
        self._selectedDate = State(initialValue: entry.date)
        self._note = State(initialValue: entry.note)
    }

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("体重")) {
                    HStack {
                        Text("体重")
                        Spacer()
                        TextField("0.0", text: $weightText)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                        Text("kg")
                    }

                    DatePicker("日時", selection: $selectedDate, displayedComponents: [.date, .hourAndMinute])
                }

                Section(header: Text("メモ（任意）")) {
                    TextField("メモを入力", text: $note, axis: .vertical)
                        .lineLimit(3...6)
                }

                Section {
                    Button("保存") {
                        saveChanges()
                    }
                    .frame(maxWidth: .infinity)
                    .disabled(weightText.isEmpty)

                    Button("削除", role: .destructive) {
                        deleteEntry()
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .navigationTitle("記録編集")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("キャンセル") {
                        dismiss()
                    }
                }
            }
            .alert("エラー", isPresented: $showingAlert) {
                Button("OK") {
                    if alertMessage == "記録を更新しました" || alertMessage == "記録を削除しました" {
                        dismiss()
                    }
                }
            } message: {
                Text(alertMessage)
            }
        }
    }

    private func saveChanges() {
        guard let weight = Double(weightText) else {
            showAlert(message: "正しい数値を入力してください")
            return
        }

        guard weight > 0 && weight <= 500 else {
            showAlert(message: "体重は0kgより大きく、500kg以下で入力してください")
            return
        }

        var updatedEntry = entry
        updatedEntry.weight = weight
        updatedEntry.date = selectedDate
        updatedEntry.note = note

        weightStore.updateEntry(updatedEntry)
        showAlert(message: "記録を更新しました")
    }

    private func deleteEntry() {
        weightStore.deleteEntry(entry)
        showAlert(message: "記録を削除しました")
    }

    private func showAlert(message: String) {
        alertMessage = message
        showingAlert = true
    }
}

#Preview {
    let entry = WeightEntry(weight: 70.5, date: Date(), note: "朝食前")
    return WeightEditView(entry: entry)
        .environmentObject(WeightStore())
}