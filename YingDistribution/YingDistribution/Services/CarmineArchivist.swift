import Foundation

final class CarmineArchivist {

    private let quillonKey = "quillon_latest_metrics"
    private let configKey = "quillon_latest_config"
    private let historyKey = "ying_history_v1"
    private let presetsKey = "ying_presets_v1"
    private let comparisonKey = "ying_comparison_v1"
    private let historyLimit = 100

    func preserveLatest(_ metrics: CeladonMetrics) {
        if let data = try? JSONEncoder().encode(MetricsEnvelope(from: metrics)) {
            UserDefaults.standard.set(data, forKey: quillonKey)
        }
    }

    func preserveConfig(_ config: CobaltConfig) {
        if let data = try? JSONEncoder().encode(ConfigEnvelope(from: config)) {
            UserDefaults.standard.set(data, forKey: configKey)
        }
    }

    func retrieveLatest() -> CeladonMetrics? {
        guard let data = UserDefaults.standard.data(forKey: quillonKey),
              let envelope = try? JSONDecoder().decode(MetricsEnvelope.self, from: data) else {
            return nil
        }
        return envelope.unwrap()
    }

    func retrieveConfig() -> CobaltConfig? {
        guard let data = UserDefaults.standard.data(forKey: configKey),
              let envelope = try? JSONDecoder().decode(ConfigEnvelope.self, from: data) else {
            return nil
        }
        return envelope.unwrap()
    }
}

private struct MetricsEnvelope: Codable {
    let totalIterations: Int
    let aggregateYield: Double
    let zenithMultiplier: Double
    let bucketData: [BucketData]
    let tierData: [TierData]

    struct BucketData: Codable {
        let nadir: Double
        let zenith: Double
        let census: Int
        let likelihood: Double
        let rtpFragment: Double
    }

    struct TierData: Codable {
        let tierIndex: Int
        let census: Int
        let likelihood: Double
        let rtpFragment: Double
        let averageYield: Double
    }

    init(from metrics: CeladonMetrics) {
        self.totalIterations = metrics.totalIterations
        self.aggregateYield = metrics.aggregateYield
        self.zenithMultiplier = metrics.zenithMultiplier
        self.bucketData = metrics.buckets.map {
            BucketData(nadir: $0.nadir, zenith: $0.zenith, census: $0.census, likelihood: $0.likelihood, rtpFragment: $0.rtpFragment)
        }
        self.tierData = metrics.tierBreakdown.map { (tier, digest) in
            TierData(tierIndex: CinnabarTier.allCases.firstIndex(of: tier) ?? 0,
                     census: digest.census, likelihood: digest.likelihood,
                     rtpFragment: digest.rtpFragment, averageYield: digest.averageYield)
        }
    }

    func unwrap() -> CeladonMetrics {
        let allTiers = CinnabarTier.allCases
        var tierMap: [CinnabarTier: CeladonMetrics.TierDigest] = [:]
        for td in tierData {
            guard td.tierIndex < allTiers.count else { continue }
            let tier = allTiers[td.tierIndex]
            tierMap[tier] = CeladonMetrics.TierDigest(
                tier: tier, census: td.census, likelihood: td.likelihood,
                rtpFragment: td.rtpFragment, averageYield: td.averageYield
            )
        }

        return CeladonMetrics(
            totalIterations: totalIterations,
            aggregateYield: aggregateYield,
            zenithMultiplier: zenithMultiplier,
            buckets: bucketData.map { ZirconBucket(nadir: $0.nadir, zenith: $0.zenith, census: $0.census, likelihood: $0.likelihood, rtpFragment: $0.rtpFragment) },
            tierBreakdown: tierMap
        )
    }
}

private struct ConfigEnvelope: Codable {
    let iterationQuantum: Int
    let wagerAmount: Double
    let cascadeMode: String

    init(from config: CobaltConfig) {
        self.iterationQuantum = config.iterationQuantum
        self.wagerAmount = config.wagerAmount
        self.cascadeMode = config.cascadeMode.rawValue
    }

    func unwrap() -> CobaltConfig {
        return CobaltConfig(
            iterationQuantum: iterationQuantum,
            wagerAmount: wagerAmount,
            cascadeMode: CobaltConfig.CascadeMode(rawValue: cascadeMode) ?? .universal,
            isLineSimulated: true
        )
    }
}

// MARK: - History Envelope
private struct HistoryEnvelope: Codable {
    let records: [HistoryRecord]

    init(from records: [HistoryRecord]) {
        self.records = records
    }

    func unwrap() -> [HistoryRecord] {
        return records
    }
}

// MARK: - Preset Envelope
private struct PresetEnvelope: Codable {
    let presets: [PresetEntity]

    init(from presets: [PresetEntity]) {
        self.presets = presets
    }

    func unwrap() -> [PresetEntity] {
        return presets
    }
}

// MARK: - CarmineArchivist Extension
extension CarmineArchivist {
    // MARK: History Methods
    func preserveHistory(_ metrics: CeladonMetrics, config: CobaltConfig) {
        var records = retrieveHistory() ?? []

        let record = HistoryRecord(
            id: UUID(),
            timestamp: Date(),
            configSummary: HistoryRecord.ConfigSummary(
                iterationQuantum: config.iterationQuantum,
                wagerAmount: config.wagerAmount,
                cascadeMode: config.cascadeMode.rawValue
            ),
            metricsSummary: HistoryRecord.MetricsSummary(
                rtp: metrics.rtp,
                collisionFrequency: metrics.collisionFrequency,
                evValue: metrics.expectancyValue,
                zenithMultiplier: metrics.zenithMultiplier,
                totalIterations: metrics.totalIterations,
                tierSummaries: CinnabarTier.allCases.compactMap { tier in
                    guard let digest = metrics.tierBreakdown[tier] else { return nil }
                    return HistoryRecord.MetricsSummary.TierSummary(
                        tierName: tier.moniker,
                        likelihood: digest.likelihood,
                        rtpFragment: digest.rtpFragment
                    )
                }
            )
        )

        records.append(record)

        // Trim to last 100 records
        if records.count > historyLimit {
            records = Array(records.suffix(historyLimit))
        }

        if let data = try? JSONEncoder().encode(HistoryEnvelope(from: records)) {
            UserDefaults.standard.set(data, forKey: historyKey)
        }
    }

    func retrieveHistory() -> [HistoryRecord]? {
        guard let data = UserDefaults.standard.data(forKey: historyKey),
              let envelope = try? JSONDecoder().decode(HistoryEnvelope.self, from: data) else {
            return nil
        }
        return envelope.unwrap()
    }

    func deleteHistoryRecord(id: UUID) {
        guard var records = retrieveHistory() else { return }
        records.removeAll { $0.id == id }

        if let data = try? JSONEncoder().encode(HistoryEnvelope(from: records)) {
            UserDefaults.standard.set(data, forKey: historyKey)
        }
    }

    // MARK: Preset Methods
    func savePreset(_ config: CobaltConfig, name: String) {
        var presets = retrievePresets() ?? []

        let preset = PresetEntity(
            id: UUID(),
            name: name,
            config: config,
            createdAt: Date()
        )

        presets.append(preset)

        if let data = try? JSONEncoder().encode(PresetEnvelope(from: presets)) {
            UserDefaults.standard.set(data, forKey: presetsKey)
        }
    }

    func retrievePresets() -> [PresetEntity]? {
        guard let data = UserDefaults.standard.data(forKey: presetsKey),
              let envelope = try? JSONDecoder().decode(PresetEnvelope.self, from: data) else {
            return nil
        }
        return envelope.unwrap()
    }

    func deletePreset(id: UUID) {
        guard var presets = retrievePresets() else { return }
        presets.removeAll { $0.id == id }

        if let data = try? JSONEncoder().encode(PresetEnvelope(from: presets)) {
            UserDefaults.standard.set(data, forKey: presetsKey)
        }
    }

    // MARK: Comparison Methods
    func saveComparison(_ snapshot: ComparisonSnapshot) {
        if let data = try? JSONEncoder().encode(snapshot) {
            UserDefaults.standard.set(data, forKey: comparisonKey)
        }
    }

    func retrieveComparison() -> ComparisonSnapshot? {
        guard let data = UserDefaults.standard.data(forKey: comparisonKey),
              let snapshot = try? JSONDecoder().decode(ComparisonSnapshot.self, from: data) else {
            return nil
        }
        return snapshot
    }

    func deleteComparison() {
        UserDefaults.standard.removeObject(forKey: comparisonKey)
    }
}

extension CinnabarTier: CaseIterable {
    static var allCases: [CinnabarTier] {
        return [.lacuna, .minuscule, .modest, .favorable, .substantial, .colossal]
    }
}
