import Foundation

enum RecordsEndpoint: Endpoint {
    case list(memberId: String)
    case create(memberId: String, cardId: String, duration: Int, comment: String?, date: String?)
    case update(id: String, duration: Int?, comment: String?)
    case delete(id: String)
    
    var path: String {
        switch self {
        case .list(let memberId):
            return "/api/records/\(memberId)"
        case .create(let memberId, _, _, _, _):
            return "/api/records/\(memberId)"
        case .update(let id, _, _):
            return "/api/records/\(id)"
        case .delete(let id):
            return "/api/records/\(id)"
        }
    }
    
    var method: String {
        switch self {
        case .list:
            return "GET"
        case .create:
            return "POST"
        case .update:
            return "PUT"
        case .delete:
            return "DELETE"
        }
    }
    
    var body: [String: Any]? {
        switch self {
        case .create(_, let cardId, let duration, let comment, let date):
            var dict: [String: Any] = [
                "trello_card_id": cardId,
                "duration_sec": duration
            ]
            if let comment = comment { dict["comment"] = comment }
            if let date = date { dict["record_date"] = date }
            return dict
        case .update(_, let duration, let comment):
            var dict: [String: Any] = [:]
            if let duration = duration { dict["duration_sec"] = duration }
            if let comment = comment { dict["comment"] = comment }
            return dict
        case .delete, .list:
            return nil
        }
    }
}
