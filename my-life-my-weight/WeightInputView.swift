import SwiftUI

struct WeightInputView: View {
    @EnvironmentObject var weightStore: WeightStore
    @State private var selectedWeight: Double = 60.0
    @State private var selectedDate = Date()
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var alertTitle = ""
    @State private var hasAppeared = false

    // Parameters for setting date and weight from external sources (like calendar)
    let initialDate: Date?
    let initialWeight: Double?

    private let weightRange: ClosedRange<Double> = 30.0...200.0
    private let weightStep: Double = 0.1

    init(initialDate: Date? = nil, initialWeight: Double? = nil) {
        self.initialDate = initialDate
        self.initialWeight = initialWeight
    }


    var body: some View {
        NavigationView {
            VStack(spacing: 50) {
                Spacer()

                VStack(spacing: 40) {
                    DatePicker("", selection: $selectedDate, displayedComponents: [.date])
                        .datePickerStyle(.compact)
                        .labelsHidden()
                        .scaleEffect(1.4)
                        .environment(\.locale, Locale(identifier: "ja_JP"))

                    WeightPickerView(selectedWeight: $selectedWeight, range: weightRange)
                }

                Spacer()

                Button(action: {
                    saveWeight()
                }) {
                    Text("保存")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 60)
                }
                .background(Color.accentColor)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .disabled(!isValidWeight)
                .opacity(isValidWeight ? 1.0 : 0.6)
                .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                .padding(.horizontal, 24)
                .padding(.bottom, 50)
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
        // First, set the date if provided from external source (like calendar)
        if let initialDate = initialDate {
            selectedDate = initialDate
        }

        // Then set the weight: priority is initialWeight > existing entry for date > latest entry > default
        if let initialWeight = initialWeight {
            selectedWeight = initialWeight
        } else if let initialDate = initialDate,
                  let existingEntry = weightStore.existingEntry(for: initialDate) {
            selectedWeight = existingEntry.weight
        } else if let latestEntry = weightStore.latestEntry {
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
            Spacer()

            Picker("", selection: Binding(
                get: { Int(selectedWeight) },
                set: { newValue in
                    let decimal = selectedWeight.truncatingRemainder(dividingBy: 1)
                    selectedWeight = Double(newValue) + decimal
                }
            )) {
                ForEach(Int(range.lowerBound)...Int(range.upperBound), id: \.self) { value in
                    Text("\(value)")
                        .font(.largeTitle)
                        .fontWeight(.medium)
                        .tag(value)
                }
            }
            .pickerStyle(.wheel)
            .frame(width: 100)
            .clipped()

            Text(".")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.horizontal, 12)

            Picker("", selection: Binding(
                get: { Int((selectedWeight * 10).rounded()) % 10 },
                set: { newValue in
                    let integerPart = Int(selectedWeight)
                    selectedWeight = Double(integerPart) + Double(newValue) / 10.0
                }
            )) {
                ForEach(0...9, id: \.self) { value in
                    Text("\(value)")
                        .font(.largeTitle)
                        .fontWeight(.medium)
                        .tag(value)
                }
            }
            .pickerStyle(.wheel)
            .frame(width: 80)
            .clipped()

            Text("kg")
                .font(.title)
                .fontWeight(.medium)
                .foregroundStyle(.secondary)
                .padding(.leading, 16)

            Spacer()
        }
        .frame(height: 200)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(.systemGray6))
                .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
        )
        .padding(.horizontal, 20)
    }
}

#Preview {
    let store = WeightStore()
    store.entries = [
        WeightEntry(weight: 65.5, date: Calendar.current.date(byAdding: .day, value: -1, to: Date()) ?? Date())
    ]

    return WeightInputView(initialDate: nil, initialWeight: nil)
        .environmentObject(store)
}