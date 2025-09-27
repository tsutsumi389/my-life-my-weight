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
                Section {
                    DatePicker("", selection: $selectedDate, displayedComponents: [.date])
                        .datePickerStyle(.compact)
                        .labelsHidden()
                        .scaleEffect(1.2)
                        .frame(maxWidth: .infinity)
                        .environment(\.locale, Locale(identifier: "ja_JP"))
                        .padding(.vertical, 12)
                }

                Section {
                    HStack {
                        Text("体重")
                        Spacer()
                        TextField("0.0", text: $weightText)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                        Text("kg")
                    }
                }


                Section {
                    Button("記録する") {
                        saveWeight()
                    }
                    .frame(maxWidth: .infinity)
                    .disabled(weightText.isEmpty)
                }

            }
            .navigationTitle("体重記録")
            .onAppear {
                if weightText.isEmpty, let latestEntry = weightStore.latestEntry {
                    weightText = String(format: "%.1f", latestEntry.weight)
                }
            }
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
            weightStore.addEntry(entry)
            showAlert(message: "記録を更新しました")
        } else {
            weightStore.addEntry(entry)
            showAlert(message: "体重を記録しました")
        }

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