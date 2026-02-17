import Foundation

struct Habit: Identifiable, Codable {
    var id = UUID()
    var title: String
    var completedDates: [Date] = []
    
    var isCompletedToday: Bool {
        completedDates.contains { Calendar.current.isDateInToday($0) }
    }
    
    mutating func toggleCompletion() {
        if isCompletedToday {
            completedDates.removeAll { Calendar.current.isDateInToday($0) }
        } else {
            completedDates.append(Date())
        }
    }
}
