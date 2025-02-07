import Foundation

struct WorkoutStreak: Identifiable, Codable {
    let id: UUID
    let date: Date
    let workoutType: WorkoutType
    let steps: Int
    let caloriesBurned: Double
    
    init(workoutType: WorkoutType, steps: Int, caloriesBurned: Double) {
        self.id = UUID()
        self.date = Date()
        self.workoutType = workoutType
        self.steps = steps
        self.caloriesBurned = caloriesBurned
    }
} 