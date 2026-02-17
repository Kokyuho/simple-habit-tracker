import Foundation
import Combine

class HabitViewModel: ObservableObject {
    @Published var habits: [Habit] = [] {
        didSet {
            save()
        }
    }
    
    // Key for UserDefaults
    private let key = "SavedHabits"
    
    init() {
        load()
        // If empty, add a sample one
        if habits.isEmpty {
            habits.append(Habit(title: "Drink Water"))
            habits.append(Habit(title: "Exercise"))
        }
    }
    
    func addHabit(title: String) {
        habits.append(Habit(title: title))
    }
    
    func deleteHabit(at offsets: IndexSet) {
        habits.remove(atOffsets: offsets)
    }

    func move(from source: IndexSet, to destination: Int) {
        habits.move(fromOffsets: source, toOffset: destination)
    }
    
    func toggle(_ habit: Habit) {
        if let index = habits.firstIndex(where: { $0.id == habit.id }) {
            habits[index].toggleCompletion()
            // Changing array triggers save
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
