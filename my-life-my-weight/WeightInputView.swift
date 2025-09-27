import SwiftUI

struct WeightInputView: View {
    @EnvironmentObject var weightStore: WeightStore
    @State private var weightText = ""
    @State private var selectedDate = Date()
    @State private var showingAlert = false
    @State private var alertMessage = ""

    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd"
        formatter.locale = Locale(identifier: "ja_JP")
        return formatter
    }

    var body: some View {
        NavigationView {
            Form {
                Section {
                    VStack(spacing: 12) {
                        Text(dateFormatter.string(from: selectedDate))
                            .font(.title2)
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)

                        DatePicker("", selection: $selectedDate, displayedComponents: [.date])
                            .datePickerStyle(.compact)
                            .labelsHidden()
                            .environment(\.locale, Locale(identifier: "ja_JP"))
                    }
                    .padding(.vertical, 8)
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