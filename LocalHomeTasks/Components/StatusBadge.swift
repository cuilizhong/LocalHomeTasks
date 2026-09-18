import SwiftUI

struct StatusBadge: View {
    let status: TaskStatus

    var body: some View {
        Label(status.title, systemImage: iconName)
            .font(.caption.weight(.medium))
            .foregroundStyle(foregroundColor)
            .lineLimit(1)
            .padding(.horizontal, 8)
            .padding(.vertical, 5)
            .background(backgroundColor)
            .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
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

    private var foregroundColor: Color {
        switch status {
        case .overdue:
            AppColor.overdue
        case .dueSoon:
            AppColor.dueSoon
        case .upcoming:
            AppColor.upcoming
        }
    }

    private var backgroundColor: Color {
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
