import Foundation

enum ExportEndpoint: Endpoint {
    case csv
    case json
    
    var path: String {
        switch self {
        case .csv:
            return "/api/v1/export?format=csv"
        case .json:
            return "/api/v1/export?format=xlsx"
        }
    }
    
    var method: String { "GET" }
    var body: [String: Any]? { nil }
}
