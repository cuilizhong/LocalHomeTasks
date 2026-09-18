import SwiftUI

struct SettingsView: View {
    var store: TaskStore

    @State private var remindersEnabled: Bool = false
    @State private var defaultLeadDays: Int = 3
    @State private var dueSoonWindowDays: Int = 7

    var body: some View {
        NavigationStack {
            Form {
                Section("Reminders") {
                    Toggle("Enable reminders", isOn: $remindersEnabled)
                        .onChange(of: remindersEnabled) { _, newValue in
                            saveSettings(remindersEnabled: newValue)
                        }

                    Stepper(value: $defaultLeadDays, in: 0...30) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Default reminder")
                            Text(defaultLeadDays == 0 ? "On due date" : "\(defaultLeadDays) days before due date")
                                .font(.caption)
                                .foregroundStyle(AppColor.textSecondary)
                        }
                    }
                    .onChange(of: defaultLeadDays) { _, newValue in
                        saveSettings(defaultLeadDays: newValue)
                    }
                }

                Section("Dashboard") {
                    Stepper(value: $dueSoonWindowDays, in: 1...30) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Due soon window")
                            Text("Tasks due within \(dueSoonWindowDays) days")
                                .font(.caption)
                                .foregroundStyle(AppColor.textSecondary)
                        }
                    }
                    .onChange(of: dueSoonWindowDays) { _, newValue in
                        saveSettings(dueSoonWindowDays: newValue)
                    }
                }

            }
            .scrollContentBackground(.hidden)
            .background(AppColor.background)
            .navigationTitle("Settings")
        }
        .tint(AppColor.primary)
        .onAppear {
            remindersEnabled = store.settings.remindersEnabled
            defaultLeadDays = store.settings.defaultLeadDays
            dueSoonWindowDays = store.settings.dueSoonWindowDays
        }
    }

    private func saveSettings(
        remindersEnabled: Bool? = nil,
        defaultLeadDays: Int? = nil,
        dueSoonWindowDays: Int? = nil
    ) {
        let updatedSettings = ReminderSettings(
            remindersEnabled: remindersEnabled ?? self.remindersEnabled,
            defaultLeadDays: defaultLeadDays ?? self.defaultLeadDays,
            dueSoonWindowDays: dueSoonWindowDays ?? self.dueSoonWindowDays
        )

        Task {
            await store.updateSettings(updatedSettings)
        }
    }
}
