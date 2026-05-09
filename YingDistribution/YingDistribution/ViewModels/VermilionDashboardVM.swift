import Foundation
import Combine

@MainActor
final class VermilionDashboardVM {

    static let shared = VermilionDashboardVM()

    @Published private(set) var quillonMetrics: CeladonMetrics?
    @Published private(set) var isSimulating: Bool = false
    @Published private(set) var currentProgress: Double = 0
    @Published private(set) var history: [HistoryRecord] = []
    @Published private(set) var presets: [PresetEntity] = []
    @Published private(set) var insights: [InsightCard] = []

    private let distiller = ObsidianDistiller()
    private let archivist = CarmineArchivist()
    var activeConfig: CobaltConfig = .default

    init() {
        restoreArchived()
    }

    var totalIterations: Int { quillonMetrics?.totalIterations ?? 0 }
    var rtpValue: Double { quillonMetrics?.rtp ?? 0 }
    var hitFrequency: Double { quillonMetrics?.collisionFrequency ?? 0 }
    var evValue: Double { quillonMetrics?.expectancyValue ?? 0 }
    var apexMultiplier: Double { quillonMetrics?.zenithMultiplier ?? 0 }

    var nonZeroBuckets: [ZirconBucket] {
        quillonMetrics?.buckets.filter { $0.nadir > 0 } ?? []
    }

    var tierBreakdown: [CinnabarTier: CeladonMetrics.TierDigest] {
        quillonMetrics?.tierBreakdown ?? [:]
    }

    var sortedTiers: [(CinnabarTier, CeladonMetrics.TierDigest)] {
        let order: [CinnabarTier] = [.minuscule, .modest, .favorable, .substantial, .colossal]
        return order.compactMap { tier in
            guard let digest = tierBreakdown[tier] else { return nil }
            return (tier, digest)
        }
    }

    var hasMetrics: Bool { quillonMetrics != nil }

    func commenceSimulation(with config: CobaltConfig) {
        activeConfig = config
        isSimulating = true
        currentProgress = 0
        archivist.preserveConfig(config)

        distiller.rendOutcomes(config: config) { [weak self] progress in
            DispatchQueue.main.async {
                self?.currentProgress = progress
            }
        } completion: { [weak self] metrics in
            DispatchQueue.main.async {
                guard let self else { return }
                self.quillonMetrics = metrics
                self.isSimulating = false
                self.currentProgress = 1.0
                self.archivist.preserveLatest(metrics)
                self.archivist.preserveHistory(metrics, config: config)
                self.history = self.archivist.retrieveHistory() ?? []
                self.insights = self.generateInsights(from: metrics)
            }
        }
    }

    func loadPresets() {
        presets = archivist.retrievePresets() ?? []
    }

    @discardableResult
    func savePreset(name: String) -> Bool {
        if presets.contains(where: { $0.name == name }) {
            return false
        }

        archivist.savePreset(activeConfig, name: name)
        loadPresets()
        return true
    }

    func deletePreset(id: UUID) {
        archivist.deletePreset(id: id)
        loadPresets()
    }

    func deleteHistoryRecord(id: UUID) {
        archivist.deleteHistoryRecord(id: id)
        history = archivist.retrieveHistory() ?? []
    }

    func restoreFromHistory(_ record: HistoryRecord) {
        let restoredConfig = CobaltConfig(
            iterationQuantum: record.configSummary.iterationQuantum,
            wagerAmount: record.configSummary.wagerAmount,
            cascadeMode: CobaltConfig.CascadeMode(rawValue: record.configSummary.cascadeMode) ?? .universal,
            isLineSimulated: activeConfig.isLineSimulated
        )

        activeConfig = restoredConfig
        commenceSimulation(with: restoredConfig)
    }

    func loadArchived() -> CeladonMetrics? {
        return archivist.retrieveLatest()
    }

    func restoreArchived() {
        activeConfig = archivist.retrieveConfig() ?? activeConfig
        history = archivist.retrieveHistory() ?? []
        presets = archivist.retrievePresets() ?? []

        if let saved = archivist.retrieveLatest() {
            quillonMetrics = saved
            insights = generateInsights(from: saved)
        } else {
            insights = []
        }
    }

    private func generateInsights(from metrics: CeladonMetrics) -> [InsightCard] {
        var cards: [InsightCard] = []

        if metrics.rtp > 0.97 {
            cards.append(
                InsightCard(
                    id: UUID(),
                    ruleId: "high_rtp",
                    title: "High RTP",
                    description: "Current RTP is \(String(format: "%.2f%%", metrics.rtp * 100)). Return to player is performing well.",
                    severity: .success
                )
            )
        }

        if metrics.rtp < 0.85 {
            cards.append(
                InsightCard(
                    id: UUID(),
                    ruleId: "low_rtp",
                    title: "Low RTP",
                    description: "Current RTP is \(String(format: "%.2f%%", metrics.rtp * 100)). Monitor return to player performance.",
                    severity: .warning
                )
            )
        }

        if metrics.collisionFrequency > 0.40 {
            cards.append(
                InsightCard(
                    id: UUID(),
                    ruleId: "high_hit",
                    title: "High Hit Frequency",
                    description: "Hit frequency reached \(String(format: "%.2f%%", metrics.collisionFrequency * 100)). Triggers are occurring frequently.",
                    severity: .info
                )
            )
        }

        if metrics.collisionFrequency < 0.10 {
            cards.append(
                InsightCard(
                    id: UUID(),
                    ruleId: "low_hit",
                    title: "Low Hit Frequency",
                    description: "Hit frequency is only \(String(format: "%.2f%%", metrics.collisionFrequency * 100)). Idle periods may be extended.",
                    severity: .warning
                )
            )
        }

        if metrics.zenithMultiplier > 500 {
            cards.append(
                InsightCard(
                    id: UUID(),
                    ruleId: "high_volatility",
                    title: "Extreme Peak Multiplier",
                    description: "Peak multiplier reached \(String(format: "%.2f", metrics.zenithMultiplier))x. Volatility is high.",
                    severity: .warning
                )
            )
        }

        let lowerTierRTP = (metrics.tierBreakdown[.minuscule]?.rtpFragment ?? 0) + (metrics.tierBreakdown[.modest]?.rtpFragment ?? 0)
        if lowerTierRTP > 0.80 {
            cards.append(
                InsightCard(
                    id: UUID(),
                    ruleId: "tier_concentration",
                    title: "Low Tier Reward Concentration",
                    description: "Low and modest tier rewards contribute \(String(format: "%.2f%%", lowerTierRTP * 100)) to RTP. Rewards are concentrated in lower tiers.",
                    severity: .info
                )
            )
        }

        return cards
    }
}
