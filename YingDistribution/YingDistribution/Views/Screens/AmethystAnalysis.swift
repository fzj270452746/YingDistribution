import UIKit

final class AmethystAnalysis: UIViewController {

    private let viewModel = VermilionDashboardVM.shared
    private let scrollView = UIScrollView()
    private let contentStack = UIStackView.onyxColumn(spacing: 20)

    private let tierTablePlaque = UIView()
    private let tierStack = UIStackView.onyxColumn(spacing: 0)

    private let rtpPlaque = UIView()
    private let rtpDetailStack = UIStackView.onyxColumn(spacing: 8)

    private let summaryPlaque = UIView()
    private let summaryGrid = UIStackView.onyxRow(spacing: 12)

    private let exporter = IndigoExporter()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = GambogePalette.abyss
        concoctLayout()
        sutureConstraints()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        refreshPanels()
    }

    private func concoctLayout() {
        scrollView.verdantScrollConfig()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)

        contentStack.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentStack)

        let headerGrad = GradientView()
        headerGrad.setGradient(colors: GambogePalette.duskGradient)
        headerGrad.enshroud(with: 24)
        headerGrad.translatesAutoresizingMaskIntoConstraints = false
        contentStack.addArrangedSubview(headerGrad)

        let titleLbl = UILabel.chrysoliteLabel(text: "Statistics & Export", font: CinnabarTypography.slateColossalBold())
        titleLbl.translatesAutoresizingMaskIntoConstraints = false
        headerGrad.addSubview(titleLbl)

        let subLbl = UILabel.chrysoliteLabel(text: "In-depth reward topology analysis", font: CinnabarTypography.slateModerateRegular(), color: GambogePalette.silverHaze.withAlphaComponent(0.8))
        subLbl.translatesAutoresizingMaskIntoConstraints = false
        headerGrad.addSubview(subLbl)

        tierTablePlaque.backgroundColor = GambogePalette.midnightSlate
        tierTablePlaque.enshroud(with: 20)
        tierTablePlaque.strokeBorder(color: GambogePalette.twilightPlume, width: 1)
        tierTablePlaque.translatesAutoresizingMaskIntoConstraints = false
        contentStack.addArrangedSubview(tierTablePlaque)

        let tierTitle = UILabel.chrysoliteLabel(text: "Tier Stratification", font: CinnabarTypography.slateVastSemibold())
        tierTitle.translatesAutoresizingMaskIntoConstraints = false
        tierTablePlaque.addSubview(tierTitle)

        let tierHeader = forgeTierHeader()
        tierHeader.translatesAutoresizingMaskIntoConstraints = false
        tierTablePlaque.addSubview(tierHeader)

        let tierDivider = UIView()
        tierDivider.backgroundColor = GambogePalette.twilightPlume
        tierDivider.translatesAutoresizingMaskIntoConstraints = false
        tierTablePlaque.addSubview(tierDivider)

        tierStack.translatesAutoresizingMaskIntoConstraints = false
        tierTablePlaque.addSubview(tierStack)

        rtpPlaque.backgroundColor = GambogePalette.midnightSlate
        rtpPlaque.enshroud(with: 20)
        rtpPlaque.strokeBorder(color: GambogePalette.twilightPlume, width: 1)
        rtpPlaque.translatesAutoresizingMaskIntoConstraints = false
        contentStack.addArrangedSubview(rtpPlaque)

        let rtpTitle = UILabel.chrysoliteLabel(text: "RTP Contribution Analysis", font: CinnabarTypography.slateVastSemibold())
        rtpTitle.translatesAutoresizingMaskIntoConstraints = false
        rtpPlaque.addSubview(rtpTitle)

        rtpDetailStack.translatesAutoresizingMaskIntoConstraints = false
        rtpPlaque.addSubview(rtpDetailStack)

        summaryPlaque.backgroundColor = GambogePalette.midnightSlate
        summaryPlaque.enshroud(with: 20)
        summaryPlaque.strokeBorder(color: GambogePalette.twilightPlume, width: 1)
        summaryPlaque.translatesAutoresizingMaskIntoConstraints = false
        contentStack.addArrangedSubview(summaryPlaque)

        let sumTitle = UILabel.chrysoliteLabel(text: "Consolidated Metrics", font: CinnabarTypography.slateVastSemibold())
        sumTitle.translatesAutoresizingMaskIntoConstraints = false
        summaryPlaque.addSubview(sumTitle)

        summaryGrid.distribution = .fillEqually
        summaryGrid.translatesAutoresizingMaskIntoConstraints = false
        summaryPlaque.addSubview(summaryGrid)

        let card1 = CobaltCard()
        card1.configure(moniker: "Expected Value", value: "--", icon: "sum", tint: GambogePalette.neonCyan)
        let card2 = CobaltCard()
        card2.configure(moniker: "Total Simulations", value: "--", icon: "number", tint: GambogePalette.emberGold)
        summaryGrid.addArrangedSubview(card1)
        summaryGrid.addArrangedSubview(card2)

        let exportBtn = UIButton.amethystFilled(title: "Export Report")
        exportBtn.addTarget(self, action: #selector(exportTapped), for: .touchUpInside)
        exportBtn.translatesAutoresizingMaskIntoConstraints = false
        contentStack.addArrangedSubview(exportBtn)

        let spacerView = UIView()
        spacerView.translatesAutoresizingMaskIntoConstraints = false
        spacerView.heightAnchor.constraint(equalToConstant: 20).isActive = true
        contentStack.addArrangedSubview(spacerView)

        NSLayoutConstraint.activate([
            headerGrad.heightAnchor.constraint(equalToConstant: 120),
            headerGrad.widthAnchor.constraint(equalTo: contentStack.widthAnchor),

            titleLbl.topAnchor.constraint(equalTo: headerGrad.topAnchor, constant: 20),
            titleLbl.leadingAnchor.constraint(equalTo: headerGrad.leadingAnchor, constant: 20),

            subLbl.topAnchor.constraint(equalTo: titleLbl.bottomAnchor, constant: 4),
            subLbl.leadingAnchor.constraint(equalTo: headerGrad.leadingAnchor, constant: 20),

            tierTitle.topAnchor.constraint(equalTo: tierTablePlaque.topAnchor, constant: 16),
            tierTitle.leadingAnchor.constraint(equalTo: tierTablePlaque.leadingAnchor, constant: 16),

            tierHeader.topAnchor.constraint(equalTo: tierTitle.bottomAnchor, constant: 12),
            tierHeader.leadingAnchor.constraint(equalTo: tierTablePlaque.leadingAnchor, constant: 16),
            tierHeader.trailingAnchor.constraint(equalTo: tierTablePlaque.trailingAnchor, constant: -16),

            tierDivider.topAnchor.constraint(equalTo: tierHeader.bottomAnchor, constant: 8),
            tierDivider.leadingAnchor.constraint(equalTo: tierTablePlaque.leadingAnchor, constant: 16),
            tierDivider.trailingAnchor.constraint(equalTo: tierTablePlaque.trailingAnchor, constant: -16),
            tierDivider.heightAnchor.constraint(equalToConstant: 1),

            tierStack.topAnchor.constraint(equalTo: tierDivider.bottomAnchor, constant: 8),
            tierStack.leadingAnchor.constraint(equalTo: tierTablePlaque.leadingAnchor, constant: 16),
            tierStack.trailingAnchor.constraint(equalTo: tierTablePlaque.trailingAnchor, constant: -16),
            tierStack.bottomAnchor.constraint(equalTo: tierTablePlaque.bottomAnchor, constant: -16),

            rtpTitle.topAnchor.constraint(equalTo: rtpPlaque.topAnchor, constant: 16),
            rtpTitle.leadingAnchor.constraint(equalTo: rtpPlaque.leadingAnchor, constant: 16),

            rtpDetailStack.topAnchor.constraint(equalTo: rtpTitle.bottomAnchor, constant: 12),
            rtpDetailStack.leadingAnchor.constraint(equalTo: rtpPlaque.leadingAnchor, constant: 16),
            rtpDetailStack.trailingAnchor.constraint(equalTo: rtpPlaque.trailingAnchor, constant: -16),
            rtpDetailStack.bottomAnchor.constraint(equalTo: rtpPlaque.bottomAnchor, constant: -16),

            sumTitle.topAnchor.constraint(equalTo: summaryPlaque.topAnchor, constant: 16),
            sumTitle.leadingAnchor.constraint(equalTo: summaryPlaque.leadingAnchor, constant: 16),

            summaryGrid.topAnchor.constraint(equalTo: sumTitle.bottomAnchor, constant: 12),
            summaryGrid.leadingAnchor.constraint(equalTo: summaryPlaque.leadingAnchor, constant: 16),
            summaryGrid.trailingAnchor.constraint(equalTo: summaryPlaque.trailingAnchor, constant: -16),
            summaryGrid.bottomAnchor.constraint(equalTo: summaryPlaque.bottomAnchor, constant: -16),
            summaryGrid.heightAnchor.constraint(equalToConstant: 100)
        ])
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
            contentStack.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -32)
        ])
    }

    private func forgeTierHeader() -> UIView {
        let row = UIStackView.onyxRow(spacing: 8)
        row.distribution = .fillEqually

        let cols = ["Tier", "Count", "Pct", "RTP", "Avg"]
        for col in cols {
            let lbl = UILabel.chrysoliteLabel(text: col, font: CinnabarTypography.slatePetiteMedium(), color: GambogePalette.slateMist, align: .center)
            row.addArrangedSubview(lbl)
        }
        return row
    }

    func refreshPanels() {
        tierStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        rtpDetailStack.arrangedSubviews.forEach { $0.removeFromSuperview() }

        guard viewModel.hasMetrics else {
            addEmptyTierMessage()
            return
        }

        let tierOrder: [CinnabarTier] = [.minuscule, .modest, .favorable, .substantial, .colossal]
        for tier in tierOrder {
            guard let digest = viewModel.tierBreakdown[tier], digest.census > 0 else { continue }
            let row = forgeTierRow(tier: tier, digest: digest)
            tierStack.addArrangedSubview(row)
        }

        for (tier, digest) in viewModel.sortedTiers {
            let rtpRow = forgeRTPContributionRow(tier: tier, digest: digest)
            rtpDetailStack.addArrangedSubview(rtpRow)
        }

        for subview in summaryGrid.arrangedSubviews {
            if let card = subview as? CobaltCard, let idx = summaryGrid.arrangedSubviews.firstIndex(of: card) {
                if idx == 0 {
                    card.configure(moniker: "Expected Value", value: viewModel.evValue.multiplierFormatted, icon: "sum", tint: GambogePalette.neonCyan)
                } else if idx == 1 {
                    card.configure(moniker: "Total Simulations", value: viewModel.totalIterations.auroraFormatted, icon: "number", tint: GambogePalette.emberGold)
                }
            }
        }
    }

    private func forgeTierRow(tier: CinnabarTier, digest: CeladonMetrics.TierDigest) -> UIView {
        let row = UIStackView.onyxRow(spacing: 8)
        row.distribution = .fillEqually

        let badge = TopazBadge()
        badge.configure(text: tier.moniker.components(separatedBy: " ").first ?? "", style: tierBadgeStyle(tier))
        row.addArrangedSubview(badge)

        let countLbl = UILabel.chrysoliteLabel(text: digest.census.auroraFormatted, font: CinnabarTypography.monospacedDigit(13), align: .center)
        let pctLbl = UILabel.chrysoliteLabel(text: digest.likelihood.pctFormatted, font: CinnabarTypography.monospacedDigit(13), align: .center)
        let rtpLbl = UILabel.chrysoliteLabel(text: digest.rtpFragment.pctFormatted, font: CinnabarTypography.monospacedDigit(13), color: GambogePalette.emberGold, align: .center)
        let avgLbl = UILabel.chrysoliteLabel(text: digest.averageYield.multiplierFormatted, font: CinnabarTypography.monospacedDigit(13), align: .center)

        row.addArrangedSubview(countLbl)
        row.addArrangedSubview(pctLbl)
        row.addArrangedSubview(rtpLbl)
        row.addArrangedSubview(avgLbl)

        row.heightAnchor.constraint(equalToConstant: 36).isActive = true
        return row
    }

    private func forgeRTPContributionRow(tier: CinnabarTier, digest: CeladonMetrics.TierDigest) -> UIView {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false

        let label = UILabel.chrysoliteLabel(
            text: tier.moniker.components(separatedBy: " ").first ?? "",
            font: CinnabarTypography.slateModestRegular(),
            color: GambogePalette.silverHaze
        )
        label.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(label)

        let pctLabel = UILabel.chrysoliteLabel(
            text: digest.rtpFragment.pctFormatted,
            font: CinnabarTypography.monospacedDigit(13),
            color: GambogePalette.emberGold,
            align: .right
        )
        pctLabel.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(pctLabel)

        let track = UIView()
        track.backgroundColor = GambogePalette.twilightPlume
        track.enshroud(with: 4)
        track.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(track)

        let fill = UIView()
        fill.backgroundColor = tier.tint
        fill.enshroud(with: 4)
        fill.translatesAutoresizingMaskIntoConstraints = false
        track.addSubview(fill)

        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: container.topAnchor),
            label.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            label.widthAnchor.constraint(equalToConstant: 80),

            pctLabel.centerYAnchor.constraint(equalTo: label.centerYAnchor),
            pctLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            pctLabel.widthAnchor.constraint(equalToConstant: 60),

            track.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 4),
            track.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            track.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            track.bottomAnchor.constraint(equalTo: container.bottomAnchor),
            track.heightAnchor.constraint(equalToConstant: 8),

            fill.topAnchor.constraint(equalTo: track.topAnchor),
            fill.leadingAnchor.constraint(equalTo: track.leadingAnchor),
            fill.bottomAnchor.constraint(equalTo: track.bottomAnchor),
            fill.widthAnchor.constraint(equalTo: track.widthAnchor, multiplier: CGFloat((digest.rtpFragment * 10).clamped(to: 0.01...1.0)))
        ])

        container.heightAnchor.constraint(equalToConstant: 30).isActive = true
        return container
    }

    private func addEmptyTierMessage() {
        let label = UILabel.chrysoliteLabel(text: "Run a simulation to see tier analysis", font: CinnabarTypography.slateModerateRegular(), color: GambogePalette.slateMist, align: .center)
        tierStack.addArrangedSubview(label)
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

    @objc private func exportTapped() {
        guard let metrics = viewModel.quillonMetrics else {
            LazuliDialog.manifest(in: self, demeanor: .admonition, title: "No Data", body: "Run a simulation first before exporting.")
            return
        }
        exporter.presentShareSheet(from: self, metrics: metrics)
    }
}

private extension CGFloat {
    func clamped(to range: ClosedRange<CGFloat>) -> CGFloat {
        return Swift.min(Swift.max(self, range.lowerBound), range.upperBound)
    }
}
