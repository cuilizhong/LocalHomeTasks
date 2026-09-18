import SwiftUI

struct DashboardView: View {
    var store: TaskStore
    @Binding var isShowingAddTask: Bool

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: AppSpacing.section) {
                    metrics
                    upcomingSection
                }
                .padding(AppSpacing.screen)
            }
            .background(AppColor.background)
            .navigationTitle("Home Tasks")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        isShowingAddTask = true
                    } label: {
                        Image(systemName: "plus")
                    }
                    .accessibilityLabel("Add task")
                }
            }
        }
        .tint(AppColor.primary)
    }

    private var metrics: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Overview")
                .font(.headline)
                .foregroundStyle(AppColor.textPrimary)

            HStack(spacing: 10) {
                MetricBlockView(
                    title: "Overdue",
                    value: "\(store.overdueCount)",
                    systemImage: "exclamationmark.circle",
                    tint: AppColor.overdue,
                    background: AppColor.overdueSoft
                )

                MetricBlockView(
                    title: "Due soon",
                    value: "\(store.dueSoonCount)",
                    systemImage: "clock",
                    tint: AppColor.dueSoon,
                    background: AppColor.dueSoonSoft
                )

                MetricBlockView(
                    title: "Total",
                    value: "\(store.tasks.count)",
                    systemImage: "checklist",
                    tint: AppColor.primary,
                    background: AppColor.primarySoft
                )
            }
        }
    }

    private var upcomingSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Due Next")
                .font(.headline)
                .foregroundStyle(AppColor.textPrimary)

            if store.upcomingTasks.isEmpty {
                EmptyStateView(
                    title: "No tasks yet",
                    message: "Add recurring maintenance tasks to track upcoming home work.",
                    systemImage: "house",
                    actionTitle: "Add Task"
                ) {
                    isShowingAddTask = true
                }
            } else {
                VStack(spacing: 10) {
                    ForEach(store.upcomingTasks) { task in
                        NavigationLink {
                            TaskDetailView(store: store, taskID: task.id)
                        } label: {
                            TaskRowView(task: task, status: store.taskStatus(for: task))
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }
}
