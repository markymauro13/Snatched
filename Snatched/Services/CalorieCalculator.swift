//
//  CalorieCalculator.swift
//  Snatched
//
//  Created by Mark Mauro on 2/5/25.
//

import Foundation

class CalorieCalculator {
    static func calculateCalories(for input: WorkoutInput) -> WorkoutResult {
        var caloriesBurned: Double
        var steps: Int
        
        switch input.workoutType {
        case .stairMaster:
            // Stair master calculations
            steps = Int(input.time * Double(input.levelOrSpeed) * 30)
            caloriesBurned = input.weight * 0.17 * input.time * (input.levelOrSpeed / 10)
            
        case .treadmill:
            // Treadmill calculations including incline
            let baseCaloriesPerMinute = 0.1 * input.weight * (input.levelOrSpeed / 4)
            let inclineFactor = 1 + (input.incline / 100 * 1.5)  // Incline increases calories burned
            caloriesBurned = baseCaloriesPerMinute * input.time * inclineFactor
            
            // Steps calculation (assuming average stride length)
            let stepsPerMile = 2000.0  // Average steps per mile
            let milesPerHour = input.levelOrSpeed
            let hours = input.time / 60
            steps = Int(stepsPerMile * milesPerHour * hours)
        }
        
        return WorkoutResult(steps: steps, caloriesBurned: caloriesBurned)
    }
}
