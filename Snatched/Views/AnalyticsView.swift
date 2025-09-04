import SwiftUI

struct AnalyticsView: View {
    @StateObject private var viewModel = AnalyticsViewModel()
    @State private var showingPaywall = false
    @Environment(\.dismiss) private var dismiss
    
    // Mock premium status - replace with your actual premium check
    @State private var isPremiumUser = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                if isPremiumUser {
                    // Premium Analytics Content
                    premiumContent
                } else {
                    // Paywall Preview
                    paywallPreview
                }
            }
            .navigationTitle("Analytics")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
        .sheet(isPresented: $showingPaywall) {
            PaywallView(isPremiumUser: $isPremiumUser)
        }
    }
    
    // MARK: - Premium Content
    
    @ViewBuilder
    private var premiumContent: some View {
        if viewModel.isLoading {
            ProgressView("Analyzing your workouts...")
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding()
        } else if let analytics = viewModel.analyticsData {
            LazyVStack(spacing: 20) {
                // Overall Stats Section
                overallStatsSection(analytics.overallStats)
                
                // Weekly Stats Section
                weeklyStatsSection(analytics.weeklyStats)
                
                // Monthly Stats Section
                monthlyStatsSection(analytics.monthlyStats)
                
                // Charts Section
                chartsSection
                
                // Workout Type Breakdown
                workoutTypeSection
                
                // Recent Workouts
                recentWorkoutsSection(analytics.recentWorkouts)
            }
            .padding()
        } else {
            Text("No workout data available")
                .foregroundColor(.secondary)
                .padding()
        }
    }
    
    // MARK: - Paywall Preview
    
    private var paywallPreview: some View {
        VStack(spacing: 24) {
            // Header
            VStack(spacing: 12) {
                Image(systemName: "chart.line.uptrend.xyaxis")
                    .font(.system(size: 60))
                    .foregroundColor(.purple)
                
                Text("Unlock Advanced Analytics")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text("Get detailed insights into your workout progress")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.top, 40)
            
            // Preview Cards (Blurred)
            VStack(spacing: 16) {
                previewCard(title: "Weekly Progress", icon: "calendar")
                previewCard(title: "Calorie Trends", icon: "flame.fill")
                previewCard(title: "Performance Insights", icon: "chart.bar.fill")
                previewCard(title: "Streak Analytics", icon: "chart.line.uptrend.xyaxis")
            }
            .blur(radius: 3)
            .overlay(
                VStack {
                    Spacer()
                    
                    Button {
                        showingPaywall = true
                    } label: {
                        Text("Unlock Analytics")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                LinearGradient(
                                    colors: [.purple, .blue],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(12)
                            .shadow(color: .purple.opacity(0.3), radius: 8, x: 0, y: 4)
                    }
                    .padding(.horizontal, 40)
                    
                    Spacer()
                }
            )
            
            Spacer()
        }
        .padding()
    }
    
    private func previewCard(title: String, icon: String) -> some View {
        HStack {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.purple)
            
            VStack(alignment: .leading) {
                Text(title)
                    .font(.headline)
                Text("Premium feature")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Text("📊")
                .font(.title)
        }
        .padding()
        .background(Color.purple.opacity(0.1))
        .cornerRadius(12)
    }
    
    // MARK: - Analytics Sections
    
    private func overallStatsSection(_ stats: OverallStats) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Overall Progress")
                .font(.title2)
                .fontWeight(.bold)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                statCard("Total Workouts", value: "\(stats.totalWorkouts)", icon: "figure.run")
                statCard("Calories Burned", value: String(format: "%.0f", stats.totalCaloriesBurned), icon: "flame.fill")
                statCard("Total Steps", value: "\(stats.totalSteps)", icon: "figure.walk")
                statCard("Current Streak", value: "\(stats.longestStreak) days", icon: "calendar")
            }
        }
        .padding()
        .background(Color.purple.opacity(0.1))
        .cornerRadius(15)
    }
    
    private func weeklyStatsSection(_ stats: WeeklyStats) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("This Week")
                .font(.title2)
                .fontWeight(.bold)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                statCard("Workouts", value: "\(stats.workoutCount)", icon: "calendar.badge.plus")
                statCard("Avg Calories", value: String(format: "%.0f", stats.averageCaloriesPerWorkout), icon: "flame")
                statCard("Total Steps", value: "\(stats.totalSteps)", icon: "figure.walk")
                statCard("Most Active", value: stats.mostActiveDay, icon: "star.fill")
            }
        }
        .padding()
        .background(Color.blue.opacity(0.1))
        .cornerRadius(15)
    }
    
    private func monthlyStatsSection(_ stats: MonthlyStats) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("This Month")
                .font(.title2)
                .fontWeight(.bold)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                statCard("Workouts", value: "\(stats.workoutCount)", icon: "calendar")
                statCard("Avg/Week", value: String(format: "%.1f", stats.averageWorkoutsPerWeek), icon: "chart.bar")
                statCard("Calories", value: String(format: "%.0f", stats.totalCalories), icon: "flame.fill")
                statCard("Streak Days", value: "\(stats.streakDays)", icon: "calendar.badge.checkmark")
            }
        }
        .padding()
        .background(Color.green.opacity(0.1))
        .cornerRadius(15)
    }
    
    private var chartsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Trends (Last 30 Days)")
                .font(.title2)
                .fontWeight(.bold)
            
            // Simple bar chart representation
            VStack(spacing: 12) {
                Text("Daily Calories")
                    .font(.headline)
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 4) {
                        ForEach(viewModel.calorieChartData.suffix(14)) { point in
                            VStack {
                                Rectangle()
                                    .fill(Color.purple.opacity(0.7))
                                    .frame(width: 20, height: max(point.value / 10, 2))
                                
                                Text(point.label)
                                    .font(.caption2)
                                    .rotationEffect(.degrees(-45))
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                .frame(height: 120)
            }
        }
        .padding()
        .background(Color.orange.opacity(0.1))
        .cornerRadius(15)
    }
    
    private var workoutTypeSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Workout Breakdown")
                .font(.title2)
                .fontWeight(.bold)
            
            ForEach(viewModel.workoutTypeBreakdown) { breakdown in
                HStack {
                    Image(systemName: breakdown.workoutType == .stairMaster ? "figure.stair.stepper" : "figure.run")
                        .foregroundColor(.purple)
                    
                    VStack(alignment: .leading) {
                        Text(breakdown.workoutType == .stairMaster ? "Stair Master" : "Treadmill")
                            .font(.headline)
                        Text("\(breakdown.count) workouts • \(String(format: "%.0f", breakdown.totalCalories)) calories")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    Text("\(String(format: "%.0f", breakdown.percentage))%")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.purple)
                }
                .padding()
                .background(Color.purple.opacity(0.05))
                .cornerRadius(8)
            }
        }
        .padding()
        .background(Color.purple.opacity(0.1))
        .cornerRadius(15)
    }
    
    private func recentWorkoutsSection(_ workouts: [WorkoutStreak]) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Recent Workouts")
                .font(.title2)
                .fontWeight(.bold)
            
            ForEach(workouts.prefix(5)) { workout in
                HStack {
                    Image(systemName: workout.workoutType == .stairMaster ? "figure.stair.stepper" : "figure.run")
                        .foregroundColor(.purple)
                    
                    VStack(alignment: .leading) {
                        Text(workout.workoutType == .stairMaster ? "Stair Master" : "Treadmill")
                            .font(.headline)
                        Text(workout.date, style: .date)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing) {
                        Text("\(String(format: "%.0f", workout.caloriesBurned)) cal")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                        Text("\(workout.steps) steps")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.vertical, 8)
                
                if workout.id != workouts.prefix(5).last?.id {
                    Divider()
                }
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(15)
    }
    
    private func statCard(_ title: String, value: String, icon: String) -> some View {
        VStack {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.purple)
            
            Text(value)
                .font(.title3)
                .fontWeight(.bold)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
        .background(Color.white.opacity(0.8))
        .cornerRadius(12)
    }
}

// MARK: - Simple Paywall View

struct PaywallView: View {
    @Binding var isPremiumUser: Bool
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 32) {
                VStack(spacing: 16) {
                    Image(systemName: "chart.line.uptrend.xyaxis.circle.fill")
                        .font(.system(size: 80))
                        .foregroundColor(.purple)
                    
                    Text("Snatched Pro")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("Unlock advanced analytics and insights")
                        .font(.headline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                
                VStack(alignment: .leading, spacing: 16) {
                    featureRow("📊", "Detailed progress charts")
                    featureRow("🔥", "Calorie burn trends")
                    featureRow("📈", "Performance insights")
                    featureRow("⚡", "Streak analytics")
                    featureRow("📤", "Export your data")
                }
                
                VStack(spacing: 12) {
                    Button {
                        // Mock upgrade - replace with actual purchase logic
                        isPremiumUser = true
                        dismiss()
                    } label: {
                        Text("Start Free Trial")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                LinearGradient(
                                    colors: [.purple, .blue],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(12)
                    }
                    
                    Text("7 days free, then $2.99/month")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("Upgrade")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func featureRow(_ icon: String, _ text: String) -> some View {
        HStack {
            Text(icon)
                .font(.title2)
            Text(text)
                .font(.headline)
            Spacer()
        }
    }
}

#Preview {
    AnalyticsView()
}