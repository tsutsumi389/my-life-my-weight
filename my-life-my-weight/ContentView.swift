//
//  ContentView.swift
//  my-life-my-weight
//
//  Created by tsutsumi on 2025/09/27.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var weightStore = WeightStore()

    var body: some View {
        TabView {
            WeightInputView()
                .environmentObject(weightStore)
                .tabItem {
                    Label("記録", systemImage: "plus.circle")
                }

            WeightGraphView()
                .environmentObject(weightStore)
                .tabItem {
                    Label("グラフ", systemImage: "chart.line.uptrend.xyaxis")
                }

            WeightHistoryView()
                .environmentObject(weightStore)
                .tabItem {
                    Label("履歴", systemImage: "list.bullet")
                }
        }
    }
}

#Preview {
    ContentView()
}
