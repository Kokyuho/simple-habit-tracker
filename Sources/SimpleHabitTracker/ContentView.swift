import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = HabitViewModel()
    @State private var showingAddAlert = false
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
                    }
                    .padding(.vertical, 4)
                }
                .onDelete(perform: viewModel.deleteHabit)
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
                Button(action: { showingAddAlert = true }) {
                    Image(systemName: "plus")
                }
            }
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
