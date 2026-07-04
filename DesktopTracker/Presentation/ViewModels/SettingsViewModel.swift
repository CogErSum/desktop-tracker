import Foundation
import SwiftUI

@Observable
class SettingsViewModel {
    var apiBaseURL: String
    var memberId: String
    var showMenuBarIcon: Bool
    
    init() {
        self.apiBaseURL = UserDefaults.standard.string(forKey: "apiBaseURL") ?? "https://timetracker.karkach.tech"
        self.memberId = UserDefaults.standard.string(forKey: "memberId") ?? "6a100df28c8a4d38a17c0c5f"
        self.showMenuBarIcon = UserDefaults.standard.bool(forKey: "showMenuBarIcon")
    }
    
    func save() {
        UserDefaults.standard.set(apiBaseURL, forKey: "apiBaseURL")
        UserDefaults.standard.set(memberId, forKey: "memberId")
        UserDefaults.standard.set(showMenuBarIcon, forKey: "showMenuBarIcon")
    }
}