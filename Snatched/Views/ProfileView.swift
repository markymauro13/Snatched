import SwiftUI

struct ProfileView: View {
    @StateObject private var profileManager = ProfileManager.shared
    @State private var tempWeight: String = ""
    @State private var showingSaveConfirmation = false
    @Environment(\.dismiss) private var dismiss
    
    private let weightPresets = Array(stride(from: 100, through: 300, by: 10))
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 8) {
                    Image(systemName: "person.circle.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.purple)
                    
                    Text("Your Profile")
                        .font(.title2)
                        .fontWeight(.bold)
                }
                .padding(.top)
                
                // Current Weight Display
                if profileManager.hasValidWeight() {
                    VStack(spacing: 8) {
                        Text("Current Weight")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        
                        Text("\(profileManager.userProfile.weight, specifier: "%.1f") lbs")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.purple)
                        
                        Text("Last updated: \(profileManager.userProfile.dateUpdated, formatter: dateFormatter)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .background(Color.purple.opacity(0.1))
                    .cornerRadius(12)
                }
                
                // Weight Input Section
                VStack(alignment: .leading, spacing: 16) {
                    Label("Set Your Weight (lbs)", systemImage: "figure.arms.open")
                        .font(.headline)
                    
                    // Custom weight input
                    VStack(spacing: 12) {
                        TextField("Enter your weight", text: $tempWeight)
                            .keyboardType(.decimalPad)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .multilineTextAlignment(.center)
                        
                        Text("Valid range: 50 - 500 lbs")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    // Preset weight buttons
                    Text("Quick Select")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                            ForEach(weightPresets, id: \.self) { weight in
                                WeightPresetButton(
                                    weight: weight,
                                    isSelected: profileManager.userProfile.weight == Double(weight),
                                    action: {
                                        tempWeight = "\(weight)"
                                    }
                                )
                            }
                        }
                        .padding(.horizontal, 4)
                    }
                }
                .padding()
                .background(Color.purple.opacity(0.1))
                .cornerRadius(15)
                
                // Save Button
                Button {
                    saveWeight()
                } label: {
                    Text("Save Weight")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(isValidWeight() ? Color.purple : Color.gray)
                        .cornerRadius(10)
                        .shadow(radius: 3)
                }
                .disabled(!isValidWeight())
                
                Spacer()
            }
            .padding()
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .alert("Weight Saved!", isPresented: $showingSaveConfirmation) {
                Button("OK") { }
            } message: {
                Text("Your weight has been saved and will be used for future workouts.")
            }
        }
        .onAppear {
            if profileManager.hasValidWeight() {
                tempWeight = String(format: "%.1f", profileManager.userProfile.weight)
            }
        }
    }
    
    private func isValidWeight() -> Bool {
        guard let weight = Double(tempWeight) else { return false }
        return weight >= 50 && weight <= 500
    }
    
    private func saveWeight() {
        guard let weight = Double(tempWeight), weight >= 50 && weight <= 500 else { return }
        
        withAnimation {
            profileManager.updateWeight(weight)
            showingSaveConfirmation = true
        }
    }
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }
}

struct WeightPresetButton: View {
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

#Preview {
    ProfileView()
} 