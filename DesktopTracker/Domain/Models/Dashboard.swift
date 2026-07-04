import Foundation

struct DashboardData: Codable {
    let todaySec: Int
    let weekSec: Int
    let monthSec: Int
    let recentRecords: [TimeRecord]
    
    enum CodingKeys: String, CodingKey {
        case todaySec = "today_sec"
        case weekSec = "week_sec"
        case monthSec = "month_sec"
        case recentRecords = "recent_records"
    }
}

struct DailyStats: Identifiable {
    let id = UUID()
    let date: Date
    let totalSeconds: Int
}

struct WeeklyStats: Identifiable {
    let id = UUID()
    let weekStart: Date
    let totalSeconds: Int
}
