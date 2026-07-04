import Foundation

enum DashboardEndpoint: Endpoint {
    case get
    
    var path: String {
        switch self {
        case .get:
            return "/api/v1/dashboard"
        }
    }
    
    var method: String { "GET" }
    var body: [String: Any]? { nil }
}
