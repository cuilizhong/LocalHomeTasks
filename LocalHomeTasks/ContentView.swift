import SwiftUI

struct ContentView: View {
    @State private var store = TaskStore()
    @State private var isShowingAddTask = false
    @State private var isShowingSplash = true
    @State private var didStartLoading = false

    var body: some View {
        ZStack {
            mainContent
                .opacity(isShowingSplash ? 0 : 1)

            if isShowingSplash {
                SplashView()
                    .transition(.opacity)
            }
        }
        .task {
            await loadInitialData()
        }
        .sheet(isPresented: $isShowingAddTask) {
            TaskFormView(defaultReminderLeadDays: store.settings.defaultLeadDays) { task in
                Task {
                    await store.add(task)
                }
            }
        }
        .alert("Something went wrong", isPresented: errorBinding) {
            Button("OK") {
                store.clearError()
            }
        } message: {
            Text(store.errorMessage ?? "Please try again.")
        }
    }

    private var mainContent: some View {
        TabView {
            DashboardView(store: store, isShowingAddTask: $isShowingAddTask)
                .tabItem {
                    Label("Dashboard", systemImage: "house")
                }

            TaskListView(store: store, isShowingAddTask: $isShowingAddTask)
                .tabItem {
                    Label("Tasks", systemImage: "checklist")
                }

            SettingsView(store: store)
                .tabItem {
                    Label("Settings", systemImage: "gearshape")
                }
        }
        .tint(AppColor.primary)
    }

    private func loadInitialData() async {
        guard !didStartLoading else { return }
        didStartLoading = true

        async let loadTasks: Void = store.load()
        async let minimumSplashTime: Void = waitForMinimumSplashTime()
        _ = await (loadTasks, minimumSplashTime)

        withAnimation(.easeOut(duration: 0.25)) {
            isShowingSplash = false
        }
    }

    private func waitForMinimumSplashTime() async {
        try? await Task.sleep(for: .milliseconds(850))
    }

    private var errorBinding: Binding<Bool> {
        Binding(
            get: { store.errorMessage != nil },
            set: { isPresented in
                if !isPresented {
                    store.clearError()
                }
            }
        )
    }
}

#Preview {
    ContentView()
}
