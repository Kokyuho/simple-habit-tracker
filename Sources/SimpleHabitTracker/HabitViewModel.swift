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
    
    private let legacyDefaultsKey = "SavedHabits"
    private let fileManager = FileManager.default
    private let appSupportFolderName = "SimpleHabitTracker"
    private let habitsFileName = "habits.json"
    private let secureStore = SecureHabitStore()
    
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

    func updateHabit(_ habit: Habit, title: String, type: HabitType, weeklyCount: Int = 1) {
        guard let index = habits.firstIndex(where: { $0.id == habit.id }) else {
            return
        }

        var updatedHabit = habits[index]
        updatedHabit.title = title.trimmingCharacters(in: .whitespacesAndNewlines)
        updatedHabit.frequency = type == .daily
            ? .daily
            : .weekly(occurrences: max(1, min(7, weeklyCount)))

        habits[index] = updatedHabit
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

    func moveDailyHabit(draggedID: UUID, to destinationID: UUID) {
        moveFilteredHabitByID(
            draggedID: draggedID,
            destinationID: destinationID,
            isIncluded: { habit in
                if case .daily = habit.frequency { return true }
                return false
            }
        )
    }

    func moveWeeklyHabit(draggedID: UUID, to destinationID: UUID) {
        moveFilteredHabitByID(
            draggedID: draggedID,
            destinationID: destinationID,
            isIncluded: { habit in
                if case .weekly = habit.frequency { return true }
                return false
            }
        )
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

    private func moveFilteredHabitByID(
        draggedID: UUID,
        destinationID: UUID,
        isIncluded: (Habit) -> Bool
    ) {
        var filtered = habits.filter(isIncluded)
        guard let fromIndex = filtered.firstIndex(where: { $0.id == draggedID }),
              let toIndex = filtered.firstIndex(where: { $0.id == destinationID }) else {
            return
        }

        let targetOffset = toIndex > fromIndex ? toIndex + 1 : toIndex
        filtered.move(fromOffsets: IndexSet(integer: fromIndex), toOffset: targetOffset)

        var reorderedIterator = filtered.makeIterator()
        for index in habits.indices {
            if isIncluded(habits[index]), let nextHabit = reorderedIterator.next() {
                habits[index] = nextHabit
            }
        }
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
        do {
            try secureStore.save(habits)
        } catch {
            print("Failed to securely save habits: \(error.localizedDescription)")
        }
    }
    
    private func load() {
        if let decoded = try? secureStore.load() {
            habits = decoded
            return
        }

        if let decodedLegacyFile = loadLegacyPlaintextFile() {
            habits = decodedLegacyFile
            save()
            removeLegacyPlaintextFileIfPresent()
            return
        }

        if let legacyData = UserDefaults.standard.data(forKey: legacyDefaultsKey),
           let decodedLegacy = try? JSONDecoder().decode([Habit].self, from: legacyData) {
            habits = decodedLegacy
            save()
            UserDefaults.standard.removeObject(forKey: legacyDefaultsKey)
        }
    }

    private func loadLegacyPlaintextFile() -> [Habit]? {
        guard let fileURL = habitsFileURL(),
              let data = try? Data(contentsOf: fileURL),
              let decoded = try? JSONDecoder().decode([Habit].self, from: data) else {
            return nil
        }

        return decoded
    }

    private func removeLegacyPlaintextFileIfPresent() {
        guard let fileURL = habitsFileURL(), fileManager.fileExists(atPath: fileURL.path) else {
            return
        }

        do {
            try fileManager.removeItem(at: fileURL)
        } catch {
            print("Failed to remove legacy plaintext habits file: \(error.localizedDescription)")
        }
    }

    private func habitsFileURL() -> URL? {
        guard let appSupportURL = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first else {
            return nil
        }

        let folderURL = appSupportURL.appendingPathComponent(appSupportFolderName, isDirectory: true)
        do {
            try fileManager.createDirectory(at: folderURL, withIntermediateDirectories: true)
        } catch {
            print("Failed to prepare app support directory: \(error.localizedDescription)")
            return nil
        }

        return folderURL.appendingPathComponent(habitsFileName)
    }
}
