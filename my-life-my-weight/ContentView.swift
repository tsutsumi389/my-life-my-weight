//
//  ContentView.swift
//  my-life-my-weight
//
//  Created by tsutsumi on 2025/09/27.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var weightStore = WeightStore()
    @State private var selectedTab = 0
    @State private var calendarSelectedDate: Date?
    @State private var calendarSelectedWeight: Double?

    var body: some View {
        TabView(selection: $selectedTab) {
            WeightInputView(
                initialDate: calendarSelectedDate,
                initialWeight: calendarSelectedWeight
            )
                .environmentObject(weightStore)
                .tabItem {
                    Label("記録", systemImage: "plus.circle")
                }
                .tag(0)

            WeightGraphView()
                .environmentObject(weightStore)
                .tabItem {
                    Label("グラフ", systemImage: "chart.line.uptrend.xyaxis")
                }
                .tag(1)

            WeightHistoryView(
                onDateSelected: { date, weight in
                    calendarSelectedDate = date
                    calendarSelectedWeight = weight
                    selectedTab = 0 // Navigate to record tab
                }
            )
                .environmentObject(weightStore)
                .tabItem {
                    Label("履歴", systemImage: "list.bullet")
                }
                .tag(2)

            SettingsView()
                .environmentObject(weightStore)
                .tabItem {
                    Label("設定", systemImage: "gearshape")
                }
                .tag(3)
        }
    }
}

#Preview {
    ContentView()
}
