import Foundation
import SwiftUI

@Observable
class SettingsViewModel {
    var apiBaseURL: String
    var showMenuBarIcon: Bool
    
    init() {
        self.apiBaseURL = UserDefaults.standard.string(forKey: "apiBaseURL") ?? "https://timetracker.karkach.tech"
        self.showMenuBarIcon = UserDefaults.standard.bool(forKey: "showMenuBarIcon")
    }
    
    func save() {
        UserDefaults.standard.set(apiBaseURL, forKey: "apiBaseURL")
        UserDefaults.standard.set(showMenuBarIcon, forKey: "showMenuBarIcon")
    }
    
    func signOut() {
        UserDefaults.standard.removeObject(forKey: "memberId")
        UserDefaults.standard.removeObject(forKey: "apiBaseURL")
        UserDefaults.standard.removeObject(forKey: "showMenuBarIcon")
    }
}
