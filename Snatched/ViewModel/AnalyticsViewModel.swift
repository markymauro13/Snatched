import Foundation
import Combine

class AnalyticsViewModel: ObservableObject {
    @Published var analyticsData: AnalyticsData?
    @Published var isLoading = false
    @Published var calorieChartData: [ChartDataPoint] = []
    @Published var stepChartData: [ChartDataPoint] = []
    @Published var workoutTypeBreakdown: [WorkoutTypeBreakdown] = []
    
    private let streakManager = StreakManager.shared
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        // Listen to streak manager updates
        streakManager.$streaks
            .sink { [weak self] _ in
                self?.generateAnalytics()
            }
            .store(in: &cancellables)
        
        generateAnalytics()
    }
    
    func generateAnalytics() {
        isLoading = true
        
        DispatchQueue.global(qos: .background).async { [weak self] in
            guard let self = self else { return }
            
            let workouts = self.streakManager.streaks
            
            let weeklyStats = self.calculateWeeklyStats(from: workouts)
            let monthlyStats = self.calculateMonthlyStats(from: workouts)
            let overallStats = self.calculateOverallStats(from: workouts)
            let recentWorkouts = Array(workouts.sorted { $0.date > $1.date }.prefix(10))
            
            let analytics = AnalyticsData(
                weeklyStats: weeklyStats,
                monthlyStats: monthlyStats,
                overallStats: overallStats,
                recentWorkouts: recentWorkouts
            )
            
            let calorieData = self.generateCalorieChartData(from: workouts)
            let stepData = self.generateStepChartData(from: workouts)
            let typeBreakdown = self.generateWorkoutTypeBreakdown(from: workouts)
            
            DispatchQueue.main.async {
                self.analyticsData = analytics
                self.calorieChartData = calorieData
                self.stepChartData = stepData
                self.workoutTypeBreakdown = typeBreakdown
                self.isLoading = false
            }
        }
    }
    
    // MARK: - Private Analytics Calculations
    
    private func calculateWeeklyStats(from workouts: [WorkoutStreak]) -> WeeklyStats {
        let calendar = Calendar.current
        let oneWeekAgo = calendar.date(byAdding: .day, value: -7, to: Date()) ?? Date()
        let weekWorkouts = workouts.filter { $0.date >= oneWeekAgo }
        
        let totalCalories = weekWorkouts.reduce(0) { $0 + $1.caloriesBurned }
        let totalSteps = weekWorkouts.reduce(0) { $0 + $1.steps }
        let workoutCount = weekWorkouts.count
        let averageCalories = workoutCount > 0 ? totalCalories / Double(workoutCount) : 0
        
        // Calculate most active day
        let dayFormatter = DateFormatter()
        dayFormatter.dateFormat = "EEEE"
        let dayGroups = Dictionary(grouping: weekWorkouts) { dayFormatter.string(from: $0.date) }
        let mostActiveDay = dayGroups.max { $0.value.count < $1.value.count }?.key ?? "N/A"
        
        // Generate daily breakdown
        let dailyBreakdown = generateDailyBreakdown(from: weekWorkouts)
        
        return WeeklyStats(
            totalCalories: totalCalories,
            totalSteps: totalSteps,
            workoutCount: workoutCount,
            averageCaloriesPerWorkout: averageCalories,
            mostActiveDay: mostActiveDay,
            dailyBreakdown: dailyBreakdown
        )
    }
    
    private func calculateMonthlyStats(from workouts: [WorkoutStreak]) -> MonthlyStats {
        let calendar = Calendar.current
        let oneMonthAgo = calendar.date(byAdding: .month, value: -1, to: Date()) ?? Date()
        let monthWorkouts = workouts.filter { $0.date >= oneMonthAgo }
        
        let totalCalories = monthWorkouts.reduce(0) { $0 + $1.caloriesBurned }
        let totalSteps = monthWorkouts.reduce(0) { $0 + $1.steps }
        let workoutCount = monthWorkouts.count
        let streakDays = streakManager.getConsecutiveDays()
        let averageWorkoutsPerWeek = Double(workoutCount) / 4.0 // Approximate weeks in a month
        
        return MonthlyStats(
            totalCalories: totalCalories,
            totalSteps: totalSteps,
            workoutCount: workoutCount,
            streakDays: streakDays,
            averageWorkoutsPerWeek: averageWorkoutsPerWeek
        )
    }
    
    private func calculateOverallStats(from workouts: [WorkoutStreak]) -> OverallStats {
        let totalWorkouts = workouts.count
        let totalCalories = workouts.reduce(0) { $0 + $1.caloriesBurned }
        let totalSteps = workouts.reduce(0) { $0 + $1.steps }
        let averageCalories = totalWorkouts > 0 ? totalCalories / Double(totalWorkouts) : 0
        
        // Calculate longest streak (simplified - you might want to enhance this)
        let longestStreak = streakManager.getConsecutiveDays()
        
        // Find favorite workout type
        let typeGroups = Dictionary(grouping: workouts) { $0.workoutType }
        let favoriteWorkoutType = typeGroups.max { $0.value.count < $1.value.count }?.key
        
        return OverallStats(
            totalWorkouts: totalWorkouts,
            totalCaloriesBurned: totalCalories,
            totalSteps: totalSteps,
            longestStreak: longestStreak,
            favoriteWorkoutType: favoriteWorkoutType,
            averageCaloriesPerWorkout: averageCalories
        )
    }
    
    private func generateDailyBreakdown(from workouts: [WorkoutStreak]) -> [DayStats] {
        let calendar = Calendar.current
        let dayFormatter = DateFormatter()
        dayFormatter.dateFormat = "EEE"
        
        var dailyStats: [DayStats] = []
        
        for i in 0..<7 {
            let date = calendar.date(byAdding: .day, value: -i, to: Date()) ?? Date()
            let dayWorkouts = workouts.filter { calendar.isDate($0.date, inSameDayAs: date) }
            
            let dayStats = DayStats(
                dayName: dayFormatter.string(from: date),
                date: date,
                calories: dayWorkouts.reduce(0) { $0 + $1.caloriesBurned },
                steps: dayWorkouts.reduce(0) { $0 + $1.steps },
                workoutCount: dayWorkouts.count
            )
            
            dailyStats.append(dayStats)
        }
        
        return dailyStats.reversed() // Show oldest to newest
    }
    
    private func generateCalorieChartData(from workouts: [WorkoutStreak]) -> [ChartDataPoint] {
        let calendar = Calendar.current
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd"
        
        let last30Days = (0..<30).compactMap { calendar.date(byAdding: .day, value: -$0, to: Date()) }
        
        return last30Days.map { date in
            let dayWorkouts = workouts.filter { calendar.isDate($0.date, inSameDayAs: date) }
            let totalCalories = dayWorkouts.reduce(0) { $0 + $1.caloriesBurned }
            
            return ChartDataPoint(
                date: date,
                value: totalCalories,
                label: dateFormatter.string(from: date)
            )
        }.reversed()
    }
    
    private func generateStepChartData(from workouts: [WorkoutStreak]) -> [ChartDataPoint] {
        let calendar = Calendar.current
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd"
        
        let last30Days = (0..<30).compactMap { calendar.date(byAdding: .day, value: -$0, to: Date()) }
        
        return last30Days.map { date in
            let dayWorkouts = workouts.filter { calendar.isDate($0.date, inSameDayAs: date) }
            let totalSteps = dayWorkouts.reduce(0) { $0 + $1.steps }
            
            return ChartDataPoint(
                date: date,
                value: Double(totalSteps),
                label: dateFormatter.string(from: date)
            )
        }.reversed()
    }
    
    private func generateWorkoutTypeBreakdown(from workouts: [WorkoutStreak]) -> [WorkoutTypeBreakdown] {
        let typeGroups = Dictionary(grouping: workouts) { $0.workoutType }
        let totalWorkouts = workouts.count
        
        return typeGroups.map { (type, workouts) in
            let count = workouts.count
            let totalCalories = workouts.reduce(0) { $0 + $1.caloriesBurned }
            let percentage = totalWorkouts > 0 ? (Double(count) / Double(totalWorkouts)) * 100 : 0
            
            return WorkoutTypeBreakdown(
                workoutType: type,
                count: count,
                totalCalories: totalCalories,
                percentage: percentage
            )
        }.sorted { $0.count > $1.count }
    }
}