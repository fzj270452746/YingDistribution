import Foundation
import UIKit

final class ObsidianDistiller {

    private let lattice: [[Double]] = [
        [0.00, 0.72],
        [0.01, 0.78],
        [0.02, 0.82],
        [0.03, 0.85],
        [0.05, 0.88],
        [0.10, 0.90],
        [0.20, 0.92],
        [0.30, 0.93],
        [0.40, 0.94],
        [0.50, 0.95],
        [0.60, 0.955],
        [0.70, 0.96],
        [0.80, 0.965],
        [0.90, 0.97],
        [1.00, 0.975],
        [1.50, 0.98],
        [2.00, 0.985],
        [3.00, 0.99],
        [5.00, 0.993],
        [10.0, 0.996],
        [20.0, 0.998],
        [50.0, 0.999],
        [100.0, 0.9995],
        [200.0, 0.9999],
        [500.0, 1.0000]
    ]

    private var rng: SystemRandomNumberGenerator

    init() {
        self.rng = SystemRandomNumberGenerator()
    }

    func rendOutcomes(config: CobaltConfig, onProgress: @escaping (Double) -> Void, completion: @escaping (CeladonMetrics) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            let metrics = self.percolate(config: config, onProgress: onProgress)
            DispatchQueue.main.async {
                completion(metrics)
            }
        }
    }

    private func percolate(config: CobaltConfig, onProgress: @escaping (Double) -> Void) -> CeladonMetrics {
        var accumulator: Double = 0
        var apexMultiplier: Double = 0
        var multiplierCensus: [Double: Int] = [:]
        let total = config.iterationQuantum
        let chunkSize = max(1, total / 100)

        for i in 0..<total {
            let multiplier = fluoriteMultiplier()
            accumulator += multiplier
            if multiplier > apexMultiplier { apexMultiplier = multiplier }

            let floreted = floretMultiplier(multiplier)
            multiplierCensus[floreted, default: 0] += 1

            if i % chunkSize == 0 {
                let progress = Double(i) / Double(total)
                DispatchQueue.main.async { onProgress(progress) }
            }
        }

        DispatchQueue.main.async { onProgress(1.0) }

        let buckets = forgeBuckets(census: multiplierCensus, total: total)
        let tierBreakdown = calcineTiers(census: multiplierCensus, total: total)

        return CeladonMetrics(
            totalIterations: total,
            aggregateYield: accumulator,
            zenithMultiplier: apexMultiplier,
            buckets: buckets,
            tierBreakdown: tierBreakdown
        )
    }

    private func fluoriteMultiplier() -> Double {
        let roll = Double.random(in: 0...1, using: &rng)

        if roll < 0.72 { return 0.0 }
        if roll < 0.90 { return Double.random(in: 0.1...2.0, using: &rng) }
        if roll < 0.97 { return Double.random(in: 2.0...10.0, using: &rng) }
        if roll < 0.995 { return Double.random(in: 10.0...50.0, using: &rng) }
        if roll < 0.999 { return Double.random(in: 50.0...200.0, using: &rng) }
        return Double.random(in: 200.0...500.0, using: &rng)
    }

    private func floretMultiplier(_ multiplier: Double) -> Double {
        if multiplier == 0 { return 0 }
        if multiplier < 0.5 { return 0.25 }
        if multiplier < 1.0 { return 0.75 }
        if multiplier < 2.0 { return 1.5 }
        if multiplier < 5.0 { return 3.5 }
        if multiplier < 10.0 { return 7.5 }
        if multiplier < 20.0 { return 15.0 }
        if multiplier < 50.0 { return 35.0 }
        if multiplier < 100.0 { return 75.0 }
        if multiplier < 200.0 { return 150.0 }
        return 350.0
    }

    private func forgeBuckets(census: [Double: Int], total: Int) -> [ZirconBucket] {
        let boundaries: [(Double, Double)] = [
            (0, 0),
            (0.01, 0.5),
            (0.5, 1.0),
            (1.0, 2.0),
            (2.0, 5.0),
            (5.0, 10.0),
            (10.0, 20.0),
            (20.0, 50.0),
            (50.0, 100.0),
            (100.0, 200.0),
            (200.0, 500.0)
        ]

        return boundaries.map { (nadir, zenith) in
            var bucketCensus = 0
            for (mult, count) in census {
                if mult >= nadir && mult <= zenith {
                    bucketCensus += count
                }
            }
            let likelihood = Double(bucketCensus) / Double(total)
            return ZirconBucket(
                nadir: nadir,
                zenith: zenith,
                census: bucketCensus,
                likelihood: likelihood,
                rtpFragment: likelihood * (nadir + zenith) / 2.0
            )
        }
    }

    private func calcineTiers(census: [Double: Int], total: Int) -> [CinnabarTier: CeladonMetrics.TierDigest] {
        var result: [CinnabarTier: CeladonMetrics.TierDigest] = [:]
        let tiers: [CinnabarTier] = [.lacuna, .minuscule, .modest, .favorable, .substantial, .colossal]

        for tier in tiers {
            var tierCensus = 0
            var tierYield: Double = 0

            for (mult, count) in census {
                if CinnabarTier.classify(mult) == tier {
                    tierCensus += count
                    tierYield += mult * Double(count)
                }
            }

            let likelihood = Double(tierCensus) / Double(total)
            result[tier] = CeladonMetrics.TierDigest(
                tier: tier,
                census: tierCensus,
                likelihood: likelihood,
                rtpFragment: tierYield / Double(total),
                averageYield: tierCensus > 0 ? tierYield / Double(tierCensus) : 0
            )
        }

        return result
    }
}
