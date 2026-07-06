import SwiftUI

struct SettingsView: View {
    @State private var viewModel = SettingsViewModel()
    @State private var saved = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                headerSection
                settingsContent
            }
            .padding(24)
        }
        .background(Color.tmst.surface.opacity(0.3))
    }
    
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Settings")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(Color.tmst.textPrimary)
            Text("Configure your application preferences")
                .font(.system(size: 14))
                .foregroundColor(Color.tmst.textSecondary)
        }
    }
    
    private var settingsContent: some View {
        VStack(alignment: .leading, spacing: 20) {
            sectionCard(title: "API Configuration", icon: "network") {
                VStack(alignment: .leading, spacing: 12) {
                    fieldLabel("API Base URL")
                    TextField("https://api.example.com", text: $viewModel.apiBaseURL)
                        .textFieldStyle(.plain)
                        .padding(10)
                        .background(Color.tmst.surface)
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.tmst.stroke, lineWidth: 1)
                        )
                    
                    fieldLabel("Member ID")
                    TextField("Enter your member ID", text: $viewModel.memberId)
                        .textFieldStyle(.plain)
                        .padding(10)
                        .background(Color.tmst.surface)
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.tmst.stroke, lineWidth: 1)
                        )
                }
            }
            
            sectionCard(title: "Appearance", icon: "paintbrush") {
                Toggle(isOn: $viewModel.showMenuBarIcon) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Show Menu Bar Icon")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(Color.tmst.textPrimary)
                        Text("Display timer in the menu bar")
                            .font(.system(size: 11))
                            .foregroundColor(Color.tmst.textSecondary)
                    }
                }
                .toggleStyle(.switch)
            }
            
            saveSection
        }
    }
    
    private func sectionCard<Content: View>(title: String, icon: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 14))
                    .foregroundColor(Color.tmst.accent)
                Text(title)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(Color.tmst.textPrimary)
            }
            
            content()
        }
        .padding(20)
        .tmstCard()
    }
    
    private func fieldLabel(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 12, weight: .medium))
            .foregroundColor(Color.tmst.textSecondary)
            .textCase(.uppercase)
    }
    
    private var saveSection: some View {
        HStack {
            if saved {
                HStack(spacing: 6) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(Color.tmst.accent)
                    Text("Settings saved!")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(Color.tmst.accent)
                }
                .transition(.opacity)
            }
            
            Spacer()
            
            Button {
                viewModel.save()
                withAnimation {
                    saved = true
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    withAnimation {
                        saved = false
                    }
                }
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "checkmark")
                    Text("Save Changes")
                }
            }
            .buttonStyle(TMSTButtonStyle())
        }
        .padding(16)
        .tmstCard()
    }
}
