//
//  StreakManager.swift
//  Snatched
//

import Foundation

class StreakManager: ObservableObject {
    static let shared = StreakManager()
    @Published var streaks: [WorkoutStreak] = []
    
    private let streaksKey = "workout_streaks"
    
    init() {
        loadStreaks()
    }
    
    func saveWorkout(_ workout: WorkoutStreak) {
        streaks.append(workout)
        saveStreaks()
    }
    
    private func loadStreaks() {
        if let data = UserDefaults.standard.data(forKey: streaksKey),
           let decoded = try? JSONDecoder().decode([WorkoutStreak].self, from: data) {
            streaks = decoded
        }
    }
    
    private func saveStreaks() {
        if let encoded = try? JSONEncoder().encode(streaks) {
            UserDefaults.standard.set(encoded, forKey: streaksKey)
        }
    }
    
    func getConsecutiveDays() -> Int {
        let calendar = Calendar.current
        let sortedStreaks = streaks.sorted { $0.date > $1.date }
        var consecutiveDays = 0
        
        guard let lastWorkout = sortedStreaks.first else { return 0 }
        var currentDate = calendar.startOfDay(for: lastWorkout.date)
        
        for streak in sortedStreaks {
            let workoutDate = calendar.startOfDay(for: streak.date)
            if calendar.isDate(currentDate, equalTo: workoutDate, toGranularity: .day) {
                // Same day, continue
                continue
            } else if calendar.isDate(currentDate, equalTo: calendar.date(byAdding: .day, value: -1, to: workoutDate)!, toGranularity: .day) {
                // Previous day, increment streak
                consecutiveDays += 1
                currentDate = workoutDate
            } else {
                // Streak broken
                break
            }
        }
        
        return consecutiveDays + 1 // Add 1 for the current day
    }
} 