import Foundation

actor APICache {
    static let shared = APICache()
    
    private var cache: [String: (data: Any, timestamp: Date)] = [:]
    private let ttl: TimeInterval = 60
    
    func get<T>(_ key: String) -> T? {
        guard let entry = cache[key], Date().timeIntervalSince(entry.timestamp) < ttl else {
            cache.removeValue(forKey: key)
            return nil
        }
        return entry.data as? T
    }
    
    func set<T>(_ key: String, data: T) {
        cache[key] = (data: data, timestamp: Date())
    }
    
    func invalidate(_ key: String) {
        cache.removeValue(forKey: key)
    }
    
    func invalidateAll() {
        cache.removeAll()
    }
}
