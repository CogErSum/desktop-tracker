import SwiftUI
import AuthenticationServices

struct LoginView: View {
    let onComplete: (String) -> Void
    
    @State private var loading = false
    @State private var error: String?
    
    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            
            VStack(spacing: 16) {
                Image(systemName: "timer")
                    .font(.system(size: 48))
                    .foregroundColor(Color.tmst.accent)
                
                Text("TeamSight Tracker")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(Color.tmst.textPrimary)
                
                Text("Sign in with Trello to start tracking time")
                    .font(.system(size: 14))
                    .foregroundColor(Color.tmst.textSecondary)
            }
            
            Spacer()
            
            if loading {
                ProgressView("Connecting to Trello...")
            } else {
                Button {
                    Task { await startAuth() }
                } label: {
                    HStack(spacing: 10) {
                        Image(systemName: "person.circle.fill")
                            .font(.system(size: 18))
                        Text("Sign in with Trello")
                            .font(.system(size: 15, weight: .semibold))
                    }
                    .frame(maxWidth: 280)
                }
                .buttonStyle(TMSTButtonStyle())
            }
            
            if let error = error {
                Text(error)
                    .font(.system(size: 12))
                    .foregroundColor(Color.tmst.error)
            }
            
            Spacer()
            
            Text("By signing in, you agree to the Terms of Service")
                .font(.system(size: 11))
                .foregroundColor(Color.tmst.textSecondary)
        }
        .frame(width: 400, height: 400)
        .background(Color.white)
    }
    
    private func startAuth() async {
        loading = true
        error = nil
        
        do {
            let response: AuthStartResponse = try await APIClient.shared.request(AuthEndpoint.start)
            
            if let url = URL(string: response.authorizationUrl) {
                NSWorkspace.shared.open(url)
            }
            
            try await Task.sleep(for: .seconds(2))
            
            for _ in 0..<30 {
                try await Task.sleep(for: .seconds(2))
                let latest: AuthLatestResponse = try await APIClient.shared.request(AuthEndpoint.latest)
                if latest.authorized, let memberId = latest.memberId {
                    onComplete(memberId)
                    return
                }
            }
            
            self.error = "Authorization timeout. Please try again."
        } catch {
            self.error = "Failed to start authorization: \(error.localizedDescription)"
        }
        
        loading = false
    }
}
