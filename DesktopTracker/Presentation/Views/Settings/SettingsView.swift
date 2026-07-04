import SwiftUI

struct SettingsView: View {
    @State private var viewModel = SettingsViewModel()
    @State private var saved = false
    
    var body: some View {
        Form {
            Section("API Configuration") {
                TextField("API Base URL", text: $viewModel.apiBaseURL)
                    .textFieldStyle(.roundedBorder)
                
                TextField("Member ID", text: $viewModel.memberId)
                    .textFieldStyle(.roundedBorder)
            }
            
            Section("Appearance") {
                Toggle("Show Menu Bar Icon", isOn: $viewModel.showMenuBarIcon)
            }
            
            if saved {
                Text("Settings saved!")
                    .foregroundColor(.green)
            }
            
            HStack {
                Spacer()
                Button("Save") {
                    viewModel.save()
                    saved = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        saved = false
                    }
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .padding()
        .frame(minWidth: 400, minHeight: 250)
        .navigationTitle("Settings")
    }
}

#Preview {
    SettingsView()
}