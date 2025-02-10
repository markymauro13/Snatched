import SwiftUI

struct StreakGridView: View {
    @ObservedObject private var streakManager = StreakManager.shared
    @Environment(\.dismiss) private var dismiss
    
    // 7 rows (weeks), showing about 30 weeks
    private let rows = Array(repeating: GridItem(.fixed(12), spacing: 4), count: 7)
    private let weeks = 30
    @State private var scrollPosition: CGPoint = .zero
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header with close button
            HStack {
                Text("\(streakManager.getConsecutiveDays()) Day Streak")
                    .font(.headline)
                    .foregroundColor(.purple)
                Spacer()
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                        .font(.title3)
                }
            }
            
            VStack(alignment: .leading, spacing: 6) {
                // Months row
                HStack(spacing: 0) {
                    ForEach(getMonthLabels(), id: \.self) { month in
                        Text(month)
                            .font(.system(size: 11))
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                
                // Contribution grid
                ScrollView(.horizontal, showsIndicators: false) {
                    LazyHGrid(rows: rows, spacing: 4) {
                        ForEach(0..<(weeks * 7), id: \.self) { index in
                            let startOfMonth = Calendar.current.date(from: Calendar.current.dateComponents([.year, .month], from: Date()))!
                            let date = Calendar.current.date(byAdding: .day, value: index, to: startOfMonth)!
                            ContributionCell(date: date, streaks: streakManager.streaks)
                        }
                    }
                    .padding(.trailing, 20)
                }
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
    }
    
    private func getMonthLabels() -> [String] {
        let calendar = Calendar.current
        let startDate = Date()
        let endDate = calendar.date(byAdding: .day, value: (weeks * 7 - 1), to: startDate)!
        
        var months: [String] = []
        var currentDate = startDate
        
        while currentDate <= endDate {
            let month = calendar.component(.month, from: currentDate)
            if months.isEmpty || month != calendar.component(.month, from: calendar.date(byAdding: .day, value: -1, to: currentDate)!) {
                months.append(calendar.shortMonthSymbols[month - 1])
            }
            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate)!
        }
        
        return months
    }
}

struct ContributionCell: View {
    let date: Date
    let streaks: [WorkoutStreak]
    @State private var isShowingDetails = false
    
    private var workoutsOnDate: [WorkoutStreak] {
        streaks.filter {
            Calendar.current.isDate($0.date, inSameDayAs: date)
        }
    }
    
    private var intensity: Double {
        let count = workoutsOnDate.count
        switch count {
        case 0: return 0.15
        case 1: return 0.4
        case 2: return 0.6
        case 3: return 0.8
        default: return 1.0
        }
    }
    
    var body: some View {
        RoundedRectangle(cornerRadius: 2)
            .fill(workoutsOnDate.isEmpty ? Color.purple.opacity(0.15) : Color.purple.opacity(intensity))
            .frame(width: 12, height: 12)
            .overlay(
                RoundedRectangle(cornerRadius: 2)
                    .stroke(Color.purple.opacity(0.3), lineWidth: 0.5)
            )
            .onTapGesture {
                isShowingDetails = true
            }
            .popover(isPresented: $isShowingDetails) {
                VStack(spacing: 0) {
                    // Header
                    HStack {
                        Text(date.formatted(date: .abbreviated, time: .omitted))
                            .font(.headline)
                        Spacer()
                        Text("\(workoutsOnDate.count) workout\(workoutsOnDate.count != 1 ? "s" : "")")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Button {
                            isShowingDetails = false
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.gray)
                                .font(.title3)
                        }
                    }
                    .padding()
                    .background(Color(UIColor.systemBackground))
                    
                    if !workoutsOnDate.isEmpty {
                        Divider()
                        
                        // Scrollable content
                        ScrollView {
                            VStack(spacing: 0) {
                                ForEach(workoutsOnDate) { workout in
                                    VStack(spacing: 0) {
                                        HStack(spacing: 12) {
                                            VStack(alignment: .leading, spacing: 4) {
                                                Text(workout.workoutType.rawValue.capitalized)
                                                    .font(.subheadline)
                                                    .fontWeight(.medium)
                                                
                                                Text("\(Int(workout.steps)) steps")
                                                    .font(.caption)
                                                    .foregroundColor(.secondary)
                                                
                                                Text("\(Int(workout.caloriesBurned)) calories")
                                                    .font(.caption)
                                                    .foregroundColor(.secondary)
                                            }
                                            
                                            Spacer()
                                            
                                            Image(systemName: workout.workoutType == .stairMaster ? "stairs" : "figure.walk")
                                                .foregroundColor(.purple)
                                                .font(.system(size: 16))
                                        }
                                        .padding()
                                        
                                        if workout.id != workoutsOnDate.last?.id {
                                            Divider()
                                        }
                                    }
                                }
                            }
                        }
                    } else {
                        // No workouts
                    }
                }
                .frame(width: 300, height: workoutsOnDate.isEmpty ? 100 : min(CGFloat(workoutsOnDate.count * 85 + 60), 400))
                .presentationCompactAdaptation(.popover)
            }
    }
}

#Preview {
    StreakGridView()
} 
