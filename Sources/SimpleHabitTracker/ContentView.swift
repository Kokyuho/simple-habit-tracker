import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = HabitViewModel()
    @State private var showingAddSheet = false
    @State private var showingStats = false
    
    var body: some View {
        HSplitView {
            // LEFT: Daily Habits
            VStack(spacing: 0) {
                Text("Daily Habits")
                    .font(.headline)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.secondary.opacity(0.1))
                
                List {
                    ForEach(viewModel.dailyHabits) { habit in
                        HStack {
                            Image(systemName: habit.isCompletedToday ? "checkmark.circle.fill" : "circle")
                                .foregroundColor(habit.isCompletedToday ? .green : .gray)
                                .onTapGesture {
                                    withAnimation {
                                        viewModel.toggleDaily(habit)
                                    }
                                }
                            Text(habit.title)
                                .strikethrough(habit.isCompletedToday, color: .gray)
                                .foregroundStyle(habit.isCompletedToday ? .gray : .primary)
                            Spacer()
                            
                            Button(action: {
                                withAnimation {
                                    viewModel.deleteHabit(habit)
                                }
                            }) {
                                Image(systemName: "trash")
                                    .foregroundColor(.red.opacity(0.5))
                            }
                            .buttonStyle(.plain)
                        }
                        .padding(.vertical, 4)
                    }
                }
                .listStyle(.inset)
            }
            .frame(minWidth: 250, maxWidth: .infinity, maxHeight: .infinity)
            
            // RIGHT: Weekly Habits
            VStack(spacing: 0) {
                Text("Weekly Goals")
                    .font(.headline)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.secondary.opacity(0.1))
                
                List {
                    ForEach(viewModel.weeklyHabits) { habit in
                        if case .weekly(let target) = habit.frequency {
                            VStack(alignment: .leading, spacing: 6) {
                                HStack {
                                    Text(habit.title)
                                        .font(.headline)
                                    Spacer()
                                    // Delete button for weekly
                                    Button(action: {
                                        withAnimation {
                                            viewModel.deleteHabit(habit)
                                        }
                                    }) {
                                        Image(systemName: "trash")
                                            .foregroundColor(.red.opacity(0.5))
                                    }
                                    .buttonStyle(.plain)
                                }
                                
                                HStack {
                                    Text("Goal: \(habit.completionsThisWeek) / \(target)")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    
                                    Spacer()
                                    
                                    HStack(spacing: 12) {
                                        Button(action: {
                                            withAnimation {
                                                viewModel.decrementWeekly(habit)
                                            }
                                        }) {
                                            Image(systemName: "minus.circle")
                                        }
                                        .disabled(habit.completionsThisWeek == 0)
                                        
                                        // Visualize weekly progress
                                        HStack(spacing: 2) {
                                            ForEach(0..<target, id: \.self) { i in
                                                Circle()
                                                    .fill(i < habit.completionsThisWeek ? Color.blue : Color.gray.opacity(0.3))
                                                    .frame(width: 8, height: 8)
                                            }
                                        }
                                        
                                        Button(action: {
                                            withAnimation {
                                                viewModel.incrementWeekly(habit)
                                            }
                                        }) {
                                            Image(systemName: "plus.circle")
                                        }
                                        .disabled(habit.completionsThisWeek >= 7) // Cap at 7 for UI sanity
                                    }
                                }
                            }
                            .padding(.vertical, 6)
                        }
                    }
                }
                .listStyle(.inset)
            }
            .frame(minWidth: 250, maxWidth: .infinity, maxHeight: .infinity)
        }
        .frame(minWidth: 600, minHeight: 400)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button(action: { showingStats = true }) {
                    Image(systemName: "chart.bar")
                        .help("Consistency Graph")
                }
            }
            ToolbarItem(placement: .primaryAction) {
                Button(action: { showingAddSheet = true }) {
                    Image(systemName: "plus")
                        .help("Add New Habit")
                }
            }
        }
        .sheet(isPresented: $showingStats) {
            StatisticsView(viewModel: viewModel)
        }
        .sheet(isPresented: $showingAddSheet) {
            AddHabitView(viewModel: viewModel)
                .padding()
        }
    }
}
