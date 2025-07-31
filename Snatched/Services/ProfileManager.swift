import Foundation
import Combine

class ProfileManager: ObservableObject {
    static let shared = ProfileManager()
    @Published var userProfile: UserProfile
    
    private let profileKey = "user_profile"
    
    init() {
        self.userProfile = UserProfile()
        loadProfile()
    }
    
    func updateWeight(_ weight: Double) {
        userProfile.updateWeight(weight)
        saveProfile()
    }
    
    func hasValidWeight() -> Bool {
        return userProfile.weight > 0
    }
    
    private func loadProfile() {
        if let data = UserDefaults.standard.data(forKey: profileKey),
           let decoded = try? JSONDecoder().decode(UserProfile.self, from: data) {
            userProfile = decoded
        }
    }
    
    private func saveProfile() {
        if let encoded = try? JSONEncoder().encode(userProfile) {
            UserDefaults.standard.set(encoded, forKey: profileKey)
        }
    }
} 