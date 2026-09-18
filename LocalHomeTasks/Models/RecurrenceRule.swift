import Foundation

enum RecurrenceRule: String, Codable, CaseIterable, Identifiable {
    case monthly
    case yearly

    var id: String { rawValue }

    var title: String {
        switch self {
        case .monthly:
            "Monthly"
        case .yearly:
            "Yearly"
        }
    }
}
