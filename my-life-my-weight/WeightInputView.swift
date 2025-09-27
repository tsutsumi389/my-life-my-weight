import SwiftUI

struct WeightInputView: View {
    @EnvironmentObject var weightStore: WeightStore
    @State private var weightText = ""
    @State private var selectedDate = Date()
    @State private var showingAlert = false
    @State private var alertMessage = ""

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("体重記録")) {
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
                    Button("記録する") {
                        saveWeight()
                    }
                    .frame(maxWidth: .infinity)
                    .disabled(weightText.isEmpty)
                }

                if let latestEntry = weightStore.latestEntry {
                    Section(header: Text("最新記録")) {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text("体重")
                                Spacer()
                                Text(latestEntry.formattedWeight)
                                    .fontWeight(.semibold)
                            }

                            HStack {
                                Text("記録日付")
                                Spacer()
                                Text(latestEntry.formattedDate)
                                    .foregroundStyle(.secondary)
                            }

                            if let difference = weightStore.weightDifference {
                                HStack {
                                    Text("前回との差")
                                    Spacer()
                                    Text(String(format: "%+.1f kg", difference))
                                        .foregroundStyle(difference > 0 ? .red : difference < 0 ? .blue : .primary)
                                        .fontWeight(.medium)
                                }
                            }

                        }
                    }
                }
            }
            .navigationTitle("体重記録")
            .alert("エラー", isPresented: $showingAlert) {
                Button("OK") { }
            } message: {
                Text(alertMessage)
            }
        }
    }

    private func saveWeight() {
        guard let weight = Double(weightText) else {
            showAlert(message: "正しい数値を入力してください")
            return
        }

        guard weight > 0 && weight <= 500 else {
            showAlert(message: "体重は0kgより大きく、500kg以下で入力してください")
            return
        }

        let entry = WeightEntry(weight: weight, date: selectedDate)

        if let existingEntry = weightStore.existingEntry(for: selectedDate) {
            showAlert(message: "この日付には既に記録があります。記録を更新しました。")
        } else {
            showAlert(message: "体重を記録しました")
        }

        weightStore.addEntry(entry)

        weightText = ""
        selectedDate = Date()
    }

    private func showAlert(message: String) {
        alertMessage = message
        showingAlert = true
    }
}

#Preview {
    WeightInputView()
        .environmentObject(WeightStore())
}