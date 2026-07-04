import Foundation

enum EstimatesEndpoint: Endpoint {
    case get(cardId: String)
    case set(cardId: String, estimateMinutes: Int)
    
    var path: String {
        switch self {
        case .get(let cardId):
            return "/api/estimates/\(cardId)"
        case .set(let cardId, _):
            return "/api/estimates/\(cardId)"
        }
    }
    
    var method: String {
        switch self {
        case .get:
            return "GET"
        case .set:
            return "POST"
        }
    }
    
    var body: [String: Any]? {
        switch self {
        case .set(_, let minutes):
            return ["estimate_minutes": minutes]
        case .get:
            return nil
        }
    }
}
