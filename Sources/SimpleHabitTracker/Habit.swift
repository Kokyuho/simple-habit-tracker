import Foundation

enum HabitFrequency: Codable, Equatable {
    case daily
    case weekly(occurrences: Int)
}

struct Habit: Identifiable, Codable {
    var id = UUID()
    var title: String
    var completedDates: [Date] = []
    // Default to daily for backward compatibility if needed, though Codable handles it
    var frequency: HabitFrequency = .daily
    
    // MARK: - Daily Logic
    var isCompletedToday: Bool {
        completedDates.contains { Calendar.current.isDateInToday($0) }
    }
    
    // MARK: - Weekly Logic
    var completionsThisWeek: Int {
        completedDates.filter {
            Calendar.current.isDate($0, equalTo: Date(), toGranularity: .weekOfYear)
        }.count
    }
    
    // MARK: - Actions
    mutating func toggleCompletion() {
        switch frequency {
        case .daily:
            if isCompletedToday {
                completedDates.removeAll { Calendar.current.isDateInToday($0) }
            } else {
                completedDates.append(Date())
            }
        case .weekly:
            // For weekly, toggle isn't quite right. We usually add/remove based on count
            // But if called directly without parameters, we assume adding one or removing last
            // It's safer to have explicit add/remove methods for weekly, but for compatibility:
            if completionsThisWeek > 0 {
                removeWeeklyCompletion()
            } else {
                addWeeklyCompletion()
            }
        }
    }
    
    mutating func addWeeklyCompletion() {
        // Only valid for weekly
        if case .weekly(let target) = frequency {
            if completionsThisWeek < target {
                completedDates.append(Date())
            }
        }
    }
    
    mutating func removeWeeklyCompletion() {
        // Remove the most recent completion within this week
        let weekCompletions = completedDates.filter {
            Calendar.current.isDate($0, equalTo: Date(), toGranularity: .weekOfYear)
        }
        
        if let last = weekCompletions.max(), let index = completedDates.firstIndex(of: last) {
            completedDates.remove(at: index)
        }
    }
}
