import Foundation
import SwiftUI

@MainActor
@Observable
class DashboardViewModel {
    private let repository: TimeTrackerRepository
    private var memberId: String
    
    var dashboardData: DashboardData?
    var dailyStats: [DailyStats] = []
    var weeklyStats: [WeeklyStats] = []
    var cardNames: [String: String] = [:]
    var loading = false
    var error: String?
    
    init(repository: TimeTrackerRepository = TimeTrackerRepositoryImpl(), memberId: String? = nil) {
        self.repository = repository
        self.memberId = memberId ?? UserDefaults.standard.string(forKey: "memberId") ?? "6a100df28c8a4d38a17c0c5f"
    }
    
    func loadDashboard() async {
        loading = true
        error = nil
        
        do {
            async let dashboardTask = repository.getDashboard(memberId: memberId)
            let data = try await dashboardTask
            dashboardData = data
            
            if !data.recentRecords.isEmpty {
                let cardIds = Array(Set(data.recentRecords.map { $0.trelloCardId }))
                if !cardIds.isEmpty {
                    async let namesTask = repository.getCardNames(cardIds: cardIds)
                    cardNames = try await namesTask
                }
            }
        } catch {
            print("Dashboard load error: \(error)")
            self.error = "Failed to load dashboard"
        }
        
        loading = false
    }
    
    func loadDailyStats(startDate: Date, endDate: Date) async {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        
        do {
            dailyStats = try await repository.getDailyStats(
                memberId: memberId,
                startDate: formatter.string(from: startDate),
                endDate: formatter.string(from: endDate)
            )
        } catch {
            print("Failed to load daily stats: \(error)")
        }
    }
    
    func loadWeeklyStats(startDate: Date, endDate: Date) async {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        
        do {
            weeklyStats = try await repository.getWeeklyStats(
                memberId: memberId,
                startDate: formatter.string(from: startDate),
                endDate: formatter.string(from: endDate)
            )
        } catch {
            print("Failed to load weekly stats: \(error)")
        }
    }
    
    func cardName(for cardId: String) -> String {
        cardNames[cardId] ?? String(cardId.prefix(8)) + "..."
    }
    
    func formatDuration(_ seconds: Int) -> String {
        let h = seconds / 3600
        let m = (seconds % 3600) / 60
        if h > 0 && m > 0 { return "\(h)h \(m)m" }
        if h > 0 { return "\(h)h" }
        return "\(m)m"
    }
}
