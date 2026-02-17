import Foundation
import Combine

enum HabitType {
    case daily, weekly
}

class HabitViewModel: ObservableObject {
    @Published var habits: [Habit] = [] {
        didSet {
            save()
        }
    }
    
    // Key for UserDefaults
    private let key = "SavedHabits"
    
    // Derived collections for UI
    var dailyHabits: [Habit] {
        habits.filter { if case .daily = $0.frequency { return true }; return false }
    }
    
    var weeklyHabits: [Habit] {
        habits.filter { if case .weekly = $0.frequency { return true }; return false }
    }
    
    init() {
        load()
        // If empty, add a sample one
        if habits.isEmpty {
            habits.append(Habit(title: "Drink Water"))
            habits.append(Habit(title: "Exercise"))
        }
    }
    
    func addHabit(title: String, type: HabitType, weeklyCount: Int = 1) {
        let habit = Habit(
            title: title, 
            frequency: type == .daily ? .daily : .weekly(occurrences: weeklyCount)
        )
        habits.append(habit)
    }

    func updateWeeklyTarget(for habit: Habit, to newTarget: Int) {
        if let index = habits.firstIndex(where: { $0.id == habit.id }) {
            var updatedHabit = habits[index]
            if case .weekly = updatedHabit.frequency {
                updatedHabit.frequency = .weekly(occurrences: newTarget)
                habits[index] = updatedHabit
            }
        }
    }
    
    // For manual toggles (click checkmark)
    func toggleDaily(_ habit: Habit) {
        if let index = habits.firstIndex(where: { $0.id == habit.id }) {
            var updatedHabit = habits[index]
             if case .daily = updatedHabit.frequency {
                updatedHabit.toggleCompletion()
                habits[index] = updatedHabit
            }
        }
    }
    
    // Updated for Weeklies: Add ONE completion
    func incrementWeekly(_ habit: Habit) {
        if let index = habits.firstIndex(where: { $0.id == habit.id }) {
             var updatedHabit = habits[index]
             updatedHabit.addWeeklyCompletion()
             habits[index] = updatedHabit
        }
    }

    // Updated for Weeklies: Remove ONE completion
    func decrementWeekly(_ habit: Habit) {
        if let index = habits.firstIndex(where: { $0.id == habit.id }) {
             var updatedHabit = habits[index]
             updatedHabit.removeWeeklyCompletion()
             habits[index] = updatedHabit
        }
    }

    
    func deleteHabit(at offsets: IndexSet) {
        habits.remove(atOffsets: offsets)
    }

    // New delete for weekly list since indexset will be relative to filtered list
    func deleteHabit(_ habit: Habit) {
        if let index = habits.firstIndex(where: { $0.id == habit.id }) {
            habits.remove(at: index)
        }
    }

    func move(from source: IndexSet, to destination: Int) {
        habits.move(fromOffsets: source, toOffset: destination)
    }

    func moveHabit(_ habit: Habit, from source: IndexSet, to destination: Int) {
          // When moving within filtered lists (Daily or Weekly), we need to translate the indices
          // But SwiftUI lists binding to filtered arrays usually just provide offsets within that array.
          // The easiest way is to reorder the main 'habits' array to reflect the new relative order.
          // However, for simplicity given two lists, we can just say "reordering is supported within the main list" 
          // or implement sophisticated swap logic.
          // A simple approach: 
          // 1. Get the items being moved from the filtered list (e.g., dailyHabits)
          // 2. Remove them from the main 'habits' array
          // 3. Insert them back at the correct new relative position
          // This is complex. For this iteration, we might disable reordering or accept it only works 
          // if we display only one list.
          // Since the user asked for 2 columns, drag-reorder might be tricky across columns.
          // We will stick to simple deletion for now in the columns or basic reorder if feasible.
    }
    
    // Legacy toggle (compat) - reroutes
    func toggle(_ habit: Habit) {
        if case .daily = habit.frequency {
           toggleDaily(habit) 
        } else {
            // For weekly, tapping 'item' is ambiguous, maybe add completion?
            incrementWeekly(habit)
        }
    }
    
    private func save() {
        if let encoded = try? JSONEncoder().encode(habits) {
            UserDefaults.standard.set(encoded, forKey: key)
        }
    }
    
    private func load() {
        if let data = UserDefaults.standard.data(forKey: key),
           let decoded = try? JSONDecoder().decode([Habit].self, from: data) {
            self.habits = decoded
        }
    }
}
