import Foundation

enum EstimatesEndpoint: Endpoint {
    case get(cardId: String)
    case set(cardId: String, estimatedMin: Int, comment: String?)
    case delete(cardId: String)
    
    var path: String {
        switch self {
        case .get(let cardId):
            return "/api/v1/estimates?card_id=\(cardId)"
        case .set:
            return "/api/v1/estimates"
        case .delete(let cardId):
            return "/api/v1/estimates/\(cardId)"
        }
    }
    
    var method: String {
        switch self {
        case .get:
            return "GET"
        case .set:
            return "POST"
        case .delete:
            return "DELETE"
        }
    }
    
    var body: [String: Any]? {
        switch self {
        case .set(let cardId, let estimatedMin, let comment):
            var dict: [String: Any] = [
                "card_id": cardId,
                "estimated_min": estimatedMin
            ]
            if let comment = comment { dict["comment"] = comment }
            return dict
        case .get, .delete:
            return nil
        }
    }
}
