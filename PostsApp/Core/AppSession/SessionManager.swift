import Foundation

final class SessionManager: SessionManagerProtocol {
    
    static let shared = SessionManager()
    private init() {}
    
    private enum Key {
        static let isLoggedIn = "com.postapp.session.isLoggedIn"
        static let cachedEmail = "com.postapp.session.cachedEmail"
    }
    
    var isLoggedIn: Bool {
        UserDefaults.standard.bool(forKey: Key.isLoggedIn)
    }
    
    var cachedEmail: String? {
        UserDefaults.standard.string(forKey: Key.cachedEmail)
    }
    
    func saveSession(email: String) {
        UserDefaults.standard.set(true, forKey: Key.isLoggedIn)
        UserDefaults.standard.set(email, forKey: Key.cachedEmail)
    }
    
    func clearSession() {
        UserDefaults.standard.removeObject(forKey: Key.isLoggedIn)
        UserDefaults.standard.removeObject(forKey: Key.cachedEmail)
        DatabaseService().clearAllData()
    }
    
    func getCurrentSession() -> String? {
        return cachedEmail
    }
}

