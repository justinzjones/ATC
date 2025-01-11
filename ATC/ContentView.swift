//
//  ContentView.swift
//  ATC
//
//  Created by Justin Jones on 12/31/24.
//

import SwiftUI

struct ContentView: View {
    @State private var showingSettings = false
    @State private var settings = ATCSettings.shared
    
    var body: some View {
        NavigationStack {
            TrainingView()
                .navigationTitle("ATC Training")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button {
                            showingSettings = true
                        } label: {
                            Image(systemName: "ellipsis.circle")
                                .foregroundStyle(.blue)
                        }
                    }
                }
                .sheet(isPresented: $showingSettings) {
                    SettingsView()
                }
        }
    }
}

#Preview {
    ContentView()
}
