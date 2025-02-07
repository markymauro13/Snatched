//
//  HomeView.swift
//  Snatched
//
//  Created by Mark Mauro on 2/5/25.
//


import SwiftUI

struct HomeView: View {
    @State private var selectedWorkout: WorkoutType?
    @State private var isExpanded = true
    @State private var viewID = UUID()
    @Namespace private var animation
    @State private var showingStreakView = false

    func resetToHome() {
        withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
            selectedWorkout = nil
            isExpanded = true
            viewID = UUID()
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            if isExpanded {
                // Centered workout selection
                VStack(spacing: 24) {
                    Image(systemName: "figure.run")
                        .font(.system(size: 60))
                        .foregroundColor(.purple)
                        .matchedGeometryEffect(id: "icon", in: animation)
                    
                    Text("Choose Your Workout")
                        .font(.title2)
                        .fontWeight(.bold)
                        .matchedGeometryEffect(id: "title", in: animation)
                    
                    VStack(spacing: 16) {
                        workoutButton(type: .stairMaster, title: "Stair Master")
                            .matchedGeometryEffect(id: "stairmaster", in: animation)
                        
                        workoutButton(type: .treadmill, title: "Treadmill")
                            .matchedGeometryEffect(id: "treadmill", in: animation)
                    }
                    .frame(maxWidth: 280)
                }
                .frame(maxHeight: .infinity)
                
                Button {
                    showingStreakView.toggle()
                } label: {
                    Label("View Streak", systemImage: "chart.line.uptrend.xyaxis")
                        .font(.headline)
                        .foregroundColor(.purple)
                        .padding()
                        .background(Color.purple.opacity(0.1))
                        .cornerRadius(10)
                }
                .sheet(isPresented: $showingStreakView) {
                    StreakGridView()
                        .presentationDetents([.height(250)])
                        .presentationDragIndicator(.visible)
                }
                
                Spacer()
            } else {
                // Collapsed header with workout buttons
                HStack {
                    workoutButton(type: .stairMaster, title: "Stair Master")
                        .matchedGeometryEffect(id: "stairmaster", in: animation)
                    
                    workoutButton(type: .treadmill, title: "Treadmill")
                        .matchedGeometryEffect(id: "treadmill", in: animation)
                }
                .padding(.horizontal)
                .padding(.vertical, 12)
            }
            
            // Workout View Container
            if let selectedType = selectedWorkout {
                WorkoutView(workoutType: selectedType, resetToHome: resetToHome)
                    .id(viewID)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
            
            if isExpanded {
                Spacer()
            }
        }
        .navigationBarHidden(true)
    }
    
    private func workoutButton(type: WorkoutType, title: String) -> some View {
        Button {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                if selectedWorkout != type {
                    selectedWorkout = nil
                    viewID = UUID()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                            selectedWorkout = type
                        }
                    }
                }
                isExpanded = false
            }
        } label: {
            Text(title)
                .font(.headline)
                .padding(.vertical, 12)
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(selectedWorkout == type ? Color.purple : Color.purple.opacity(0.7))
                        .shadow(color: .purple.opacity(0.3), radius: 8, x: 0, y: 4)
                )
                .foregroundColor(.white)
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
