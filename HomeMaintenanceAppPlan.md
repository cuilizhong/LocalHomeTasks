# LocalHomeTasks Feature And Technical Plan

## 1. Project Overview

LocalHomeTasks is a SwiftUI iOS app for tracking recurring home maintenance tasks, upcoming due dates, overdue items, and optional local reminders.

The app is designed as a lightweight local-first utility. It focuses on quick task entry, clear due-date visibility, reliable recurrence behavior, and simple reminder settings.

## 2. Core Features

### Dashboard

The dashboard gives users an immediate overview of home maintenance status.

- Upcoming tasks sorted by next due date
- Overdue task count
- Due-soon task count
- Total active task count
- Quick access to add a new task
- Empty state for users with no saved tasks

### Task Management

Users can manage recurring maintenance tasks from a clean SwiftUI list interface.

- Add a task
- Edit a task
- Delete a task
- View task details
- Mark a task complete
- Save the last completion date
- Automatically advance the next due date

Each task supports:

- Title
- Notes
- Next due date
- Monthly or yearly recurrence
- Optional reminder
- Reminder lead time
- Created and updated timestamps

### Local Persistence

Tasks and settings are stored locally so the app remains useful offline and saved entries remain available after closing and reopening the app.

Preferred storage is SwiftData for modern iOS versions. If broader compatibility is needed, the same app structure can support JSON file persistence or Core Data.

### Local Reminders

The app uses iOS local notifications for reminder alerts.

- Notification permission is requested when reminders are enabled
- One reminder is scheduled per task
- Reminders update when a task changes
- Reminders are canceled when a task is deleted or disabled
- Completing a task updates the future reminder date

### Settings

The settings screen keeps reminder behavior simple and predictable.

- Global reminder enable or disable
- Default reminder lead days
- Notification permission status

## 3. Development Framework And Architecture

The app uses a lightweight SwiftUI architecture with clear separation between UI, state, persistence, and system services. The goal is to keep the code easy to read, easy to test, and simple enough for a local-only utility app.

### Technology Stack

- Language: Swift
- UI framework: SwiftUI
- Navigation: `NavigationStack` and sheet-based forms
- Persistence: SwiftData for iOS 17+, with a Codable JSON fallback option
- Notifications: `UserNotifications`
- Testing: Swift Testing framework for pure logic tests
- App lifecycle: SwiftUI `App` protocol
- Icons: SF Symbols

### Architecture Pattern

Use a small MV-style SwiftUI structure with service-backed stores.

- Views own presentation state only, such as selected task, sheet visibility, and form fields.
- Stores own app data, mutations, persistence calls, and coordination with services.
- Services own reusable system or domain behavior, such as recurring date calculation and notification scheduling.
- Models remain plain and predictable so they can be persisted and tested easily.

This avoids over-engineering while still keeping business logic out of SwiftUI views.

### Proposed File Structure

```text
LocalHomeTasks/
  App/
    LocalHomeTasksApp.swift
    AppContainer.swift

  Models/
    MaintenanceTask.swift
    RecurrenceRule.swift
    TaskStatus.swift
    ReminderSettings.swift

  Stores/
    TaskStore.swift
    SettingsStore.swift

  Persistence/
    TaskPersistence.swift
    SwiftDataTaskPersistence.swift
    JSONTaskPersistence.swift

  Services/
    RecurrenceCalculator.swift
    TaskStatusResolver.swift
    NotificationScheduler.swift
    DateProvider.swift

  Views/
    RootView.swift
    DashboardView.swift
    TaskListView.swift
    TaskDetailView.swift
    TaskFormView.swift
    SettingsView.swift

  Components/
    AppButton.swift
    StatusBadge.swift
    TaskRowView.swift
    MetricBlockView.swift
    EmptyStateView.swift

  Theme/
    AppColor.swift
    AppSpacing.swift
    AppStrings.swift

  Tests/
    RecurrenceCalculatorTests.swift
    TaskStatusResolverTests.swift
    TaskStoreTests.swift
```

### AppContainer

`AppContainer` creates and shares app-level dependencies.

```swift
struct AppContainer {
    let taskStore: TaskStore
    let settingsStore: SettingsStore
    let recurrenceCalculator: RecurrenceCalculator
    let notificationScheduler: NotificationScheduler
}
```

The app can inject this container into `RootView`, then pass stores down through initializers or `@Environment` where appropriate.

### State Management

Use SwiftUI-native state management.

- `@State` for local view state
- `@Binding` for form field bindings
- `@Observable` or `ObservableObject` for stores, depending on deployment target
- `@Environment` for shared app dependencies only when it reduces initializer noise
- `@Query` only if using SwiftData directly in simple list screens

For a small app, avoid introducing Combine-heavy pipelines or external architecture frameworks.

### Store Responsibilities

#### TaskStore

`TaskStore` is the main coordinator for task behavior.

Responsibilities:

- Load saved tasks
- Add tasks
- Update tasks
- Delete tasks
- Mark tasks complete
- Sort and filter tasks
- Recalculate due dates after completion
- Trigger reminder scheduling updates
- Expose dashboard counts and upcoming tasks

Suggested API:

```swift
@MainActor
final class TaskStore {
    private(set) var tasks: [MaintenanceTask] = []

    func load() async throws
    func add(_ task: MaintenanceTask) async throws
    func update(_ task: MaintenanceTask) async throws
    func delete(_ task: MaintenanceTask) async throws
    func markComplete(_ task: MaintenanceTask, completedAt: Date) async throws

    var overdueCount: Int { get }
    var dueSoonCount: Int { get }
    var upcomingTasks: [MaintenanceTask] { get }
}
```

#### SettingsStore

`SettingsStore` manages reminder preferences.

Responsibilities:

- Load and save reminder settings
- Store default reminder lead days
- Store global reminder enabled state
- Expose notification permission status when needed

Suggested API:

```swift
@MainActor
final class SettingsStore {
    private(set) var settings: ReminderSettings

    func load() async throws
    func updateRemindersEnabled(_ isEnabled: Bool) async throws
    func updateDefaultLeadDays(_ days: Int) async throws
}
```

### Persistence Layer

Use a protocol so storage can be swapped without changing UI or business logic.

```swift
protocol TaskPersistence {
    func loadTasks() async throws -> [MaintenanceTask]
    func saveTasks(_ tasks: [MaintenanceTask]) async throws
}
```

SwiftData implementation:

- Best option for iOS 17+
- Native model storage
- Good integration with SwiftUI

JSON implementation:

- Good fallback for simple local storage
- Easy to test with temporary file URLs
- Keeps persistence explicit and transparent

The store should depend on `TaskPersistence`, not a concrete storage class.

### Service Layer

#### RecurrenceCalculator

Pure logic type responsible for recurring date math.

```swift
struct RecurrenceCalculator {
    func nextDueDate(after dueDate: Date, recurrence: RecurrenceRule, calendar: Calendar) -> Date
    func nextFutureDueDate(from dueDate: Date, recurrence: RecurrenceRule, completedAt: Date, calendar: Calendar) -> Date
}
```

#### TaskStatusResolver

Pure logic type responsible for deriving task status.

```swift
struct TaskStatusResolver {
    func status(for dueDate: Date, today: Date, dueSoonWindowDays: Int, calendar: Calendar) -> TaskStatus
}
```

#### NotificationScheduler

System service responsible for local notification behavior.

```swift
protocol NotificationScheduling {
    func requestAuthorizationIfNeeded() async throws -> Bool
    func scheduleReminder(for task: MaintenanceTask) async throws
    func cancelReminder(for taskID: UUID)
}
```

The store should call the scheduler after task changes, but the scheduler should not own task data.

#### DateProvider

Use a date provider for testable date-sensitive behavior.

```swift
protocol DateProvider {
    var now: Date { get }
}

struct SystemDateProvider: DateProvider {
    var now: Date { Date() }
}
```

Tests can inject a fixed date provider for deterministic results.

### Navigation Structure

Use `RootView` with a `TabView` for the main app sections.

Tabs:

- Dashboard
- Tasks
- Settings

Suggested structure:

```swift
struct RootView: View {
    var body: some View {
        TabView {
            DashboardView()
                .tabItem { Label("Dashboard", systemImage: "house") }

            TaskListView()
                .tabItem { Label("Tasks", systemImage: "checklist") }

            SettingsView()
                .tabItem { Label("Settings", systemImage: "gearshape") }
        }
    }
}
```

Add and edit flows should use sheets because they are short, focused forms. Task details can use `NavigationLink` from the task list.

### Error Handling

Use simple user-facing error states.

- Persistence load failure: show a retryable error message
- Save failure: show an alert and keep the form open
- Notification permission denied: keep task saved but show reminders as unavailable
- Invalid form input: disable save and show inline validation where useful

Define app-level errors where the UI needs clear messaging.

```swift
enum AppError: LocalizedError {
    case failedToLoadTasks
    case failedToSaveTask
    case notificationPermissionDenied
}
```

### Dependency Direction

Dependencies should flow inward from UI to stores and services.

```text
Views -> Stores -> Persistence
Views -> Stores -> Services
Services -> Models
Persistence -> Models
```

Views should not directly write files, calculate recurrence edge cases, or schedule notifications.

### Concurrency

- Mark stores as `@MainActor` because they update UI-observed state
- Use async functions for persistence and notification calls
- Keep pure date logic synchronous
- Avoid manual thread management

### Testing Strategy By Layer

- Model tests: equality and Codable behavior when needed
- Service tests: recurrence and status rules
- Store tests: add, update, delete, complete, and reminder coordination
- Persistence tests: JSON load/save behavior with temporary file URLs
- UI tests can be added later for core flows if needed

This structure keeps the app small, but leaves enough boundaries to grow without rewriting the foundation.

## 4. Data Model

### MaintenanceTask

```swift
struct MaintenanceTask: Identifiable, Codable, Equatable {
    var id: UUID
    var title: String
    var notes: String
    var recurrence: RecurrenceRule
    var nextDueDate: Date
    var lastCompletedDate: Date?
    var reminderEnabled: Bool
    var reminderLeadDays: Int
    var createdAt: Date
    var updatedAt: Date
}
```

### RecurrenceRule

```swift
enum RecurrenceRule: String, Codable, CaseIterable {
    case monthly
    case yearly
}
```

### TaskStatus

```swift
enum TaskStatus: Equatable {
    case overdue(days: Int)
    case dueSoon(daysRemaining: Int)
    case upcoming(daysRemaining: Int)
}
```

### ReminderSettings

```swift
struct ReminderSettings: Codable, Equatable {
    var remindersEnabled: Bool
    var defaultLeadDays: Int
}
```

## 5. Recurring Date Rules

Recurring date behavior is isolated in `RecurrenceCalculator` so it can be tested independently from the UI and persistence layer.

### Monthly Schedule

- Completing a monthly task advances `nextDueDate` by one month from the previous due date.
- The app uses calendar-based date math instead of a fixed number of days.
- Month-end dates are normalized by the calendar.
- January 31 advances to February 28 or February 29, depending on leap year.
- March 31 advances to April 30.

### Yearly Schedule

- Completing a yearly task advances `nextDueDate` by one year from the previous due date.
- Leap-day dates are normalized by the calendar.
- February 29, 2024 advances to February 28, 2025.

### Completing An Overdue Task

When a task is overdue and marked complete, the app advances from the existing `nextDueDate` until the next due date is future-facing.

Example:

- Monthly task due May 1
- User completes it on September 18
- App advances May 1 to June 1, July 1, August 1, September 1, then October 1
- New next due date becomes October 1

This prevents a task from still appearing overdue immediately after completion when it has been missed for multiple recurrence cycles.

## 6. Task Status Rules

Task status is derived from the current date and the task's `nextDueDate`.

- `overdue`: the due date is before today
- `dueSoon`: the due date is today or within the configured due-soon window
- `upcoming`: the due date is beyond the due-soon window

The default due-soon window can be set to 7 days for a simple first implementation.

## 7. Notification Scheduling

`NotificationScheduler` wraps `UserNotifications` and keeps scheduling behavior separate from the views.

### Scheduling Rules

- Use a stable notification identifier based on the task ID
- Schedule one pending notification per task
- Reminder date equals `nextDueDate - reminderLeadDays`
- Skip scheduling if reminders are disabled globally
- Skip scheduling if reminders are disabled for the task
- Skip scheduling if the calculated reminder date is already in the past
- Cancel and reschedule when a task is edited or completed
- Cancel when a task is deleted

Example identifier:

```swift
"maintenance-task-\(task.id.uuidString)"
```

## 8. Screen Design

### DashboardView

Purpose: surface the most important maintenance information first.

Content:

- Navigation title: `Home Tasks`
- Summary metrics for overdue, due soon, and total tasks
- Upcoming task preview list
- Add task button
- Empty state when no tasks exist

### TaskListView

Purpose: provide full task browsing and management.

Content:

- Tasks sorted by next due date
- Status badge for each task
- Due date text
- Recurrence label
- Swipe actions for complete and delete
- Tap row to open details or edit
- Toolbar button for adding a task

### TaskFormView

Purpose: add and edit task details.

Fields:

- Task title
- Notes
- Next due date
- Schedule picker: monthly or yearly
- Reminder toggle
- Reminder lead days picker or stepper

Validation:

- Title cannot be empty
- Reminder lead days cannot be negative
- Save button is disabled until required fields are valid

### TaskDetailView

Purpose: show one task and its primary actions.

Content:

- Task title
- Notes
- Current status
- Last completed date
- Next due date
- Recurrence rule
- Reminder information

Actions:

- Mark complete
- Edit
- Delete

### SettingsView

Purpose: keep reminder preferences easy to adjust.

Content:

- Global reminders toggle
- Default reminder lead days
- Notification permission status

## 9. Visual Design System

The visual style is flat, quiet, and utility-focused. The app should feel like a practical home management tool rather than a decorative lifestyle app.

### Design Principles

- Use flat surfaces only
- Do not use gradients
- Do not use shadows
- Do not use glass effects, blur panels, or translucent cards
- Do not use decorative background shapes
- Do not use oversized hero layouts
- Use clear spacing, simple hierarchy, and native iOS interaction patterns
- Keep cards and grouped sections subtle, with borders or background contrast instead of elevation
- Prefer system symbols for actions and status indicators

### Theme Colors

The theme uses a clean green-based primary color because it fits home care, maintenance, and completion states without feeling too loud.

```swift
enum AppColor {
    static let primary = Color(red: 0.10, green: 0.45, blue: 0.32)      // Deep maintenance green
    static let primarySoft = Color(red: 0.88, green: 0.95, blue: 0.91)  // Light green surface
    static let background = Color(red: 0.97, green: 0.98, blue: 0.97)   // Warm off-white
    static let surface = Color.white
    static let border = Color(red: 0.86, green: 0.89, blue: 0.87)
    static let textPrimary = Color(red: 0.10, green: 0.12, blue: 0.11)
    static let textSecondary = Color(red: 0.39, green: 0.43, blue: 0.41)
    static let overdue = Color(red: 0.78, green: 0.18, blue: 0.16)
    static let overdueSoft = Color(red: 0.98, green: 0.90, blue: 0.89)
    static let dueSoon = Color(red: 0.74, green: 0.45, blue: 0.08)
    static let dueSoonSoft = Color(red: 0.99, green: 0.94, blue: 0.84)
    static let upcoming = Color(red: 0.10, green: 0.45, blue: 0.32)
    static let upcomingSoft = Color(red: 0.88, green: 0.95, blue: 0.91)
}
```

### Color Usage

- `primary`: main action buttons, selected tabs, active toggles, confirmation actions
- `primarySoft`: subtle selected backgrounds and completed states
- `background`: root screen background
- `surface`: list rows, form sections, dashboard metric blocks
- `border`: separators, row outlines, card outlines
- `textPrimary`: titles and important values
- `textSecondary`: descriptions, metadata, secondary labels
- `overdue`: overdue badges, warning text, destructive urgency indicators
- `dueSoon`: due-soon badges and medium-priority status labels
- `upcoming`: normal active status and completion-oriented indicators

### Typography

Use system typography to keep the interface native and readable.

- Large screen title: `.title2.weight(.semibold)`
- Section title: `.headline`
- Row title: `.body.weight(.medium)`
- Metadata: `.subheadline`
- Badge text: `.caption.weight(.medium)`
- Empty state title: `.headline`
- Empty state copy: `.subheadline`

Text should not scale with viewport width. Use Dynamic Type-friendly SwiftUI font styles instead of fixed custom sizes except for small badge tuning when needed.

### Layout And Spacing

Use a compact but breathable layout.

- Root padding: 16 points
- Vertical section spacing: 20 points
- Row internal padding: 12 points
- Metric block padding: 14 points
- Form field spacing: 12 points
- Button height: 44 points minimum
- Icon button touch target: 44 x 44 points
- Corner radius: 8 points maximum

Cards should be used only for dashboard metrics, repeated task rows, and small contained panels. Do not nest cards inside other cards.

### Components

#### Dashboard Metric Block

- White or soft status background
- 1 point border
- 8 point corner radius
- No shadow
- No gradient
- Contains icon, number, and label

#### Task Row

- White background
- 1 point border
- 8 point corner radius
- Leading status marker or SF Symbol
- Task title and next due date
- Compact recurrence label
- Status badge aligned to the trailing side when space allows

#### Status Badge

- Soft background color based on status
- Matching status text color
- Capsule or 6 point rounded rectangle
- Horizontal padding around text
- No shadow or glow

#### Primary Button

- Solid `primary` fill
- White text
- 8 point corner radius
- Minimum height of 44 points
- Optional SF Symbol before the label

#### Secondary Button

- White or clear background
- 1 point `border`
- `primary` text
- 8 point corner radius

#### Destructive Button

- Use system destructive role where available
- Use `overdue` for custom destructive text or icons
- Avoid large red filled areas unless confirming deletion

### Icons

Use SF Symbols for common actions.

- Add: `plus`
- Complete: `checkmark.circle`
- Edit: `pencil`
- Delete: `trash`
- Reminder: `bell`
- Overdue: `exclamationmark.circle`
- Due soon: `clock`
- Upcoming: `calendar`
- Settings: `gearshape`
- Home maintenance: `house`

### Empty States

Empty states should be simple and practical.

- Use one SF Symbol icon
- Short title
- One sentence of supporting copy
- One primary action button
- No illustration, gradient, or large decorative artwork

### Accessibility

- Maintain strong contrast for all status colors
- Do not rely on color alone for status; pair color with text and icons
- Support Dynamic Type using system font styles
- Keep tap targets at least 44 x 44 points
- Provide clear labels for icon-only buttons

## 10. Persistence Plan

### SwiftData Option

SwiftData is a good fit for this app because the data model is small, local, and relational complexity is minimal.

- Store tasks as SwiftData model objects
- Store reminder settings as a single settings object
- Use `@Query` for list screens
- Keep recurrence logic outside model objects for testability

### JSON Storage Option

A Codable JSON store is also practical for this app because the data set is small.

- Save tasks to the app documents directory
- Load tasks at app launch
- Write changes after add, edit, complete, and delete actions
- Keep tests simple by injecting a temporary file URL

### Recommended Direction

Use SwiftData when targeting iOS 17 or newer. Use JSON persistence when the app needs to support older iOS versions or when a minimal persistence layer is preferred.

## 11. Testing Plan

Use the Swift Testing framework for focused unit tests around behavior that must stay consistent.

### RecurrenceCalculatorTests

Test cases:

- Monthly date advances normally, such as January 15 to February 15
- Month-end advances consistently, such as January 31 to February 28 in a non-leap year
- Month-end advances consistently in leap year, such as January 31 to February 29, 2024
- March 31 advances to April 30
- Yearly date advances normally
- February 29 yearly schedule advances to February 28 in a non-leap year
- Completing an overdue monthly task advances until the due date is in the future
- Completing an overdue yearly task advances until the due date is in the future

### TaskStatusTests

Test cases:

- Date before today is overdue
- Date equal to today is due soon
- Date within the due-soon window is due soon
- Date beyond the due-soon window is upcoming

### NotificationSchedulerTests

Keep notification tests focused on pure helper behavior where possible.

- Correct notification identifier is generated
- Reminder date is calculated correctly
- Past reminder dates are skipped
- Disabled reminders do not schedule notifications

## 12. Implementation Notes

- Keep model types small and predictable
- Keep date calculations centralized in `RecurrenceCalculator`
- Avoid putting notification logic directly inside SwiftUI views
- Use standard SwiftUI controls and navigation patterns
- Prefer system components over custom UI for maintainability
- Use local timezone and the user's current calendar for date calculations
- Avoid force unwrapping dates or notification values
- Keep task completion as a single clear action that updates completion date, next due date, and reminder schedule together

## 13. Setup Instructions

1. Open `LocalHomeTasks.xcodeproj` in Xcode.
2. Select an iPhone simulator or a connected iPhone.
3. Choose the `LocalHomeTasks` scheme.
4. Build and run with `Cmd + R`.
5. Allow notification permission when testing reminders on a real device.
6. Run unit tests with `Cmd + U`.

## 14. Product Decisions

The current version uses these product decisions:

- The app is single-user and local-only.
- Accounts and sync are not part of the core app.
- A task supports one recurrence rule: monthly or yearly.
- Completing an overdue task advances to the next future due date.
- Reminder behavior depends on iOS notification permission.
- The UI uses clean, standard SwiftUI layouts.
- The app prioritizes reliability and clarity over heavy customization.
