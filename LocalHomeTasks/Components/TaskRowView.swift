import SwiftUI

struct TaskRowView: View {
    let task: MaintenanceTask
    let status: TaskStatus

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: iconName)
                .font(.headline)
                .foregroundStyle(statusColor)
                .frame(width: 32, height: 32)
                .background(statusBackground)
                .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))

            VStack(alignment: .leading, spacing: 6) {
                Text(task.title)
                    .font(.body.weight(.medium))
                    .foregroundStyle(AppColor.textPrimary)
                    .lineLimit(2)

                Text("Due \(task.nextDueDate.formatted(date: .abbreviated, time: .omitted))")
                    .font(.subheadline)
                    .foregroundStyle(AppColor.textSecondary)

                HStack(spacing: 8) {
                    Text(task.recurrence.title)
                        .font(.caption.weight(.medium))
                        .foregroundStyle(AppColor.textSecondary)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(AppColor.background)
                        .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))

                    if task.reminderEnabled {
                        Image(systemName: "bell")
                            .font(.caption)
                            .foregroundStyle(AppColor.primary)
                            .accessibilityLabel("Reminder enabled")
                    }
                }
            }

            Spacer(minLength: 8)

            StatusBadge(status: status)
        }
        .padding(AppSpacing.row)
        .background(AppColor.surface)
        .overlay(
            RoundedRectangle(cornerRadius: AppSpacing.cornerRadius, style: .continuous)
                .stroke(AppColor.border, lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: AppSpacing.cornerRadius, style: .continuous))
    }

    private var iconName: String {
        switch status {
        case .overdue:
            "exclamationmark.circle"
        case .dueSoon:
            "clock"
        case .upcoming:
            "calendar"
        }
    }

    private var statusColor: Color {
        switch status {
        case .overdue:
            AppColor.overdue
        case .dueSoon:
            AppColor.dueSoon
        case .upcoming:
            AppColor.upcoming
        }
    }

    private var statusBackground: Color {
        switch status {
        case .overdue:
            AppColor.overdueSoft
        case .dueSoon:
            AppColor.dueSoonSoft
        case .upcoming:
            AppColor.upcomingSoft
        }
    }
}
