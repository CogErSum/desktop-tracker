import Foundation

enum ExportEndpoint: Endpoint {
    case csv(memberId: String)
    case json(memberId: String)
    
    var path: String {
        switch self {
        case .csv(let memberId):
            return "/api/export/\(memberId)/csv"
        case .json(let memberId):
            return "/api/export/\(memberId)/json"
        }
    }
    
    var method: String { "GET" }
    var body: [String: Any]? { nil }
}
