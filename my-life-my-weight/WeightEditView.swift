import SwiftUI

struct WeightEditView: View {
    @EnvironmentObject var weightStore: WeightStore
    @Environment(\.dismiss) private var dismiss

    @State private var weightText: String
    @State private var selectedDate: Date
    @State private var showingAlert = false
    @State private var alertMessage = ""

    private let entry: WeightEntry

    init(entry: WeightEntry) {
        self.entry = entry
        self._weightText = State(initialValue: String(format: "%.1f", entry.weight))
        self._selectedDate = State(initialValue: entry.date)
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

                    DatePicker("日付", selection: $selectedDate, displayedComponents: [.date])
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

        if weightStore.updateEntry(updatedEntry) {
            showAlert(message: "記録を更新しました")
        } else {
            showAlert(message: "選択した日付には既に別の記録があります")
        }
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
    let entry = WeightEntry(weight: 70.5, date: Date())
    return WeightEditView(entry: entry)
        .environmentObject(WeightStore())
}