//
//  WorkoutViewModel.swift
//  Snatched
//
//  Created by Mark Mauro on 2/5/25.
//


import Foundation
import Combine

class WorkoutViewModel: ObservableObject {
    @Published var workoutInput: WorkoutInput
    @Published var workoutResult = WorkoutResult(steps: 0, caloriesBurned: 0)
    
    init(workoutType: WorkoutType) {
        // Initialize with cached weight from profile if available
        let profileManager = ProfileManager.shared
        let cachedWeight = profileManager.hasValidWeight() ? profileManager.userProfile.weight : 0
        
        self.workoutInput = WorkoutInput(
            workoutType: workoutType,
            levelOrSpeed: workoutType == .stairMaster ? 1 : 1.0,
            incline: 0.0,
            time: 0,
            weight: cachedWeight
        )
    }

    func calculateWorkout() {
        // Convert weight from lbs to kg before calculation
        let weightInKg = workoutInput.weight * 0.45359237
        let adjustedInput = WorkoutInput(
            workoutType: workoutInput.workoutType,
            levelOrSpeed: workoutInput.levelOrSpeed,
            incline: workoutInput.incline,
            time: workoutInput.time,
            weight: weightInKg
        )
        workoutResult = CalorieCalculator.calculateCalories(for: adjustedInput)
    }
}
