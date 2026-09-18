import Foundation
import Observation

@MainActor
@Observable
final class TaskStore {
    private(set) var tasks: [MaintenanceTask] = []
    private(set) var settings: ReminderSettings = .defaultValue
    var errorMessage: String?
    private(set) var isLoaded = false

    private let taskPersistence: TaskPersistence
    private let settingsPersistence: SettingsPersistence
    private let recurrenceCalculator: RecurrenceCalculator
    private let statusResolver: TaskStatusResolver
    private let notificationScheduler: NotificationScheduling
    private let dateProvider: DateProvider
    private let calendar: Calendar

    init(
        taskPersistence: TaskPersistence = JSONTaskPersistence(),
        settingsPersistence: SettingsPersistence = UserDefaultsSettingsPersistence(),
        recurrenceCalculator: RecurrenceCalculator = RecurrenceCalculator(),
        statusResolver: TaskStatusResolver = TaskStatusResolver(),
        notificationScheduler: NotificationScheduling = NotificationScheduler(),
        dateProvider: DateProvider = SystemDateProvider(),
        calendar: Calendar = .current
    ) {
        self.taskPersistence = taskPersistence
        self.settingsPersistence = settingsPersistence
        self.recurrenceCalculator = recurrenceCalculator
        self.statusResolver = statusResolver
        self.notificationScheduler = notificationScheduler
        self.dateProvider = dateProvider
        self.calendar = calendar
    }

    var sortedTasks: [MaintenanceTask] {
        tasks.sorted { lhs, rhs in
            if lhs.nextDueDate == rhs.nextDueDate {
                return lhs.title.localizedCaseInsensitiveCompare(rhs.title) == .orderedAscending
            }

            return lhs.nextDueDate < rhs.nextDueDate
        }
    }

    var overdueCount: Int {
        tasks.filter { taskStatus(for: $0).priority == 0 }.count
    }

    var dueSoonCount: Int {
        tasks.filter { taskStatus(for: $0).priority == 1 }.count
    }

    var upcomingTasks: [MaintenanceTask] {
        Array(sortedTasks.prefix(5))
    }

    func load() async {
        do {
            settings = try await settingsPersistence.loadSettings()
            tasks = try await taskPersistence.loadTasks()
            seedSampleTasksIfNeeded()
            isLoaded = true
        } catch {
            errorMessage = "Unable to load saved tasks."
            isLoaded = true
        }
    }

    func add(_ task: MaintenanceTask) async {
        var newTask = task
        newTask.updatedAt = dateProvider.now
        tasks.append(newTask)
        await persistAndSchedule(task: newTask)
    }

    func update(_ task: MaintenanceTask) async {
        guard let index = tasks.firstIndex(where: { $0.id == task.id }) else { return }
        var updatedTask = task
        updatedTask.updatedAt = dateProvider.now
        tasks[index] = updatedTask
        await persistAndSchedule(task: updatedTask)
    }

    func delete(_ task: MaintenanceTask) async {
        tasks.removeAll { $0.id == task.id }
        notificationScheduler.cancelReminder(for: task.id)
        await persistTasks()
    }

    func markComplete(_ task: MaintenanceTask) async {
        guard let index = tasks.firstIndex(where: { $0.id == task.id }) else { return }

        let completedAt = dateProvider.now
        var completedTask = task
        completedTask.lastCompletedDate = completedAt
        completedTask.nextDueDate = recurrenceCalculator.nextFutureDueDate(
            from: task.nextDueDate,
            recurrence: task.recurrence,
            completedAt: completedAt,
            calendar: calendar
        )
        completedTask.updatedAt = completedAt

        tasks[index] = completedTask
        await persistAndSchedule(task: completedTask)
    }

    func updateSettings(_ newSettings: ReminderSettings) async {
        settings = newSettings

        do {
            try await settingsPersistence.saveSettings(settings)
            await rescheduleAllReminders()
        } catch {
            errorMessage = "Unable to save reminder settings."
        }
    }

    func taskStatus(for task: MaintenanceTask) -> TaskStatus {
        statusResolver.status(
            for: task.nextDueDate,
            today: dateProvider.now,
            dueSoonWindowDays: settings.dueSoonWindowDays,
            calendar: calendar
        )
    }

    func clearError() {
        errorMessage = nil
    }

    private func seedSampleTasksIfNeeded() {
        #if DEBUG
        guard tasks.isEmpty else { return }
        tasks = SampleTasks.make(calendar: calendar, today: dateProvider.now)
        Task {
            await persistTasks()
        }
        #endif
    }

    private func persistAndSchedule(task: MaintenanceTask) async {
        await persistTasks()

        do {
            try await notificationScheduler.scheduleReminder(
                for: task,
                remindersEnabled: settings.remindersEnabled
            )
        } catch {
            errorMessage = "Task saved, but the reminder could not be scheduled."
        }
    }

    private func persistTasks() async {
        do {
            try await taskPersistence.saveTasks(tasks)
        } catch {
            errorMessage = "Unable to save task changes."
        }
    }

    private func rescheduleAllReminders() async {
        for task in tasks {
            do {
                try await notificationScheduler.scheduleReminder(
                    for: task,
                    remindersEnabled: settings.remindersEnabled
                )
            } catch {
                errorMessage = "Some reminders could not be updated."
            }
        }
    }
}
