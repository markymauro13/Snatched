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
    @State private var showingProfileView = false
    @State private var showingAnalyticsView = false

    func resetToHome() {
        withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
            selectedWorkout = nil
            isExpanded = true
            viewID = UUID()
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            // Top Navigation Bar
            HStack {
                Text("Snatched")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.purple)
                
                Spacer()
                
                Button {
                    showingAnalyticsView.toggle()
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "chart.bar.fill")
                            .font(.system(size: 12, weight: .semibold))
                        Text("Analytics")
                            .font(.system(size: 12, weight: .semibold))
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(
                        LinearGradient(
                            colors: [.purple, .blue],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(16)
                    .shadow(color: .purple.opacity(0.3), radius: 3, x: 0, y: 1)
                }
                .sheet(isPresented: $showingAnalyticsView) {
                    AnalyticsView()
                }
            }
            .padding(.horizontal)
            .padding(.top, 8)
            
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
                
                HStack(spacing: 24) {
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
                    
                    Button {
                        showingProfileView.toggle()
                    } label: {
                        Label("Profile", systemImage: "person.circle")
                            .font(.headline)
                            .foregroundColor(.purple)
                            .padding()
                            .background(Color.purple.opacity(0.1))
                            .cornerRadius(10)
                    }
                    .sheet(isPresented: $showingProfileView) {
                        ProfileView()
                    }
                }
                
                Spacer()
            } else {
                // Collapsed header with workout buttons and analytics
                VStack(spacing: 8) {
                    // Top bar with app name and analytics
                    HStack {
                        Text("Snatched")
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(.purple)
                        
                        Spacer()
                        
                        Button {
                            showingAnalyticsView.toggle()
                        } label: {
                            HStack(spacing: 6) {
                                Image(systemName: "chart.bar.fill")
                                    .font(.system(size: 16, weight: .semibold))
                                Text("Analytics")
                                    .font(.system(size: 14, weight: .semibold))
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(
                                LinearGradient(
                                    colors: [.purple, .blue],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(20)
                            .shadow(color: .purple.opacity(0.3), radius: 4, x: 0, y: 2)
                        }
                    }
                    .padding(.horizontal)
                    
                    // Workout buttons
                    HStack {
                        workoutButton(type: .stairMaster, title: "Stair Master")
                            .matchedGeometryEffect(id: "stairmaster", in: animation)
                        
                        workoutButton(type: .treadmill, title: "Treadmill")
                            .matchedGeometryEffect(id: "treadmill", in: animation)
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical, 8)
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
