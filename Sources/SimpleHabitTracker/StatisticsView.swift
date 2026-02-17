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
                ForEach(viewModel.habits) { habit in
                    VStack(alignment: .leading) {
                        Text(habit.title)
                            .font(.headline)
                        
                        HStack(spacing: 4) {
                            ForEach(0..<daysToShow, id: \.self) { offset in
                                let date = Calendar.current.date(byAdding: .day, value: -((daysToShow - 1) - offset), to: Date())!
                                let isCompleted = habit.completedDates.contains { Calendar.current.isDate($0, inSameDayAs: date) }
                                
                                VStack {
                                    Rectangle()
                                        .fill(isCompleted ? Color.green : Color.gray.opacity(0.3))
                                        .frame(width: 20, height: 20)
                                        .cornerRadius(4)
                                    
                                    Text(dateString(for: date))
                                        .font(.caption2)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                    }
                    .padding(.vertical, 8)
                }
            }
        }
        .frame(minWidth: 600, minHeight: 500)
    }
    
    func dateString(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter.string(from: date)
    }
}
