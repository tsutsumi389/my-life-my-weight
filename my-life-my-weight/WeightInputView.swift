import SwiftUI

struct WeightInputView: View {
    @EnvironmentObject var weightStore: WeightStore
    @State private var selectedWeight: Double = 60.0
    @State private var selectedDate = Date()
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var alertTitle = ""
    @State private var showingDatePicker = false

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
                    Button(action: {
                        showingDatePicker = true
                    }) {
                        VStack(spacing: 8) {
                            Text(formattedDate)
                                .font(.title)
                                .fontWeight(.semibold)
                                .foregroundStyle(.primary)

                            Text(formattedWeekday)
                                .font(.title3)
                                .foregroundStyle(.secondary)
                        }
                        .padding(.vertical, 16)
                        .frame(maxWidth: .infinity)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color(.systemGray6))
                        )
                    }
                    .padding(.horizontal, 20)

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
                setupInitialWeight()
            }
            .alert(alertTitle, isPresented: $showingAlert) {
                Button("OK") { }
            } message: {
                Text(alertMessage)
            }
            .sheet(isPresented: $showingDatePicker) {
                DatePickerSheet(selectedDate: $selectedDate, isPresented: $showingDatePicker)
            }
        }
    }

    private var isValidWeight: Bool {
        selectedWeight >= weightRange.lowerBound && selectedWeight <= weightRange.upperBound
    }

    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ja_JP")
        formatter.dateFormat = "yyyy年M月d日"
        return formatter.string(from: selectedDate)
    }

    private var formattedWeekday: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ja_JP")
        formatter.dateFormat = "EEEE"
        return formatter.string(from: selectedDate)
    }

    private func setupInitialWeight() {
        // Set the date: use initialDate if provided, otherwise use today
        if let initialDate = initialDate {
            selectedDate = initialDate
        } else {
            selectedDate = Date()
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

        // Only reset date if not set from external source (like calendar)
        if initialDate == nil {
            selectedDate = Date()
        }
    }

    private func showAlert(title: String, message: String) {
        alertTitle = title
        alertMessage = message
        showingAlert = true
    }
}

struct DatePickerSheet: View {
    @Binding var selectedDate: Date
    @Binding var isPresented: Bool
    @State private var tempDate: Date

    init(selectedDate: Binding<Date>, isPresented: Binding<Bool>) {
        self._selectedDate = selectedDate
        self._isPresented = isPresented
        self._tempDate = State(initialValue: selectedDate.wrappedValue)
    }

    var body: some View {
        NavigationView {
            VStack {
                DatePicker("", selection: $tempDate, displayedComponents: [.date])
                    .datePickerStyle(.graphical)
                    .environment(\.locale, Locale(identifier: "ja_JP"))
                    .padding()
                    .onChange(of: tempDate) { oldValue, newValue in
                        // 日付が変更されたら即座にシートを閉じる
                        if oldValue != newValue {
                            selectedDate = newValue
                            isPresented = false
                        }
                    }

                Spacer()
            }
            .navigationTitle("日付を選択")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("キャンセル") {
                        isPresented = false
                    }
                }
            }
        }
        .presentationDetents([.medium])
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