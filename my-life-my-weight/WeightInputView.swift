import SwiftUI

struct WeightInputView: View {
    @EnvironmentObject var weightStore: WeightStore
    @State private var selectedWeight: Double = 60.0
    @State private var selectedDate = Date()
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var alertTitle = ""
    @State private var hasAppeared = false

    private let weightRange: ClosedRange<Double> = 30.0...200.0
    private let weightStep: Double = 0.1


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
                    WeightPickerView(selectedWeight: $selectedWeight, range: weightRange)
                        .padding(.vertical, 20)
                }


                Section {
                    Button("保存") {
                        saveWeight()
                    }
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(Color.accentColor)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .disabled(!isValidWeight)
                    .opacity(isValidWeight ? 1.0 : 0.6)
                }
                .listRowBackground(Color.clear)
                .listRowInsets(EdgeInsets())
                .padding(.horizontal)

            }
            .navigationBarHidden(true)
            .onAppear {
                if !hasAppeared {
                    setupInitialWeight()
                    hasAppeared = true
                }
            }
            .alert(alertTitle, isPresented: $showingAlert) {
                Button("OK") { }
            } message: {
                Text(alertMessage)
            }
        }
    }

    private var isValidWeight: Bool {
        selectedWeight >= weightRange.lowerBound && selectedWeight <= weightRange.upperBound
    }

    private func setupInitialWeight() {
        if let latestEntry = weightStore.latestEntry {
            selectedWeight = latestEntry.weight
        } else {
            selectedWeight = 60.0
        }
    }

    private func saveWeight() {
        let entry = WeightEntry(weight: selectedWeight, date: selectedDate)

        if let existingEntry = weightStore.existingEntry(for: selectedDate) {
            weightStore.addEntry(entry)
            showAlert(title: "完了", message: "記録を更新しました")
        } else {
            weightStore.addEntry(entry)
            showAlert(title: "完了", message: "体重を記録しました")
        }

        selectedDate = Date()
    }

    private func showAlert(title: String, message: String) {
        alertTitle = title
        alertMessage = message
        showingAlert = true
    }
}

struct WeightPickerView: View {
    @Binding var selectedWeight: Double
    let range: ClosedRange<Double>

    var body: some View {
        HStack(spacing: 0) {
            Picker("", selection: Binding(
                get: { Int(selectedWeight) },
                set: { newValue in
                    let decimal = selectedWeight.truncatingRemainder(dividingBy: 1)
                    selectedWeight = Double(newValue) + decimal
                }
            )) {
                ForEach(Int(range.lowerBound)...Int(range.upperBound), id: \.self) { value in
                    Text("\(value)")
                        .font(.title2)
                        .tag(value)
                }
            }
            .pickerStyle(.wheel)
            .frame(width: 80)
            .clipped()

            Text(".")
                .font(.title2)
                .fontWeight(.semibold)
                .padding(.horizontal, 8)

            Picker("", selection: Binding(
                get: { Int((selectedWeight * 10).rounded()) % 10 },
                set: { newValue in
                    let integerPart = Int(selectedWeight)
                    selectedWeight = Double(integerPart) + Double(newValue) / 10.0
                }
            )) {
                ForEach(0...9, id: \.self) { value in
                    Text("\(value)")
                        .font(.title2)
                        .tag(value)
                }
            }
            .pickerStyle(.wheel)
            .frame(width: 60)
            .clipped()

            Text("kg")
                .font(.title2)
                .fontWeight(.medium)
                .foregroundStyle(.secondary)
                .padding(.leading, 8)
        }
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemGray6))
        )
    }
}

#Preview {
    let store = WeightStore()
    store.entries = [
        WeightEntry(weight: 65.5, date: Calendar.current.date(byAdding: .day, value: -1, to: Date()) ?? Date())
    ]

    return WeightInputView()
        .environmentObject(store)
}