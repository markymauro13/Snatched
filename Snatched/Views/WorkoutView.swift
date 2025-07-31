import SwiftUI

struct WorkoutView: View {
    let workoutType: WorkoutType
    @StateObject private var viewModel: WorkoutViewModel
    @State private var isShowingResults = false
    @State private var showingProfileView = false
    @StateObject private var profileManager = ProfileManager.shared
    let resetToHome: () -> Void
    
    // Define ranges for inputs
    private let levelRange = 1...20
    private let speedRange = 1.0...12.0
    private let inclineRange = 0.0...15.0  // Standard treadmill incline range
    private let timePresets = [5, 10, 15, 20, 30, 45, 60]
    private let weightPresets = Array(stride(from: 100, through: 300, by: 10))
    
    init(workoutType: WorkoutType, resetToHome: @escaping () -> Void) {
        self.workoutType = workoutType
        self.resetToHome = resetToHome
        _viewModel = StateObject(wrappedValue: WorkoutViewModel(workoutType: workoutType))
    }
    
    var body: some View {
        VStack(spacing: 20) {
            // Input Fields with Labels
            VStack(alignment: .leading, spacing: 24) {
                // Level/Speed Slider
                VStack(alignment: .leading, spacing: 8) {
                    Label(workoutType == .stairMaster ? "Level" : "Speed", 
                          systemImage: "speedometer")
                        .font(.headline)
                    
                    HStack {
                        if workoutType == .stairMaster {
                            Slider(value: Binding(
                                get: { Double(viewModel.workoutInput.levelOrSpeed) },
                                set: { viewModel.workoutInput.levelOrSpeed = $0 }
                            ), in: Double(levelRange.lowerBound)...Double(levelRange.upperBound), step: 1)
                            .accentColor(.purple)
                        } else {
                            Slider(value: $viewModel.workoutInput.levelOrSpeed,
                                   in: speedRange.lowerBound...speedRange.upperBound,
                                   step: 0.5)
                            .accentColor(.purple)
                        }
                        
                        Text("\(viewModel.workoutInput.levelOrSpeed, specifier: workoutType == .stairMaster ? "%.0f" : "%.1f")")
                            .font(.title3)
                            .frame(width: 50)
                    }
                }
                
                // Incline Slider (Only for Treadmill)
                if workoutType == .treadmill {
                    VStack(alignment: .leading, spacing: 8) {
                        Label("Incline %", systemImage: "arrow.up.right")
                            .font(.headline)
                        
                        HStack {
                            Slider(value: $viewModel.workoutInput.incline,
                                   in: inclineRange.lowerBound...inclineRange.upperBound,
                                   step: 0.5)
                            .accentColor(.purple)
                            
                            Text("\(viewModel.workoutInput.incline, specifier: "%.1f")")
                                .font(.title3)
                                .frame(width: 50)
                        }
                    }
                }
                
                // Time Picker
                VStack(alignment: .leading, spacing: 8) {
                    Label("Time (minutes)", systemImage: "clock")
                        .font(.headline)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                            // Custom time input button
                            CustomInputButton(
                                value: $viewModel.workoutInput.time,
                                title: "Custom",
                                placeholder: "Enter minutes",
                                range: 1...120,
                                formatter: "%.0f"
                            )
                            
                            // Preset time buttons
                            ForEach(timePresets, id: \.self) { time in
                                TimeButton(time: time, 
                                         isSelected: viewModel.workoutInput.time == Double(time),
                                         action: {
                                             withAnimation(.spring()) {
                                                 viewModel.workoutInput.time = Double(time)
                                             }
                                         })
                            }
                        }
                        .padding(.horizontal, 4)
                    }
                }
                
                // Weight Picker
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Label("Your Weight (lbs)", systemImage: "figure.arms.open")
                            .font(.headline)
                        
                        Spacer()
                        
                        if profileManager.hasValidWeight() {
                            Button {
                                showingProfileView.toggle()
                            } label: {
                                Text("Edit Profile")
                                    .font(.caption)
                                    .foregroundColor(.purple)
                            }
                        }
                    }
                    
                    // Show weight source info
                    if profileManager.hasValidWeight() && viewModel.workoutInput.weight == profileManager.userProfile.weight {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                                .font(.caption)
                            Text("Using weight from your profile")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                            // Custom weight input button
                            CustomInputButton(
                                value: $viewModel.workoutInput.weight,
                                title: "Custom",
                                placeholder: "Enter weight",
                                range: 50...500,
                                formatter: "%.1f"
                            )
                            
                            // Profile weight button (if available)
                            if profileManager.hasValidWeight() {
                                Button {
                                    withAnimation(.spring()) {
                                        viewModel.workoutInput.weight = profileManager.userProfile.weight
                                    }
                                } label: {
                                    HStack {
                                        Image(systemName: "person.circle")
                                            .font(.caption)
                                        Text("\(profileManager.userProfile.weight, specifier: "%.1f")")
                                    }
                                    .font(.headline)
                                    .padding(.horizontal, 20)
                                    .padding(.vertical, 10)
                                    .background(viewModel.workoutInput.weight == profileManager.userProfile.weight ? Color.green : Color.green.opacity(0.2))
                                    .foregroundColor(viewModel.workoutInput.weight == profileManager.userProfile.weight ? .white : .green)
                                    .cornerRadius(8)
                                    .animation(.spring(), value: viewModel.workoutInput.weight == profileManager.userProfile.weight)
                                }
                            }
                            
                            // Preset weight buttons
                            ForEach(weightPresets, id: \.self) { weight in
                                WeightButton(weight: weight,
                                           isSelected: viewModel.workoutInput.weight == Double(weight),
                                           action: {
                                               withAnimation(.spring()) {
                                                   viewModel.workoutInput.weight = Double(weight)
                                               }
                                           })
                            }
                        }
                        .padding(.horizontal, 4)
                    }
                }
            }
            .padding()
            .background(Color.purple.opacity(0.1))
            .cornerRadius(15)
            
            // Calculate Button
            Button {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                    viewModel.calculateWorkout()
                    isShowingResults = true
                }
            } label: {
                Text("Calculate")
                    .font(.headline)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.purple)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .shadow(radius: 3)
            }
            .disabled(viewModel.workoutInput.time == 0 || viewModel.workoutInput.weight == 0)
            .opacity(viewModel.workoutInput.time == 0 || viewModel.workoutInput.weight == 0 ? 0.6 : 1)
            
            if isShowingResults {
                ResultsView(
                    result: viewModel.workoutResult,
                    workoutType: workoutType,
                    isShowingResults: $isShowingResults,
                    resetToHome: resetToHome
                )
                .transition(.scale.combined(with: .opacity))
            }
            
            Spacer()
            
            // Exit Button - X button to return to home
            Button {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                    resetToHome()
                }
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 40))
                    .foregroundColor(.gray.opacity(0.6))
                    .background(Circle().fill(Color.white))
                    .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
            }
            .padding(.bottom, 20)
        }
        .padding()
        .sheet(isPresented: $showingProfileView) {
            ProfileView()
        }
    }
}

// Helper Views for Time and Weight selection
struct TimeButton: View {
    let time: Int
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text("\(time)")
                .font(.headline)
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .background(isSelected ? Color.purple : Color.purple.opacity(0.2))
                .foregroundColor(isSelected ? .white : .purple)
                .cornerRadius(8)
                .animation(.spring(), value: isSelected)
        }
    }
}

struct WeightButton: View {
    let weight: Int
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text("\(weight)")
                .font(.headline)
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .background(isSelected ? Color.purple : Color.purple.opacity(0.2))
                .foregroundColor(isSelected ? .white : .purple)
                .cornerRadius(8)
                .animation(.spring(), value: isSelected)
        }
    }
}

struct ResultsView: View {
    let result: WorkoutResult
    let workoutType: WorkoutType
    @State private var showingSaveConfirmation = false
    @State private var isSaving = false
    @Environment(\.dismiss) private var dismiss
    @Binding var isShowingResults: Bool
    let resetToHome: () -> Void
    
    var body: some View {
        VStack(spacing: 15) {
            resultCard(title: "Steps", value: result.steps.formatted(.number), icon: "figure.walk")
            resultCard(title: "Calories Burned", value: String(format: "%.2f", result.caloriesBurned), icon: "flame.fill")
            
            // Save to Streak Button
            Button {
                saveToStreak()
            } label: {
                HStack {
                    Image(systemName: "chart.line.uptrend.xyaxis")
                    Text(isSaving ? "Saving..." : "Save to Streak")
                }
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(isSaving ? Color.gray : Color.purple)
                .cornerRadius(8)
                .overlay(
                    Group {
                        if isSaving {
                            ProgressView()
                                .tint(.white)
                        }
                    }
                )
            }
            .disabled(isSaving)
            .alert("Workout Saved!", isPresented: $showingSaveConfirmation) {
                Button("Done") {
                    resetToHome()
                }
            } message: {
                Text("Your workout has been added to your streak.")
            }
        }
        .transition(.scale.combined(with: .opacity))
    }
    
    private func saveToStreak() {
        isSaving = true
        
        // Create new streak entry
        let streakEntry = WorkoutStreak(
            workoutType: workoutType,
            steps: result.steps,
            caloriesBurned: result.caloriesBurned
        )
        
        // Save to UserDefaults temporarily (we'll replace this with proper storage later)
        StreakManager.shared.saveWorkout(streakEntry)
        
        // Simulate network delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            isSaving = false
            showingSaveConfirmation = true
        }
    }
    
    private func resultCard(title: String, value: String, icon: String) -> some View {
        HStack {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.purple)
            
            VStack(alignment: .leading) {
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Text(value)
                    .font(.title2)
                    .bold()
            }
            Spacer()
        }
        .padding()
        .background(Color.purple.opacity(0.1))
        .cornerRadius(10)
    }
}

// Add this new custom input button view
struct CustomInputButton: View {
    @Binding var value: Double
    let title: String
    let placeholder: String
    let range: ClosedRange<Double>
    let formatter: String
    
    @State private var isShowingSheet = false
    @State private var tempValue: String = ""
    
    var body: some View {
        Button {
            tempValue = String(format: formatter, value)
            isShowingSheet = true
        } label: {
            HStack {
                Image(systemName: "pencil")
                Text(value == 0 ? title : String(format: formatter, value))
            }
            .font(.headline)
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            .background(Color.purple.opacity(0.2))
            .foregroundColor(.purple)
            .cornerRadius(8)
        }
        .sheet(isPresented: $isShowingSheet) {
            CustomInputSheet(
                isPresented: $isShowingSheet,
                value: $value,
                tempValue: $tempValue,
                title: title,
                placeholder: placeholder,
                range: range,
                formatter: formatter
            )
            .presentationDetents([.height(180)])
            .presentationDragIndicator(.visible)
        }
    }
}

struct CustomInputSheet: View {
    @Binding var isPresented: Bool
    @Binding var value: Double
    @Binding var tempValue: String
    let title: String
    let placeholder: String
    let range: ClosedRange<Double>
    let formatter: String
    
    var body: some View {
        VStack(spacing: 16) {
            // Title and Close Button
            HStack {
                Text("Enter Custom Value")
                    .font(.headline)
                Spacer()
                Button {
                    isPresented = false
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                        .font(.title3)
                }
            }
            
            // Input Field
            TextField(placeholder, text: $tempValue)
                .keyboardType(.decimalPad)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .multilineTextAlignment(.center)
            
            // Range Label
            Text("Valid range: \(String(format: formatter, range.lowerBound)) - \(String(format: formatter, range.upperBound))")
                .font(.caption)
                .foregroundColor(.secondary)
            
            // Done Button
            Button {
                if let newValue = Double(tempValue),
                   range.contains(newValue) {
                    withAnimation {
                        value = newValue
                    }
                    isPresented = false
                }
            } label: {
                Text("Done")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Color.purple)
                    .cornerRadius(8)
            }
        }
        .padding()
        .background(Color(UIColor.systemBackground))
    }
}

#Preview {
    WorkoutView(workoutType: .stairMaster, resetToHome: {})
}
