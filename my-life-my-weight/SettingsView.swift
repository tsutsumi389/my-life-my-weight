import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var weightStore: WeightStore
    @State private var showingDeleteConfirmation = false
    @State private var showingImportSheet = false
    @State private var importText = ""
    @State private var importResult: (imported: Int, updated: Int)? = nil
    @State private var importError: String? = nil

    var body: some View {
        NavigationView {
            List {
                Section {
                    Button {
                        showingImportSheet = true
                    } label: {
                        HStack {
                            Image(systemName: "square.and.arrow.down")
                            Text("データをインポート")
                        }
                    }

                    Button(role: .destructive) {
                        showingDeleteConfirmation = true
                    } label: {
                        HStack {
                            Image(systemName: "trash")
                            Text("全期間のデータを削除")
                        }
                    }
                } header: {
                    Text("データ管理")
                } footer: {
                    Text("この操作は元に戻すことができません。")
                }
            }
        }
        .alert("全期間のデータを削除", isPresented: $showingDeleteConfirmation) {
            Button("キャンセル", role: .cancel) { }
            Button("削除", role: .destructive) {
                weightStore.deleteAllEntries()
            }
        } message: {
            Text("全ての体重データが削除されます。この操作は元に戻すことができません。")
        }
        .sheet(isPresented: $showingImportSheet) {
            importSheetView
        }
    }

    private var importSheetView: some View {
        NavigationView {
            VStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("データ形式")
                        .font(.headline)
                    Text("yyyy/MM/dd 99.9 の形式で1行ずつ入力してください")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("例: 2024/01/15 65.2")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                TextEditor(text: $importText)
                    .border(Color.gray.opacity(0.3))
                    .frame(minHeight: 200)

                if let error = importError {
                    Text(error)
                        .foregroundColor(.red)
                        .font(.caption)
                }

                if let result = importResult {
                    VStack {
                        Text("インポート完了")
                            .font(.headline)
                            .foregroundColor(.green)
                        Text("新規追加: \(result.imported)件, 更新: \(result.updated)件")
                            .font(.caption)
                    }
                }

                Spacer()
            }
            .padding()
            .navigationTitle("データインポート")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("キャンセル") {
                        showingImportSheet = false
                        resetImportState()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("インポート") {
                        performImport()
                    }
                    .disabled(importText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }

    private func resetImportState() {
        importText = ""
        importResult = nil
        importError = nil
    }

    private func performImport() {
        importError = nil
        importResult = nil

        let lines = importText.components(separatedBy: .newlines)
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }

        var entries: [WeightEntry] = []
        var lineNumber = 0

        for line in lines {
            lineNumber += 1
            guard let entry = parseWeightEntry(from: line) else {
                importError = "\(lineNumber)行目の形式が正しくありません: \(line)"
                return
            }
            entries.append(entry)
        }

        if entries.isEmpty {
            importError = "有効なデータが見つかりませんでした"
            return
        }

        let result = weightStore.importEntries(entries)
        importResult = result

        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            showingImportSheet = false
            resetImportState()
        }
    }

    private func parseWeightEntry(from line: String) -> WeightEntry? {
        let components = line.components(separatedBy: " ")
        guard components.count == 2 else { return nil }

        let dateString = components[0]
        let weightString = components[1]

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy/MM/dd"

        guard let date = dateFormatter.date(from: dateString),
              let weight = Double(weightString) else {
            return nil
        }

        return WeightEntry(weight: weight, date: date)
    }
}

#Preview {
    SettingsView()
        .environmentObject(WeightStore())
}
