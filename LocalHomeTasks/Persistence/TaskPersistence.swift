import Foundation

protocol TaskPersistence {
    func loadTasks() async throws -> [MaintenanceTask]
    func saveTasks(_ tasks: [MaintenanceTask]) async throws
}
