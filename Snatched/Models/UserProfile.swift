import Foundation

struct UserProfile: Codable {
    var weight: Double
    var dateUpdated: Date
    
    init(weight: Double = 0) {
        self.weight = weight
        self.dateUpdated = Date()
    }
    
    mutating func updateWeight(_ newWeight: Double) {
        self.weight = newWeight
        self.dateUpdated = Date()
    }
} 