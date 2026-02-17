import SwiftUI

struct EditHabitView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: HabitViewModel

    let habit: Habit

    @State private var title: String
    @State private var type: HabitType
    @State private var weeklyCount: Int

    init(viewModel: HabitViewModel, habit: Habit) {
        self.viewModel = viewModel
        self.habit = habit

        _title = State(initialValue: habit.title)

        switch habit.frequency {
        case .daily:
            _type = State(initialValue: .daily)
            _weeklyCount = State(initialValue: 3)
        case .weekly(let occurrences):
            _type = State(initialValue: .weekly)
            _weeklyCount = State(initialValue: occurrences)
        }
    }

    var body: some View {
        VStack(spacing: 20) {
            Text("Edit Habit")
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
            }

            HStack {
                Button("Cancel") {
                    dismiss()
                }
                .keyboardShortcut(.cancelAction)

                Spacer()

                Button("Save") {
                    saveChanges()
                }
                .keyboardShortcut(.defaultAction)
                .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
            .padding(.top)
        }
        .padding()
        .frame(width: 320)
    }

    private func saveChanges() {
        viewModel.updateHabit(habit, title: title, type: type, weeklyCount: weeklyCount)
        dismiss()
    }
}
