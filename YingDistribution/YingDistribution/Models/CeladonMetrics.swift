import Foundation

struct CeladonMetrics {
    let totalIterations: Int
    let aggregateYield: Double
    let zenithMultiplier: Double
    let buckets: [ZirconBucket]
    let tierBreakdown: [CinnabarTier: TierDigest]

    var rtp: Double {
        guard totalIterations > 0 else { return 0 }
        return aggregateYield / Double(totalIterations)
    }

    var collisionFrequency: Double {
        guard totalIterations > 0 else { return 0 }
        let wins = buckets.filter { $0.nadir > 0 }.reduce(0) { $0 + $1.census }
        return Double(wins) / Double(totalIterations)
    }

    var expectancyValue: Double {
        return rtp
    }

    var cumulativeLikelihood: [Double] {
        var cumulative = [Double]()
        var running: Double = 0
        for bucket in buckets {
            running += bucket.likelihood
            cumulative.append(running)
        }
        return cumulative
    }

    struct TierDigest {
        let tier: CinnabarTier
        var census: Int
        var likelihood: Double
        var rtpFragment: Double
        var averageYield: Double
    }
}

struct CobaltConfig {
    var iterationQuantum: Int
    var wagerAmount: Double
    var cascadeMode: CascadeMode
    var isLineSimulated: Bool

    enum CascadeMode: String, CaseIterable {
        case solitary = "Solitary Line"
        case aggregate = "Aggregate"
        case universal = "Universal"
    }

    static let presets: [Int] = [1_000, 5_000, 10_000, 50_000, 100_000, 500_000, 1_000_000]

    static let `default` = CobaltConfig(
        iterationQuantum: 10_000,
        wagerAmount: 1.0,
        cascadeMode: .universal,
        isLineSimulated: true
    )
}
