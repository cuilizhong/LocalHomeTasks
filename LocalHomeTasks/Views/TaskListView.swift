import SwiftUI

struct TaskListView: View {
    var store: TaskStore
    @Binding var isShowingAddTask: Bool

    var body: some View {
        NavigationStack {
            Group {
                if store.sortedTasks.isEmpty {
                    emptyState
                        .padding(AppSpacing.screen)
                } else {
                    ScrollView {
                        LazyVStack(spacing: 10) {
                            ForEach(store.sortedTasks) { task in
                                NavigationLink {
                                    TaskDetailView(store: store, taskID: task.id)
                                } label: {
                                    TaskRowView(task: task, status: store.taskStatus(for: task))
                                }
                                .buttonStyle(.plain)
                                .contextMenu {
                                    Button {
                                        Task {
                                            await store.markComplete(task)
                                        }
                                    } label: {
                                        Label("Mark Complete", systemImage: "checkmark.circle")
                                    }

                                    Button(role: .destructive) {
                                        Task {
                                            await store.delete(task)
                                        }
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }
                                }
                                .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                    Button(role: .destructive) {
                                        Task {
                                            await store.delete(task)
                                        }
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }

                                    Button {
                                        Task {
                                            await store.markComplete(task)
                                        }
                                    } label: {
                                        Label("Complete", systemImage: "checkmark.circle")
                                    }
                                    .tint(AppColor.primary)
                                }
                            }
                        }
                        .padding(AppSpacing.screen)
                    }
                }
            }
            .background(AppColor.background)
            .navigationTitle("Tasks")
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

    private var emptyState: some View {
        EmptyStateView(
            title: "No maintenance tasks",
            message: "Create your first recurring task, like changing a filter or servicing an appliance.",
            systemImage: "checklist",
            actionTitle: "Add Task"
        ) {
            isShowingAddTask = true
        }
    }
}
