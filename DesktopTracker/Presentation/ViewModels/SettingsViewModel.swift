import Foundation
import SwiftUI

@Observable
class SettingsViewModel {
    var apiBaseURL: String
    var memberId: String
    var showMenuBarIcon: Bool
    
    init() {
        self.apiBaseURL = UserDefaults.standard.string(forKey: "apiBaseURL") ?? "http://localhost:8000"
        self.memberId = UserDefaults.standard.string(forKey: "memberId") ?? "test-user-1"
        self.showMenuBarIcon = UserDefaults.standard.bool(forKey: "showMenuBarIcon")
    }
    
    func save() {
        UserDefaults.standard.set(apiBaseURL, forKey: "apiBaseURL")
        UserDefaults.standard.set(memberId, forKey: "memberId")
        UserDefaults.standard.set(showMenuBarIcon, forKey: "showMenuBarIcon")
    }
}