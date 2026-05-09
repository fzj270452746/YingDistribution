import Foundation

struct ComparisonSnapshot: Codable, Identifiable {
    let id: UUID
    let baselineRecord: HistoryRecord
    let comparisonRecord: HistoryRecord
    let createdAt: Date
    let tierDeltas: [TierDelta]

    struct TierDelta: Codable {
        let tierName: String
        let likelihoodDelta: Double
        let rtpDelta: Double
    }

    enum CodingKeys: String, CodingKey {
        case id
        case baselineRecord
        case comparisonRecord
        case createdAt
        case tierDeltas
    }

    init(
        id: UUID,
        baselineRecord: HistoryRecord,
        comparisonRecord: HistoryRecord,
        createdAt: Date,
        tierDeltas: [TierDelta]? = nil
    ) {
        self.id = id
        self.baselineRecord = baselineRecord
        self.comparisonRecord = comparisonRecord
        self.createdAt = createdAt
        self.tierDeltas = tierDeltas ?? Self.makeTierDeltas(baselineRecord: baselineRecord, comparisonRecord: comparisonRecord)
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        baselineRecord = try container.decode(HistoryRecord.self, forKey: .baselineRecord)
        comparisonRecord = try container.decode(HistoryRecord.self, forKey: .comparisonRecord)
        createdAt = try container.decode(Date.self, forKey: .createdAt)
        tierDeltas = try container.decodeIfPresent([TierDelta].self, forKey: .tierDeltas)
            ?? Self.makeTierDeltas(baselineRecord: baselineRecord, comparisonRecord: comparisonRecord)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(baselineRecord, forKey: .baselineRecord)
        try container.encode(comparisonRecord, forKey: .comparisonRecord)
        try container.encode(createdAt, forKey: .createdAt)
        try container.encode(tierDeltas, forKey: .tierDeltas)
    }
    
    var rtpDelta: Double {
        comparisonRecord.metricsSummary.rtp - baselineRecord.metricsSummary.rtp
    }
    
    var hitDelta: Double {
        comparisonRecord.metricsSummary.collisionFrequency - baselineRecord.metricsSummary.collisionFrequency
    }
    
    var evDelta: Double {
        comparisonRecord.metricsSummary.evValue - baselineRecord.metricsSummary.evValue
    }
    
    var maxWinDelta: Double {
        comparisonRecord.metricsSummary.zenithMultiplier - baselineRecord.metricsSummary.zenithMultiplier
    }

    private static func makeTierDeltas(
        baselineRecord: HistoryRecord,
        comparisonRecord: HistoryRecord
    ) -> [TierDelta] {
        let comparisonByName = Dictionary(
            uniqueKeysWithValues: comparisonRecord.metricsSummary.tierSummaries.map { ($0.tierName, $0) }
        )

        return baselineRecord.metricsSummary.tierSummaries.compactMap { baselineTier in
            guard let comparisonTier = comparisonByName[baselineTier.tierName] else { return nil }
            return TierDelta(
                tierName: baselineTier.tierName,
                likelihoodDelta: comparisonTier.likelihood - baselineTier.likelihood,
                rtpDelta: comparisonTier.rtpFragment - baselineTier.rtpFragment
            )
        }
    }
}
