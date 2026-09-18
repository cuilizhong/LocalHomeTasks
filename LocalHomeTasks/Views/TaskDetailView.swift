import SwiftUI

struct TaskDetailView: View {
    var store: TaskStore
    let taskID: UUID

    @Environment(\.dismiss) private var dismiss
    @State private var isShowingEdit = false
    @State private var isShowingDeleteConfirmation = false

    private var task: MaintenanceTask? {
        store.tasks.first { $0.id == taskID }
    }

    var body: some View {
        Group {
            if let task {
                ScrollView {
                    VStack(alignment: .leading, spacing: AppSpacing.section) {
                        header(for: task)
                        dateSection(for: task)
                        reminderSection(for: task)
                        notesSection(for: task)
                        actionSection(for: task)
                    }
                    .padding(AppSpacing.screen)
                }
                .background(AppColor.background)
                .navigationTitle("Task Details")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            isShowingEdit = true
                        } label: {
                            Image(systemName: "pencil")
                        }
                        .accessibilityLabel("Edit task")
                    }
                }
                .sheet(isPresented: $isShowingEdit) {
                    TaskFormView(task: task, defaultReminderLeadDays: store.settings.defaultLeadDays) { updatedTask in
                        Task {
                            await store.update(updatedTask)
                        }
                    }
                }
                .confirmationDialog("Delete this task?", isPresented: $isShowingDeleteConfirmation, titleVisibility: .visible) {
                    Button("Delete", role: .destructive) {
                        Task {
                            await store.delete(task)
                            dismiss()
                        }
                    }
                    Button("Cancel", role: .cancel) { }
                }
            } else {
                ContentUnavailableView("Task not found", systemImage: "questionmark.circle")
            }
        }
        .tint(AppColor.primary)
    }

    private func header(for task: MaintenanceTask) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            StatusBadge(status: store.taskStatus(for: task))

            Text(task.title)
                .font(.title2.weight(.semibold))
                .foregroundStyle(AppColor.textPrimary)

            Text(task.recurrence.title)
                .font(.subheadline)
                .foregroundStyle(AppColor.textSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(AppSpacing.screen)
        .background(AppColor.surface)
        .overlay(
            RoundedRectangle(cornerRadius: AppSpacing.cornerRadius, style: .continuous)
                .stroke(AppColor.border, lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: AppSpacing.cornerRadius, style: .continuous))
    }

    private func dateSection(for task: MaintenanceTask) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionTitle("Dates")
            valueRow("Next due", value: task.nextDueDate.formatted(date: .abbreviated, time: .omitted), icon: "calendar")

            if let lastCompletedDate = task.lastCompletedDate {
                valueRow("Last completed", value: lastCompletedDate.formatted(date: .abbreviated, time: .omitted), icon: "checkmark.circle")
            } else {
                valueRow("Last completed", value: "Not completed yet", icon: "checkmark.circle")
            }
        }
        .panelStyle()
    }

    private func reminderSection(for task: MaintenanceTask) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionTitle("Reminder")
            if task.reminderEnabled {
                valueRow("Reminder", value: task.reminderLeadDays == 0 ? "On due date" : "\(task.reminderLeadDays) days before", icon: "bell")
            } else {
                valueRow("Reminder", value: "Off", icon: "bell.slash")
            }
        }
        .panelStyle()
    }

    private func notesSection(for task: MaintenanceTask) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionTitle("Notes")
            Text(task.notes.isEmpty ? "No notes added." : task.notes)
                .font(.body)
                .foregroundStyle(task.notes.isEmpty ? AppColor.textSecondary : AppColor.textPrimary)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .panelStyle()
    }

    private func actionSection(for task: MaintenanceTask) -> some View {
        VStack(spacing: 12) {
            Button {
                Task {
                    await store.markComplete(task)
                }
            } label: {
                Label("Mark Complete", systemImage: "checkmark.circle")
                    .frame(maxWidth: .infinity)
                    .frame(height: AppSpacing.buttonHeight)
            }
            .buttonStyle(.borderedProminent)
            .tint(AppColor.primary)

            Button(role: .destructive) {
                isShowingDeleteConfirmation = true
            } label: {
                Label("Delete Task", systemImage: "trash")
                    .frame(maxWidth: .infinity)
                    .frame(height: AppSpacing.buttonHeight)
            }
            .buttonStyle(.bordered)
        }
    }

    private func sectionTitle(_ title: String) -> some View {
        Text(title)
            .font(.headline)
            .foregroundStyle(AppColor.textPrimary)
    }

    private func valueRow(_ title: String, value: String, icon: String) -> some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .foregroundStyle(AppColor.primary)
                .frame(width: 24)

            Text(title)
                .foregroundStyle(AppColor.textSecondary)

            Spacer()

            Text(value)
                .foregroundStyle(AppColor.textPrimary)
                .multilineTextAlignment(.trailing)
        }
        .font(.subheadline)
    }
}

private extension View {
    func panelStyle() -> some View {
        padding(AppSpacing.screen)
            .background(AppColor.surface)
            .overlay(
                RoundedRectangle(cornerRadius: AppSpacing.cornerRadius, style: .continuous)
                    .stroke(AppColor.border, lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: AppSpacing.cornerRadius, style: .continuous))
    }
}
