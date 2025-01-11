import SwiftUI

struct AirportSelectionView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var settings: ATCSettings
    
    var body: some View {
        List(settings.airports, id: \.code) { airport in
            Button(action: {
                settings.homeAirport = airport
                dismiss()
            }) {
                HStack {
                    VStack(alignment: .leading) {
                        Text(airport.name)
                            .foregroundStyle(.primary)
                        Text(airport.code)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    
                    Spacer()
                    
                    if airport.code == settings.homeAirport.code {
                        Image(systemName: "checkmark")
                            .foregroundColor(.blue)
                    }
                }
            }
        }
        .navigationTitle("Select Airport")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var settings = ATCSettings.shared
    @State private var tempCallsign: String = ""
    @State private var showingResetAlert = false
    
    var body: some View {
        NavigationView {
            Form {
                aircraftSection
                airportSection
                resetSection
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .alert("Reset Settings", isPresented: $showingResetAlert) {
                Button("Reset", role: .destructive) {
                    resetSettings()
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("This will reset your home airport and generate a new random callsign. Are you sure?")
            }
        }
        .onAppear {
            tempCallsign = settings.aircraftCallsign
        }
    }
    
    private var aircraftSection: some View {
        Section("Aircraft") {
            TextField("Callsign (e.g., N12345)", text: $tempCallsign)
                .textInputAutocapitalization(.characters)
                .onChange(of: tempCallsign) { _, newValue in
                    settings.aircraftCallsign = newValue.uppercased()
                }
            
            Button("Generate Random Callsign") {
                tempCallsign = settings.generateRandomCallsign()
                settings.aircraftCallsign = tempCallsign
            }
        }
    }
    
    private var airportSection: some View {
        Section("Home Airport") {
            NavigationLink {
                AirportSelectionView(settings: settings)
            } label: {
                HStack {
                    Text("Airport")
                    Spacer()
                    Text("\(settings.homeAirport.name) (\(settings.homeAirport.code))")
                        .foregroundStyle(.secondary)
                }
            }
        }
    }
    
    private var resetSection: some View {
        Section {
            Button("Reset to Defaults", role: .destructive) {
                showingResetAlert = true
            }
        }
    }
    
    private func resetSettings() {
        settings.homeAirport = settings.airports[0] // Reset to Denton
        tempCallsign = settings.generateRandomCallsign()
        settings.aircraftCallsign = tempCallsign
    }
}

#Preview {
    SettingsView()
} 