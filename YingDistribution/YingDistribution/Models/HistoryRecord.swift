import Foundation

struct HistoryRecord: Codable, Identifiable {
    let id: UUID
    let timestamp: Date
    let configSummary: ConfigSummary
    let metricsSummary: MetricsSummary
    
    struct ConfigSummary: Codable {
        let iterationQuantum: Int
        let wagerAmount: Double
        let cascadeMode: String
    }
    
    struct MetricsSummary: Codable {
        let rtp: Double
        let collisionFrequency: Double
        let evValue: Double
        let zenithMultiplier: Double
        let totalIterations: Int
        var tierSummaries: [TierSummary] = []

        struct TierSummary: Codable {
            let tierName: String
            let likelihood: Double
            let rtpFragment: Double
        }

        enum CodingKeys: String, CodingKey {
            case rtp
            case collisionFrequency
            case evValue
            case zenithMultiplier
            case totalIterations
            case tierSummaries
        }

        init(
            rtp: Double,
            collisionFrequency: Double,
            evValue: Double,
            zenithMultiplier: Double,
            totalIterations: Int,
            tierSummaries: [TierSummary] = []
        ) {
            self.rtp = rtp
            self.collisionFrequency = collisionFrequency
            self.evValue = evValue
            self.zenithMultiplier = zenithMultiplier
            self.totalIterations = totalIterations
            self.tierSummaries = tierSummaries
        }

        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            rtp = try container.decode(Double.self, forKey: .rtp)
            collisionFrequency = try container.decode(Double.self, forKey: .collisionFrequency)
            evValue = try container.decode(Double.self, forKey: .evValue)
            zenithMultiplier = try container.decode(Double.self, forKey: .zenithMultiplier)
            totalIterations = try container.decode(Int.self, forKey: .totalIterations)
            tierSummaries = try container.decodeIfPresent([TierSummary].self, forKey: .tierSummaries) ?? []
        }
    }
}
