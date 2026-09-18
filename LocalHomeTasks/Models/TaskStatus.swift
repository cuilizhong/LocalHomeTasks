import Foundation

enum TaskStatus: Equatable {
    case overdue(days: Int)
    case dueSoon(daysRemaining: Int)
    case upcoming(daysRemaining: Int)

    var title: String {
        switch self {
        case .overdue(let days):
            days == 1 ? "1 day overdue" : "\(days) days overdue"
        case .dueSoon(let daysRemaining):
            daysRemaining == 0 ? "Due today" : "Due in \(daysRemaining)d"
        case .upcoming(let daysRemaining):
            "In \(daysRemaining)d"
        }
    }

    var priority: Int {
        switch self {
        case .overdue:
            0
        case .dueSoon:
            1
        case .upcoming:
            2
        }
    }
}
