import Foundation

// MARK: - Analytics Data Models

struct AnalyticsData {
    let weeklyStats: WeeklyStats
    let monthlyStats: MonthlyStats
    let overallStats: OverallStats
    let recentWorkouts: [WorkoutStreak]
}

struct WeeklyStats {
    let totalCalories: Double
    let totalSteps: Int
    let workoutCount: Int
    let averageCaloriesPerWorkout: Double
    let mostActiveDay: String
    let dailyBreakdown: [DayStats]
}

struct MonthlyStats {
    let totalCalories: Double
    let totalSteps: Int
    let workoutCount: Int
    let streakDays: Int
    let averageWorkoutsPerWeek: Double
}

struct OverallStats {
    let totalWorkouts: Int
    let totalCaloriesBurned: Double
    let totalSteps: Int
    let longestStreak: Int
    let favoriteWorkoutType: WorkoutType?
    let averageCaloriesPerWorkout: Double
}

struct DayStats: Identifiable {
    let id = UUID()
    let dayName: String
    let date: Date
    let calories: Double
    let steps: Int
    let workoutCount: Int
}

// MARK: - Chart Data Models

struct ChartDataPoint: Identifiable {
    let id = UUID()
    let date: Date
    let value: Double
    let label: String
}

struct WorkoutTypeBreakdown: Identifiable {
    let id = UUID()
    let workoutType: WorkoutType
    let count: Int
    let totalCalories: Double
    let percentage: Double
}