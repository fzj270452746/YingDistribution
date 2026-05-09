import UIKit

final class VermilionDashboard: UIViewController {

    private let viewModel = VermilionDashboardVM.shared
    private var hasAppearedOnce = false

    private let scrollView = UIScrollView()
    private let contentStack = UIStackView.onyxColumn(spacing: 20)

    private let headerGradient = GradientView()
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let quickActionBtn = UIButton(type: .system)

    private let metricsGrid = UIStackView.onyxColumn(spacing: 12)
    private let rtpCard = CobaltCard()
    private let hitCard = CobaltCard()
    private let evCard = CobaltCard()
    private let apexCard = CobaltCard()

    private let summaryPlaque = UIView()
    private let summaryLabel = UILabel()
    private let quickDistStack = UIStackView.onyxColumn(spacing: 8)

    private let insightSection = UIView()
    private let insightTitleLabel = UILabel()
    private let insightCardsStack = UIStackView.onyxColumn(spacing: 8)

    private let entryButtonsRow = UIStackView.onyxRow(spacing: 12)
    private let historyBtn = UIButton(type: .system)
    private let presetsBtn = UIButton(type: .system)
    private let compareBtn = UIButton(type: .system)
    private let exportBtn = UIButton(type: .system)

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = GambogePalette.abyss
        concoctLayout()
        sutureConstraints()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if !hasAppearedOnce {
            hasAppearedOnce = true
            viewModel.restoreArchived()
            if !viewModel.hasMetrics {
                viewModel.commenceSimulation(with: .default)
            }
        }
        refreshPanels()
    }

    private func concoctLayout() {
        scrollView.verdantScrollConfig()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)

        contentStack.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentStack)

        headerGradient.setGradient(colors: GambogePalette.auroraGradient, startPoint: CGPoint(x: 0, y: 0), endPoint: CGPoint(x: 1, y: 1))
        headerGradient.enshroud(with: 24)
        headerGradient.translatesAutoresizingMaskIntoConstraints = false
        contentStack.addArrangedSubview(headerGradient)

        titleLabel.text = "Line Win Distribution"
        titleLabel.font = CinnabarTypography.slateColossalBold()
        titleLabel.textColor = .white
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        headerGradient.addSubview(titleLabel)

        subtitleLabel.text = "Slot Reward Topology Analyzer"
        subtitleLabel.font = CinnabarTypography.slateModerateRegular()
        subtitleLabel.textColor = GambogePalette.silverHaze.withAlphaComponent(0.8)
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        headerGradient.addSubview(subtitleLabel)

        quickActionBtn.setImage(UIImage(systemName: "bolt.fill"), for: .normal)
        quickActionBtn.setTitle(" Run Simulation", for: .normal)
        quickActionBtn.tintColor = .white
        quickActionBtn.titleLabel?.font = CinnabarTypography.slateAmpleMedium()
        quickActionBtn.backgroundColor = GambogePalette.auroraViolet.withAlphaComponent(0.5)
        quickActionBtn.enshroud(with: 20)
        quickActionBtn.addTarget(self, action: #selector(quickActionTapped), for: .touchUpInside)
        quickActionBtn.translatesAutoresizingMaskIntoConstraints = false
        headerGradient.addSubview(quickActionBtn)

        metricsGrid.distribution = .fillEqually
        metricsGrid.alignment = .fill
        contentStack.addArrangedSubview(metricsGrid)

        let topRow = UIStackView.onyxRow(spacing: 12)
        topRow.distribution = .fillEqually
        topRow.addArrangedSubview(rtpCard)
        topRow.addArrangedSubview(hitCard)
        metricsGrid.addArrangedSubview(topRow)

        let bottomRow = UIStackView.onyxRow(spacing: 12)
        bottomRow.distribution = .fillEqually
        bottomRow.addArrangedSubview(evCard)
        bottomRow.addArrangedSubview(apexCard)
        metricsGrid.addArrangedSubview(bottomRow)

        summaryPlaque.backgroundColor = GambogePalette.midnightSlate
        summaryPlaque.enshroud(with: 20)
        summaryPlaque.strokeBorder(color: GambogePalette.twilightPlume, width: 1)
        summaryPlaque.translatesAutoresizingMaskIntoConstraints = false
        contentStack.addArrangedSubview(summaryPlaque)

        summaryLabel.font = CinnabarTypography.slateVastSemibold()
        summaryLabel.textColor = .white
        summaryLabel.text = "Tier Breakdown"
        summaryLabel.translatesAutoresizingMaskIntoConstraints = false
        summaryPlaque.addSubview(summaryLabel)

        quickDistStack.translatesAutoresizingMaskIntoConstraints = false
        summaryPlaque.addSubview(quickDistStack)

        insightSection.backgroundColor = GambogePalette.midnightSlate
        insightSection.enshroud(with: 20)
        insightSection.strokeBorder(color: GambogePalette.twilightPlume, width: 1)
        insightSection.translatesAutoresizingMaskIntoConstraints = false
        insightSection.isHidden = true
        contentStack.addArrangedSubview(insightSection)

        insightTitleLabel.font = CinnabarTypography.slateVastSemibold()
        insightTitleLabel.textColor = .white
        insightTitleLabel.text = "Insights"
        insightTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        insightSection.addSubview(insightTitleLabel)

        insightCardsStack.translatesAutoresizingMaskIntoConstraints = false
        insightSection.addSubview(insightCardsStack)

        entryButtonsRow.distribution = .fillEqually
        entryButtonsRow.alignment = .fill
        entryButtonsRow.translatesAutoresizingMaskIntoConstraints = false
        contentStack.addArrangedSubview(entryButtonsRow)

        historyBtn.setTitle("History", for: .normal)
        historyBtn.tintColor = .white
        historyBtn.titleLabel?.font = CinnabarTypography.slateAmpleMedium()
        historyBtn.backgroundColor = GambogePalette.auroraViolet.withAlphaComponent(0.5)
        historyBtn.enshroud(with: 20)
        historyBtn.addTarget(self, action: #selector(historyTapped), for: .touchUpInside)
        historyBtn.translatesAutoresizingMaskIntoConstraints = false
        entryButtonsRow.addArrangedSubview(historyBtn)

        presetsBtn.setTitle("Presets", for: .normal)
        presetsBtn.tintColor = .white
        presetsBtn.titleLabel?.font = CinnabarTypography.slateAmpleMedium()
        presetsBtn.backgroundColor = GambogePalette.auroraViolet.withAlphaComponent(0.5)
        presetsBtn.enshroud(with: 20)
        presetsBtn.addTarget(self, action: #selector(presetsTapped), for: .touchUpInside)
        presetsBtn.translatesAutoresizingMaskIntoConstraints = false
        entryButtonsRow.addArrangedSubview(presetsBtn)

        compareBtn.setTitle("Compare", for: .normal)
        compareBtn.tintColor = .white
        compareBtn.titleLabel?.font = CinnabarTypography.slateAmpleMedium()
        compareBtn.backgroundColor = GambogePalette.auroraViolet.withAlphaComponent(0.5)
        compareBtn.enshroud(with: 20)
        compareBtn.addTarget(self, action: #selector(compareTapped), for: .touchUpInside)
        compareBtn.translatesAutoresizingMaskIntoConstraints = false
        entryButtonsRow.addArrangedSubview(compareBtn)

        exportBtn.setTitle("Export", for: .normal)
        exportBtn.tintColor = .white
        exportBtn.titleLabel?.font = CinnabarTypography.slateAmpleMedium()
        exportBtn.backgroundColor = GambogePalette.emeraldSuccess.withAlphaComponent(0.5)
        exportBtn.enshroud(with: 20)
        exportBtn.addTarget(self, action: #selector(exportTapped), for: .touchUpInside)
        exportBtn.translatesAutoresizingMaskIntoConstraints = false
        contentStack.addArrangedSubview(exportBtn)

        exportBtn.heightAnchor.constraint(equalToConstant: 44).isActive = true
    }

    private func sutureConstraints() {
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            contentStack.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 16),
            contentStack.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -20),
            contentStack.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 16),
            contentStack.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -16),
            contentStack.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -32),

            headerGradient.heightAnchor.constraint(equalToConstant: 180),
            headerGradient.widthAnchor.constraint(equalTo: contentStack.widthAnchor),

            titleLabel.topAnchor.constraint(equalTo: headerGradient.topAnchor, constant: 24),
            titleLabel.leadingAnchor.constraint(equalTo: headerGradient.leadingAnchor, constant: 20),

            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            subtitleLabel.leadingAnchor.constraint(equalTo: headerGradient.leadingAnchor, constant: 20),

            quickActionBtn.bottomAnchor.constraint(equalTo: headerGradient.bottomAnchor, constant: -20),
            quickActionBtn.trailingAnchor.constraint(equalTo: headerGradient.trailingAnchor, constant: -20),
            quickActionBtn.widthAnchor.constraint(equalToConstant: 180),
            quickActionBtn.heightAnchor.constraint(equalToConstant: 44),

            rtpCard.heightAnchor.constraint(equalToConstant: 110),
            hitCard.heightAnchor.constraint(equalToConstant: 110),
            evCard.heightAnchor.constraint(equalToConstant: 110),
            apexCard.heightAnchor.constraint(equalToConstant: 110),

            summaryLabel.topAnchor.constraint(equalTo: summaryPlaque.topAnchor, constant: 16),
            summaryLabel.leadingAnchor.constraint(equalTo: summaryPlaque.leadingAnchor, constant: 16),

            quickDistStack.topAnchor.constraint(equalTo: summaryLabel.bottomAnchor, constant: 12),
            quickDistStack.leadingAnchor.constraint(equalTo: summaryPlaque.leadingAnchor, constant: 16),
            quickDistStack.trailingAnchor.constraint(equalTo: summaryPlaque.trailingAnchor, constant: -16),
            quickDistStack.bottomAnchor.constraint(equalTo: summaryPlaque.bottomAnchor, constant: -16),

            insightTitleLabel.topAnchor.constraint(equalTo: insightSection.topAnchor, constant: 16),
            insightTitleLabel.leadingAnchor.constraint(equalTo: insightSection.leadingAnchor, constant: 16),

            insightCardsStack.topAnchor.constraint(equalTo: insightTitleLabel.bottomAnchor, constant: 12),
            insightCardsStack.leadingAnchor.constraint(equalTo: insightSection.leadingAnchor, constant: 16),
            insightCardsStack.trailingAnchor.constraint(equalTo: insightSection.trailingAnchor, constant: -16),
            insightCardsStack.bottomAnchor.constraint(equalTo: insightSection.bottomAnchor, constant: -16)
        ])
    }

    func refreshPanels() {
        let hasMetrics = viewModel.hasMetrics
        let placeholderValue = "—"

        rtpCard.configure(moniker: "RTP", value: hasMetrics ? String(format: "%.2f%%", viewModel.rtpValue * 100) : placeholderValue, icon: "chart.line.uptrend.xyaxis", tint: GambogePalette.neonCyan)
        hitCard.configure(moniker: "Hit Rate", value: hasMetrics ? String(format: "%.2f%%", viewModel.hitFrequency * 100) : placeholderValue, icon: "target", tint: GambogePalette.emberGold)
        evCard.configure(moniker: "EV / Spin", value: hasMetrics ? viewModel.evValue.multiplierFormatted : placeholderValue, icon: "function", tint: GambogePalette.verdantTeal)
        apexCard.configure(moniker: "Max Win", value: hasMetrics ? viewModel.apexMultiplier.multiplierFormatted : placeholderValue, icon: "crown.fill", tint: GambogePalette.crimsonFlare)

        quickDistStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        for (tier, digest) in viewModel.sortedTiers {
            if digest.census == 0 { continue }
            let row = renderTierRow(tier: tier, digest: digest)
            quickDistStack.addArrangedSubview(row)
        }

        if quickDistStack.arrangedSubviews.isEmpty {
            let emptyLabel = UILabel.chrysoliteLabel(
                text: "No tier breakdown yet",
                font: CinnabarTypography.slateModerateRegular(),
                color: GambogePalette.silverHaze
            )
            emptyLabel.numberOfLines = 1
            quickDistStack.addArrangedSubview(emptyLabel)
        }

        exportBtn.isEnabled = hasMetrics
        exportBtn.alpha = hasMetrics ? 1.0 : 0.4

        let canCompare = viewModel.history.count >= 2
        compareBtn.isEnabled = canCompare
        compareBtn.alpha = canCompare ? 1.0 : 0.4

        refreshInsights()
    }

    private func refreshInsights() {
        insightCardsStack.arrangedSubviews.forEach { subview in
            insightCardsStack.removeArrangedSubview(subview)
            subview.removeFromSuperview()
        }

        guard !viewModel.insights.isEmpty else {
            insightSection.isHidden = true
            return
        }

        insightSection.isHidden = false
        viewModel.insights.forEach { insight in
            insightCardsStack.addArrangedSubview(renderInsightCard(insight))
        }
    }

    private func renderInsightCard(_ insight: InsightCard) -> UIView {
        let card = UIView()
        card.backgroundColor = GambogePalette.midnightSlate
        card.enshroud(with: 16)
        card.strokeBorder(color: GambogePalette.twilightPlume, width: 1)
        card.translatesAutoresizingMaskIntoConstraints = false

        let dot = UIView()
        dot.backgroundColor = insightSeverityColor(insight.severity)
        dot.layer.cornerRadius = 4
        dot.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(dot)

        let iconView = UIImageView(image: UIImage(systemName: insightSeverityIconName(insight.severity)))
        iconView.tintColor = insightSeverityColor(insight.severity)
        iconView.contentMode = .scaleAspectFit
        iconView.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(iconView)

        let titleLabel = UILabel()
        titleLabel.text = insight.title
        titleLabel.font = CinnabarTypography.slateAmpleMedium()
        titleLabel.textColor = .white
        titleLabel.numberOfLines = 0
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(titleLabel)

        let descriptionLabel = UILabel()
        descriptionLabel.text = insight.description
        descriptionLabel.font = CinnabarTypography.slateModerateRegular()
        descriptionLabel.textColor = GambogePalette.silverHaze
        descriptionLabel.numberOfLines = 0
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(descriptionLabel)

        NSLayoutConstraint.activate([
            dot.topAnchor.constraint(equalTo: card.topAnchor, constant: 16),
            dot.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16),
            dot.widthAnchor.constraint(equalToConstant: 8),
            dot.heightAnchor.constraint(equalToConstant: 8),

            iconView.centerYAnchor.constraint(equalTo: dot.centerYAnchor),
            iconView.leadingAnchor.constraint(equalTo: dot.trailingAnchor, constant: 8),
            iconView.widthAnchor.constraint(equalToConstant: 14),
            iconView.heightAnchor.constraint(equalToConstant: 14),

            titleLabel.topAnchor.constraint(equalTo: card.topAnchor, constant: 12),
            titleLabel.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: 8),
            titleLabel.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -16),

            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 6),
            descriptionLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            descriptionLabel.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -16),
            descriptionLabel.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -12)
        ])

        return card
    }

    private func insightSeverityColor(_ severity: InsightSeverity) -> UIColor {
        switch severity {
        case .success:
            return GambogePalette.verdantTeal
        case .warning:
            return GambogePalette.emberGold
        case .info:
            return GambogePalette.phantomBlue
        }
    }

    private func insightSeverityIconName(_ severity: InsightSeverity) -> String {
        switch severity {
        case .success:
            return "checkmark.circle.fill"
        case .warning:
            return "exclamationmark.triangle.fill"
        case .info:
            return "info.circle.fill"
        }
    }

    private func renderTierRow(tier: CinnabarTier, digest: CeladonMetrics.TierDigest) -> UIView {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false

        let badge = TopazBadge()
        badge.configure(text: tier.moniker.components(separatedBy: " ").first ?? "", style: tierBadgeStyle(tier))
        badge.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(badge)

        let pctLabel = UILabel.chrysoliteLabel(
            text: String(format: "%.2f%%  ·  RTP %.2f%%", digest.likelihood * 100, digest.rtpFragment * 100),
            font: CinnabarTypography.slateModerateRegular(),
            color: GambogePalette.silverHaze
        )
        pctLabel.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(pctLabel)

        let barTrack = UIView()
        barTrack.backgroundColor = GambogePalette.twilightPlume
        barTrack.enshroud(with: 3)
        barTrack.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(barTrack)

        let barFill = UIView()
        barFill.backgroundColor = tier.tint
        barFill.enshroud(with: 3)
        barFill.translatesAutoresizingMaskIntoConstraints = false
        barTrack.addSubview(barFill)

        NSLayoutConstraint.activate([
            badge.topAnchor.constraint(equalTo: container.topAnchor),
            badge.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            badge.bottomAnchor.constraint(equalTo: container.bottomAnchor),

            pctLabel.centerYAnchor.constraint(equalTo: badge.centerYAnchor),
            pctLabel.leadingAnchor.constraint(equalTo: badge.trailingAnchor, constant: 10),
            pctLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor),

            barTrack.topAnchor.constraint(equalTo: badge.bottomAnchor, constant: 6),
            barTrack.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            barTrack.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            barTrack.heightAnchor.constraint(equalToConstant: 6),

            barFill.topAnchor.constraint(equalTo: barTrack.topAnchor),
            barFill.leadingAnchor.constraint(equalTo: barTrack.leadingAnchor),
            barFill.bottomAnchor.constraint(equalTo: barTrack.bottomAnchor),
            barFill.widthAnchor.constraint(equalTo: barTrack.widthAnchor, multiplier: CGFloat(digest.likelihood * 10).clamped(to: 0.01...1.0))
        ])

        container.heightAnchor.constraint(equalToConstant: 30).isActive = true
        return container
    }

    private func tierBadgeStyle(_ tier: CinnabarTier) -> TopazBadge.BadgeStyle {
        switch tier {
        case .minuscule: return .verdant
        case .modest: return .aurora
        case .favorable: return .ember
        case .substantial: return .crimson
        case .colossal: return .crimson
        default: return .aurora
        }
    }

    @objc private func quickActionTapped() {
        guard let nav = self.parent as? MonolithNavigation else { return }
        nav.transitionToPage(1)
    }

    @objc private func historyTapped() {
        let historyVC = HistoryScreen()
        let navVC = UINavigationController(rootViewController: historyVC)
        navVC.modalPresentationStyle = .fullScreen
        present(navVC, animated: true)
    }

    @objc private func presetsTapped() {
        let presetsVC = PresetsScreen()
        let navVC = UINavigationController(rootViewController: presetsVC)
        navVC.modalPresentationStyle = .fullScreen
        present(navVC, animated: true)
    }

    @objc private func compareTapped() {
        let compareVC = ComparisonScreen()
        let navVC = UINavigationController(rootViewController: compareVC)
        navVC.modalPresentationStyle = .fullScreen
        present(navVC, animated: true)
    }

    @objc private func exportTapped() {
        guard let metrics = viewModel.quillonMetrics else { return }
        let exporter = IndigoExporter()
        exporter.presentShareSheet(from: self, metrics: metrics)
    }
}

private extension CGFloat {
    func clamped(to range: ClosedRange<CGFloat>) -> CGFloat {
        return Swift.min(Swift.max(self, range.lowerBound), range.upperBound)
    }
}
