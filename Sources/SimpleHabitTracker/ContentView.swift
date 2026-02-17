import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = HabitViewModel()
    @State private var showingAddAlert = false
    @State private var showingStats = false
    @State private var newHabitTitle = ""

    var body: some View {
        VStack {
            List {
                ForEach(viewModel.habits) { habit in
                    HStack {
                        Image(systemName: habit.isCompletedToday ? "checkmark.circle.fill" : "circle")
                            .foregroundColor(habit.isCompletedToday ? .green : .gray)
                            .onTapGesture {
                                withAnimation {
                                    viewModel.toggle(habit)
                                }
                            }
                        Text(habit.title)
                            .strikethrough(habit.isCompletedToday, color: .gray)
                            .foregroundStyle(habit.isCompletedToday ? .gray : .primary)
                        Spacer()
                        
                        Button(action: {
                            if let index = viewModel.habits.firstIndex(where: { $0.id == habit.id }) {
                                viewModel.deleteHabit(at: IndexSet(integer: index))
                            }
                        }) {
                            Image(systemName: "trash")
                                .foregroundColor(.red.opacity(0.7))
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(.vertical, 4)
                }
                .onMove(perform: viewModel.move)
            }
            .listStyle(.inset)
            
            HStack {
                Button(action: {
                    showingAddAlert = true
                }) {
                    Label("Add New Habit", systemImage: "plus.circle.fill")
                        .font(.headline)
                        .padding()
                }
                .buttonStyle(.plain)
                .keyboardShortcut("n", modifiers: .command)
            }
            .padding(.bottom)
        }
        .frame(minWidth: 300, minHeight: 400)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button(action: { showingStats = true }) {
                    Image(systemName: "chart.bar")
                        .help("Consistency Graph")
                }
            }
        }
        .sheet(isPresented: $showingStats) {
            StatisticsView(viewModel: viewModel)
        }
        .alert("New Habit", isPresented: $showingAddAlert) {
            TextField("Habit Name", text: $newHabitTitle)
            Button("Add", action: addHabit)
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Enter the name of the habit you want to track.")
        }
    }
    
    private func addHabit() {
        guard !newHabitTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        withAnimation {
            viewModel.addHabit(title: newHabitTitle)
        }
        newHabitTitle = ""
    }
}
