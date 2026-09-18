# LocalHomeTasks

Language: English | [中文](README.zh-CN.md)

LocalHomeTasks is a local-first iOS app for tracking recurring home maintenance tasks, upcoming due dates, overdue work, and optional reminders.

The app is built with Swift and SwiftUI. It uses a clean flat visual style, local JSON persistence, and iOS local notifications. It is designed for simple household maintenance workflows such as replacing HVAC filters, checking smoke detectors, cleaning dryer vents, and servicing appliances.

## Features

- Dashboard with overdue, due-soon, and total task counts
- Upcoming task preview sorted by next due date
- Full task list with add, edit, delete, and complete actions
- Task detail screen with due date, recurrence, reminder, notes, and completion status
- Monthly and yearly recurring schedules
- Automatic due-date advancement after a task is completed
- Consistent handling for month-end dates and leap-year yearly schedules
- Local reminder scheduling with iOS notifications
- Simple reminder settings
- Local-only storage so tasks remain available after closing the app
- Debug sample data for quick review and testing
- Flat app icon and matching launch/splash experience

## App Flow

The app has three main tabs:

### Dashboard

The dashboard gives a quick overview of maintenance status:

- Overdue count
- Due-soon count
- Total active tasks
- Next upcoming tasks

### Tasks

The task list is the main management screen:

- View all tasks sorted by next due date
- Open task details
- Mark a task complete
- Delete a task
- Add new recurring tasks

### Settings

Settings focus on reminder behavior:

- Enable or disable reminders globally
- Set the default reminder lead time
- Adjust the due-soon window used by dashboard status

## Design

LocalHomeTasks uses a flat, practical visual style suitable for a utility app.

Design rules:

- No gradients
- No shadows
- No glass effects
- No decorative background shapes
- System typography
- SF Symbols for actions and status icons
- Subtle borders instead of elevation
- Green primary color for home maintenance and completion states

Primary theme:

- Primary green: `#1A7352`
- Background: warm off-white
- Surface: white
- Overdue: red
- Due soon: amber
- Upcoming: green

## Architecture

The app uses a lightweight SwiftUI architecture with clear separation between UI, state, persistence, and services.

```text
LocalHomeTasks/
  Components/
    EmptyStateView.swift
    MetricBlockView.swift
    StatusBadge.swift
    TaskRowView.swift

  Models/
    MaintenanceTask.swift
    RecurrenceRule.swift
    ReminderSettings.swift
    SampleTasks.swift
    TaskStatus.swift

  Persistence/
    JSONTaskPersistence.swift
    SettingsPersistence.swift
    TaskPersistence.swift

  Services/
    DateProvider.swift
    NotificationScheduler.swift
    RecurrenceCalculator.swift
    TaskStatusResolver.swift

  Stores/
    TaskStore.swift

  Theme/
    AppColor.swift
    AppSpacing.swift

  Views/
    DashboardView.swift
    SettingsView.swift
    SplashView.swift
    TaskDetailView.swift
    TaskFormView.swift
    TaskListView.swift

  ContentView.swift
  LocalHomeTasksApp.swift
```

### Main Layers

| Layer | Responsibility |
| --- | --- |
| Views | SwiftUI screens and user interaction |
| Components | Reusable UI pieces |
| Store | Task state, mutations, dashboard counts, and coordination |
| Persistence | Local JSON task storage and UserDefaults settings |
| Services | Recurrence calculation, status resolution, notifications, date provider |
| Models | Codable task and settings data |

## Recurrence Behavior

Recurring date logic is centralized in `RecurrenceCalculator`.

Monthly tasks:

- Advance by one calendar month
- Preserve practical month-end behavior
- Example: January 31 -> February 28 or February 29
- Example: March 31 -> April 30

Yearly tasks:

- Advance by one calendar year
- Handles leap-day schedules consistently
- Example: February 29, 2024 -> February 28, 2025

Overdue completion:

- Completing an overdue task advances from the existing due date until the next due date is in the future
- This avoids a task staying overdue immediately after completion

Example:

```text
Monthly task due May 1
Completed September 18
Next due date becomes October 1
```

## Local Notifications

The app uses `UserNotifications` for reminders.

Reminder behavior:

- Notification permission is requested when reminders are enabled
- One pending notification is scheduled per task
- Editing a task reschedules its reminder
- Completing a task advances the due date and reschedules its reminder
- Deleting a task cancels its reminder
- Reminder dates in the past are skipped

## Local Storage

Tasks are stored locally as JSON in the app documents directory.

Settings are stored with `UserDefaults`.

The app does not use:

- Accounts
- Cloud sync
- Shared households
- Remote APIs
- In-app purchases

## Debug Sample Data

Debug builds automatically create sample tasks when local storage is empty.

The sample data includes:

- Overdue monthly task
- Due-soon monthly task
- Upcoming monthly task
- Upcoming yearly task
- Overdue yearly task

This makes it easy to review the dashboard and task status UI immediately after launching the app.

To reset the sample data during development, delete the app from the simulator or device and run it again.

## Requirements

- Xcode 15 or newer
- iOS 17 or newer
- SwiftUI

## Running The App

1. Open `LocalHomeTasks.xcodeproj` in Xcode.
2. Select the `LocalHomeTasks` scheme.
3. Choose an iPhone simulator or a connected iPhone.
4. Build and run with `Cmd + R`.
5. Allow notification permission if testing reminders.

## Project Notes

- The UI uses SwiftUI's Observation system through `@Observable`.
- `TaskStore` is marked `@MainActor` because it updates UI-observed state.
- Date-sensitive logic is isolated so it can be tested independently.
- The notification service does not own task data; it only schedules and cancels reminders.
- The app icon uses PNG assets in `AppIcon.appiconset`, because iOS app icons do not support SVG references.

## Validation Focus

The most important logic to validate is recurring date behavior:

- Monthly schedules
- Month-end dates
- Yearly schedules
- Leap-day yearly recurrence
- Completing overdue tasks
- Task status resolution for overdue, due soon, and upcoming states

These rules are implemented outside the UI so they can be covered by focused unit tests as the project grows.
