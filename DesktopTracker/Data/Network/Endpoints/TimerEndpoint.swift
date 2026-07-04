import Foundation

enum TimerEndpoint: Endpoint {
    case getActive
    case start(cardId: String)
    case stop
    
    var path: String {
        switch self {
        case .getActive:
            return "/api/v1/timers/active"
        case .start:
            return "/api/v1/timers/start"
        case .stop:
            return "/api/v1/timers/stop"
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
        case .start(let cardId):
            return ["card_id": cardId]
        case .stop, .getActive:
            return nil
        }
    }
}
