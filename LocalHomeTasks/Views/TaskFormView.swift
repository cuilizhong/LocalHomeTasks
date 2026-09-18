import SwiftUI

struct TaskFormView: View {
    @Environment(\.dismiss) private var dismiss

    let task: MaintenanceTask?
    let defaultReminderLeadDays: Int
    let onSave: (MaintenanceTask) -> Void

    @State private var title: String
    @State private var notes: String
    @State private var recurrence: RecurrenceRule
    @State private var nextDueDate: Date
    @State private var reminderEnabled: Bool
    @State private var reminderLeadDays: Int

    init(
        task: MaintenanceTask? = nil,
        defaultReminderLeadDays: Int,
        onSave: @escaping (MaintenanceTask) -> Void
    ) {
        self.task = task
        self.defaultReminderLeadDays = defaultReminderLeadDays
        self.onSave = onSave

        _title = State(initialValue: task?.title ?? "")
        _notes = State(initialValue: task?.notes ?? "")
        _recurrence = State(initialValue: task?.recurrence ?? .monthly)
        _nextDueDate = State(initialValue: task?.nextDueDate ?? Date())
        _reminderEnabled = State(initialValue: task?.reminderEnabled ?? false)
        _reminderLeadDays = State(initialValue: task?.reminderLeadDays ?? defaultReminderLeadDays)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Task") {
                    TextField("Task title", text: $title)
                    TextField("Notes", text: $notes, axis: .vertical)
                        .lineLimit(3, reservesSpace: true)
                }

                Section("Schedule") {
                    DatePicker("Next due date", selection: $nextDueDate, displayedComponents: .date)

                    Picker("Repeats", selection: $recurrence) {
                        ForEach(RecurrenceRule.allCases) { rule in
                            Text(rule.title).tag(rule)
                        }
                    }
                    .pickerStyle(.segmented)
                }

                Section("Reminder") {
                    Toggle("Reminder", isOn: $reminderEnabled)

                    Stepper(value: $reminderLeadDays, in: 0...30) {
                        Text(reminderLeadDays == 0 ? "On due date" : "\(reminderLeadDays) days before")
                    }
                    .disabled(!reminderEnabled)
                }
            }
            .scrollContentBackground(.hidden)
            .background(AppColor.background)
            .navigationTitle(task == nil ? "Add Task" : "Edit Task")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        save()
                    }
                    .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
        .tint(AppColor.primary)
    }

    private func save() {
        let now = Date()
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedNotes = notes.trimmingCharacters(in: .whitespacesAndNewlines)

        let savedTask = MaintenanceTask(
            id: task?.id ?? UUID(),
            title: trimmedTitle,
            notes: trimmedNotes,
            recurrence: recurrence,
            nextDueDate: nextDueDate,
            lastCompletedDate: task?.lastCompletedDate,
            reminderEnabled: reminderEnabled,
            reminderLeadDays: reminderLeadDays,
            createdAt: task?.createdAt ?? now,
            updatedAt: now
        )

        onSave(savedTask)
        dismiss()
    }
}
