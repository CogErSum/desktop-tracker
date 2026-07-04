import Foundation

enum TimerEndpoint: Endpoint {
    case getActive(memberId: String)
    case start(memberId: String, cardId: String)
    case stop(memberId: String)
    
    var path: String {
        switch self {
        case .getActive(let memberId):
            return "/api/timers/\(memberId)/active"
        case .start(let memberId, _):
            return "/api/timers/\(memberId)/start"
        case .stop(let memberId):
            return "/api/timers/\(memberId)/stop"
        }
    }
    
    var method: String {
        switch self {
        case .getActive:
            return "GET"
        case .start, .stop:
            return "POST"
        }
    }
    
    var body: [String: Any]? {
        switch self {
        case .start(_, let cardId):
            return ["trello_card_id": cardId]
        case .stop:
            return nil
        case .getActive:
            return nil
        }
    }
}
