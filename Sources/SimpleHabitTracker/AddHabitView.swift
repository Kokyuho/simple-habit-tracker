import SwiftUI

struct AddHabitView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: HabitViewModel
    
    @State private var title = ""
    @State private var type: HabitType = .daily
    @State private var weeklyCount = 3
    
    var body: some View {
        VStack(spacing: 20) {
            Text("New Habit")
                .font(.title2)
                .fontWeight(.bold)
            
            TextField("Habit Name", text: $title)
                .textFieldStyle(.roundedBorder)
            
            Picker("Frequency", selection: $type) {
                Text("Daily").tag(HabitType.daily)
                Text("Weekly").tag(HabitType.weekly)
            }
            .pickerStyle(.segmented)
            
            if type == .weekly {
                HStack {
                    Text("Times per week:")
                    Stepper("\(weeklyCount)", value: $weeklyCount, in: 1...7)
                }
                .padding(.horizontal)
                .transition(.opacity)
            }
            
            HStack {
                Button("Cancel") {
                    dismiss()
                }
                .keyboardShortcut(.cancelAction)
                
                Spacer()
                
                Button("Add Habit") {
                    addHabit()
                }
                .keyboardShortcut(.defaultAction)
                .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
            .padding(.top)
        }
        .padding()
        .frame(width: 300)
    }
    
    private func addHabit() {
        viewModel.addHabit(title: title, type: type, weeklyCount: weeklyCount)
        dismiss()
    }
}
