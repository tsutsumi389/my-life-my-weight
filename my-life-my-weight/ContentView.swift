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
                .id("\(calendarSelectedDate?.timeIntervalSince1970 ?? 0)") // Force recreation when date changes
                .tabItem {
                    Label("記録", systemImage: "plus.circle")
                }
                .tag(0)
                .onChange(of: selectedTab) { oldValue, newValue in
                    // Reset to today's date when switching to the record tab (except from history tab)
                    if newValue == 0 && oldValue != 0 && oldValue != 2 {
                        calendarSelectedDate = nil
                        calendarSelectedWeight = nil
                    }
                }

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
