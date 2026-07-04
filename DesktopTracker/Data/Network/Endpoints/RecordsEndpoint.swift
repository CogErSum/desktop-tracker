import Foundation

enum RecordsEndpoint: Endpoint {
    case list
    case create(cardId: String, durationMin: Int, date: String, comment: String?)
    case update(id: String, durationMin: Int?, date: String?, comment: String?)
    case delete(id: String)
    
    var path: String {
        switch self {
        case .list:
            return "/api/v1/records"
        case .create:
            return "/api/v1/records"
        case .update(let id, _, _, _):
            return "/api/v1/records/\(id)"
        case .delete(let id):
            return "/api/v1/records/\(id)"
        }
    }
    
    var method: String {
        switch self {
        case .list:
            return "GET"
        case .create:
            return "POST"
        case .update:
            return "PATCH"
        case .delete:
            return "DELETE"
        }
    }
    
    var body: [String: Any]? {
        switch self {
        case .create(let cardId, let durationMin, let date, let comment):
            var dict: [String: Any] = [
                "card_id": cardId,
                "duration_min": durationMin,
                "date": date
            ]
            if let comment = comment { dict["comment"] = comment }
            return dict
        case .update(_, let durationMin, let date, let comment):
            var dict: [String: Any] = [:]
            if let durationMin = durationMin { dict["duration_min"] = durationMin }
            if let date = date { dict["record_date"] = date }
            if let comment = comment { dict["comment"] = comment }
            return dict
        case .delete, .list:
            return nil
        }
    }
}
