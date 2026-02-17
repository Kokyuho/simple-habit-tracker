import SwiftUI

struct StatisticsView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: HabitViewModel
    
    // We visualize the last 14 days
    private let daysToShow = 14
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("Consistency Graph")
                    .font(.title)
                
                Spacer()
                
                Button("Done") {
                    dismiss()
                }
                .keyboardShortcut(.defaultAction)
            }
            .padding()
            
            List {
                if !viewModel.dailyHabits.isEmpty {
                    Section(header: Text("Daily Habits")) {
                        ForEach(viewModel.dailyHabits) { habit in
                            DailyRow(habit: habit, daysToShow: daysToShow)
                        }
                    }
                }
                
                if !viewModel.weeklyHabits.isEmpty {
                    Section(header: Text("Weekly Goals")) {
                        ForEach(viewModel.weeklyHabits) { habit in
                            WeeklyRow(habit: habit, daysToShow: daysToShow)
                        }
                    }
                }
            }
        }
        .frame(minWidth: 600, minHeight: 500)
    }
}

// Helper Views
struct DailyRow: View {
    let habit: Habit
    let daysToShow: Int
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(habit.title)
                .font(.headline)
            
            HStack(spacing: 4) {
                ForEach(0..<daysToShow, id: \.self) { offset in
                    let date = Calendar.current.date(byAdding: .day, value: -((daysToShow - 1) - offset), to: Date())!
                    let isCompleted = habit.completedDates.contains { Calendar.current.isDate($0, inSameDayAs: date) }
                    
                    DayCell(date: date, isFilled: isCompleted, color: .green)
                }
            }
        }
        .padding(.vertical, 8)
    }
}

struct WeeklyRow: View {
    let habit: Habit
    let daysToShow: Int
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(habit.title)
                .font(.headline)
            
            HStack(spacing: 4) {
                ForEach(0..<daysToShow, id: \.self) { offset in
                    let date = Calendar.current.date(byAdding: .day, value: -((daysToShow - 1) - offset), to: Date())!
                    // Check if *any* completion happened on this specific date
                    let isCompleted = habit.completedDates.contains { Calendar.current.isDate($0, inSameDayAs: date) }
                    
                    DayCell(date: date, isFilled: isCompleted, color: .blue)
                }
            }
        }
        .padding(.vertical, 8)
    }
}

struct DayCell: View {
    let date: Date
    let isFilled: Bool
    let color: Color
    
    var body: some View {
        VStack {
            Rectangle()
                .fill(isFilled ? color : Color.gray.opacity(0.3))
                .frame(width: 20, height: 20)
                .cornerRadius(4)
            
            Text(dateString(for: date))
                .font(.caption2)
                .foregroundColor(.secondary)
        }
    }
    
    func dateString(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter.string(from: date)
    }
}
