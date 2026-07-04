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

struct DailyStats: Identifiable, Codable {
    let id: UUID
    let date: Date
    let totalSeconds: Int
    
    init(id: UUID = UUID(), date: Date, totalSeconds: Int) {
        self.id = id
        self.date = date
        self.totalSeconds = totalSeconds
    }
}

struct WeeklyStats: Identifiable, Codable {
    let id: UUID
    let weekStart: Date
    let totalSeconds: Int
    
    init(id: UUID = UUID(), weekStart: Date, totalSeconds: Int) {
        self.id = id
        self.weekStart = weekStart
        self.totalSeconds = totalSeconds
    }
}

struct EstimateResponse: Codable {
    let estimatedMin: Int?
    
    enum CodingKeys: String, CodingKey {
        case estimatedMin = "estimated_min"
    }
}

struct SearchResult: Identifiable, Codable {
    let id: String
    let name: String
    let boardName: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case boardName = "board_name"
    }
}
