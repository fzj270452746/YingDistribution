import Foundation

enum InsightSeverity: String, Codable {
    case info
    case warning
    case success
}

struct InsightCard: Codable, Identifiable {
    let id: UUID
    let ruleId: String
    let title: String
    let description: String
    let severity: InsightSeverity
}
