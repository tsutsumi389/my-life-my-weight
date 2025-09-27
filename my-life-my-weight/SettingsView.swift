import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var weightStore: WeightStore
    @State private var showingDeleteConfirmation = false

    var body: some View {
        NavigationView {
            List {
                Section {
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
            .navigationTitle("設定")
        }
        .alert("全期間のデータを削除", isPresented: $showingDeleteConfirmation) {
            Button("キャンセル", role: .cancel) { }
            Button("削除", role: .destructive) {
                weightStore.deleteAllEntries()
            }
        } message: {
            Text("全ての体重データが削除されます。この操作は元に戻すことができません。")
        }
    }
}

#Preview {
    SettingsView()
        .environmentObject(WeightStore())
}