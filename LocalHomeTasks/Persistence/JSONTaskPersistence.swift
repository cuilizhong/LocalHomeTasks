import Foundation

struct JSONTaskPersistence: TaskPersistence {
    private let fileURL: URL

    init(fileURL: URL? = nil) {
        if let fileURL {
            self.fileURL = fileURL
        } else {
            let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            self.fileURL = documentsDirectory.appendingPathComponent("maintenance-tasks.json")
        }
    }

    func loadTasks() async throws -> [MaintenanceTask] {
        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            return []
        }

        let data = try Data(contentsOf: fileURL)
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try decoder.decode([MaintenanceTask].self, from: data)
    }

    func saveTasks(_ tasks: [MaintenanceTask]) async throws {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        let data = try encoder.encode(tasks)
        try data.write(to: fileURL, options: [.atomic])
    }
}
