import Foundation

enum DashboardEndpoint: Endpoint {
    case get(memberId: String)
    case dailyStats(memberId: String, startDate: String, endDate: String)
    case weeklyStats(memberId: String, startDate: String, endDate: String)
    
    var path: String {
        switch self {
        case .get(let memberId):
            return "/api/dashboard/\(memberId)"
        case .dailyStats(let memberId, _, _):
            return "/api/dashboard/\(memberId)/daily"
        case .weeklyStats(let memberId, _, _):
            return "/api/dashboard/\(memberId)/weekly"
        }
    }
    
    var method: String { "GET" }
    
    var body: [String: Any]? { nil }
}
