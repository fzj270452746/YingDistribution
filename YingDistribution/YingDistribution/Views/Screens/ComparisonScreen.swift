import UIKit

final class ComparisonScreen: UIViewController {

    private let viewModel = VermilionDashboardVM.shared
    private let baselineRecord: HistoryRecord?
    private let comparisonRecord: HistoryRecord?

    private var selectedBaselineId: UUID?
    private var selectedComparisonId: UUID?
    private var displayedSnapshot: ComparisonSnapshot?

    private let emptyStateLabel = UILabel()
    private let selectHintLabel = UILabel()
    private let compareButton = UIButton(type: .system)
    private let tableView = UITableView(frame: .zero, style: .plain)

    private let resultScrollView = UIScrollView()
    private let resultContainer = UIStackView()
    private let timestampLabel = UILabel()

    private let timestampFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, yyyy · HH:mm"
        return formatter
    }()

    init(baselineRecord: HistoryRecord? = nil, comparisonRecord: HistoryRecord? = nil) {
        self.baselineRecord = baselineRecord
        self.comparisonRecord = comparisonRecord
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = GambogePalette.abyss
        title = "Compare"
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(dismissTapped))

        configureTableView()
        configureSelectionUI()
        configureResultUI()
        concoctLayout()
        sutureConstraints()
        bootstrapEntryMode()
    }

    private func configureTableView() {
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 24, right: 0)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 96
        tableView.register(ComparisonSelectableHistoryCell.self, forCellReuseIdentifier: ComparisonSelectableHistoryCell.reuseIdentifier)
    }

    private func configureSelectionUI() {
        emptyStateLabel.text = "Run at least 2 simulations to compare"
        emptyStateLabel.textColor = GambogePalette.silverHaze
        emptyStateLabel.font = CinnabarTypography.slateAmpleMedium()
        emptyStateLabel.textAlignment = .center
        emptyStateLabel.numberOfLines = 0
        emptyStateLabel.translatesAutoresizingMaskIntoConstraints = false

        selectHintLabel.text = "Select baseline first, then comparison"
        selectHintLabel.textColor = GambogePalette.silverHaze
        selectHintLabel.font = CinnabarTypography.slateModerateRegular()
        selectHintLabel.translatesAutoresizingMaskIntoConstraints = false

        compareButton.setTitle("Compare", for: .normal)
        compareButton.setTitleColor(.white, for: .normal)
        compareButton.titleLabel?.font = CinnabarTypography.slateAmpleMedium()
        compareButton.backgroundColor = GambogePalette.auroraViolet
        compareButton.layer.cornerRadius = 12
        compareButton.addTarget(self, action: #selector(compareTapped), for: .touchUpInside)
        compareButton.translatesAutoresizingMaskIntoConstraints = false
    }

    private func configureResultUI() {
        resultScrollView.translatesAutoresizingMaskIntoConstraints = false
        resultScrollView.showsVerticalScrollIndicator = false

        resultContainer.axis = .vertical
        resultContainer.spacing = 12
        resultContainer.translatesAutoresizingMaskIntoConstraints = false

        timestampLabel.font = CinnabarTypography.slateModerateRegular()
        timestampLabel.textColor = GambogePalette.silverHaze
        timestampLabel.numberOfLines = 0
        timestampLabel.translatesAutoresizingMaskIntoConstraints = false
    }

    private func concoctLayout() {
        view.addSubview(selectHintLabel)
        view.addSubview(tableView)
        view.addSubview(emptyStateLabel)
        view.addSubview(compareButton)

        view.addSubview(resultScrollView)
        resultScrollView.addSubview(resultContainer)
        resultContainer.addArrangedSubview(timestampLabel)
    }

    private func sutureConstraints() {
        NSLayoutConstraint.activate([
            selectHintLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 12),
            selectHintLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            selectHintLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),

            tableView.topAnchor.constraint(equalTo: selectHintLabel.bottomAnchor, constant: 8),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            tableView.bottomAnchor.constraint(equalTo: compareButton.topAnchor, constant: -12),

            emptyStateLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyStateLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            emptyStateLabel.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 24),
            emptyStateLabel.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -24),

            compareButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            compareButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            compareButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -12),
            compareButton.heightAnchor.constraint(equalToConstant: 52),

            resultScrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            resultScrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            resultScrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            resultScrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            resultContainer.topAnchor.constraint(equalTo: resultScrollView.contentLayoutGuide.topAnchor, constant: 16),
            resultContainer.leadingAnchor.constraint(equalTo: resultScrollView.frameLayoutGuide.leadingAnchor, constant: 16),
            resultContainer.trailingAnchor.constraint(equalTo: resultScrollView.frameLayoutGuide.trailingAnchor, constant: -16),
            resultContainer.bottomAnchor.constraint(equalTo: resultScrollView.contentLayoutGuide.bottomAnchor, constant: -24)
        ])
    }

    private func bootstrapEntryMode() {
        if let baselineRecord, let comparisonRecord {
            displayedSnapshot = ComparisonSnapshot(
                id: UUID(),
                baselineRecord: baselineRecord,
                comparisonRecord: comparisonRecord,
                createdAt: Date()
            )
            showResultMode()
            return
        }

        refreshSelectionModeUI()
    }

    private func refreshSelectionModeUI() {
        let hasEnoughHistory = viewModel.history.count >= 2
        emptyStateLabel.isHidden = hasEnoughHistory
        tableView.isHidden = !hasEnoughHistory
        selectHintLabel.isHidden = !hasEnoughHistory

        let hasBothSelections = selectedBaselineId != nil && selectedComparisonId != nil
        compareButton.isHidden = !hasEnoughHistory || !hasBothSelections

        resultScrollView.isHidden = true
        tableView.reloadData()
    }

    private func showResultMode() {
        guard let snapshot = displayedSnapshot else { return }

        selectHintLabel.isHidden = true
        tableView.isHidden = true
        emptyStateLabel.isHidden = true
        compareButton.isHidden = true
        resultScrollView.isHidden = false

        timestampLabel.text = "Baseline: \(timestampFormatter.string(from: snapshot.baselineRecord.timestamp))\nComparison: \(timestampFormatter.string(from: snapshot.comparisonRecord.timestamp))"

        while resultContainer.arrangedSubviews.count > 1 {
            let viewToRemove = resultContainer.arrangedSubviews.last!
            resultContainer.removeArrangedSubview(viewToRemove)
            viewToRemove.removeFromSuperview()
        }

        resultContainer.addArrangedSubview(makeMetricCard(
            title: "RTP",
            baseline: formattedPercent(snapshot.baselineRecord.metricsSummary.rtp),
            comparison: formattedPercent(snapshot.comparisonRecord.metricsSummary.rtp),
            delta: formattedSignedPercent(snapshot.rtpDelta),
            deltaValue: snapshot.rtpDelta
        ))

        resultContainer.addArrangedSubview(makeMetricCard(
            title: "Hit Rate",
            baseline: formattedPercent(snapshot.baselineRecord.metricsSummary.collisionFrequency),
            comparison: formattedPercent(snapshot.comparisonRecord.metricsSummary.collisionFrequency),
            delta: formattedSignedPercent(snapshot.hitDelta),
            deltaValue: snapshot.hitDelta
        ))

        resultContainer.addArrangedSubview(makeMetricCard(
            title: "EV/Spin",
            baseline: formattedDecimal(snapshot.baselineRecord.metricsSummary.evValue),
            comparison: formattedDecimal(snapshot.comparisonRecord.metricsSummary.evValue),
            delta: formattedSignedDecimal(snapshot.evDelta),
            deltaValue: snapshot.evDelta
        ))

        resultContainer.addArrangedSubview(makeMetricCard(
            title: "Max Win",
            baseline: formattedMultiplier(snapshot.baselineRecord.metricsSummary.zenithMultiplier),
            comparison: formattedMultiplier(snapshot.comparisonRecord.metricsSummary.zenithMultiplier),
            delta: formattedSignedMultiplier(snapshot.maxWinDelta),
            deltaValue: snapshot.maxWinDelta
        ))

        if let tierBreakdownSection = makeTierBreakdownSection(snapshot: snapshot) {
            resultContainer.addArrangedSubview(tierBreakdownSection)
        }
    }

    private func makeMetricCard(title: String, baseline: String, comparison: String, delta: String, deltaValue: Double) -> UIView {
        let card = UIView()
        card.backgroundColor = GambogePalette.midnightSlate
        card.layer.cornerRadius = 16
        card.layer.borderWidth = 1
        card.layer.borderColor = GambogePalette.twilightPlume.cgColor

        let vStack = UIStackView()
        vStack.axis = .vertical
        vStack.spacing = 10
        vStack.translatesAutoresizingMaskIntoConstraints = false

        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.textColor = .white
        titleLabel.font = CinnabarTypography.slateAmpleMedium()

        let row = UIStackView()
        row.axis = .horizontal
        row.distribution = .fillEqually
        row.spacing = 8

        row.addArrangedSubview(makeValueColumn(label: "Baseline", value: baseline, color: .white))
        row.addArrangedSubview(makeValueColumn(label: "Comparison", value: comparison, color: .white))
        row.addArrangedSubview(makeValueColumn(label: "Delta", value: delta, color: deltaColor(for: deltaValue)))

        card.addSubview(vStack)
        vStack.addArrangedSubview(titleLabel)
        vStack.addArrangedSubview(row)

        NSLayoutConstraint.activate([
            vStack.topAnchor.constraint(equalTo: card.topAnchor, constant: 14),
            vStack.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 14),
            vStack.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -14),
            vStack.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -14)
        ])

        return card
    }

    private func makeValueColumn(label: String, value: String, color: UIColor) -> UIView {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 4

        let labelView = UILabel()
        labelView.text = label
        labelView.textColor = GambogePalette.silverHaze
        labelView.font = CinnabarTypography.slateModerateRegular()

        let valueView = UILabel()
        valueView.text = value
        valueView.textColor = color
        valueView.font = CinnabarTypography.slateAmpleMedium()

        stack.addArrangedSubview(labelView)
        stack.addArrangedSubview(valueView)
        return stack
    }

    private func makeTierBreakdownSection(snapshot: ComparisonSnapshot) -> UIView? {
        let baselineTiers = snapshot.baselineRecord.metricsSummary.tierSummaries
        let comparisonTiers = snapshot.comparisonRecord.metricsSummary.tierSummaries

        guard !baselineTiers.isEmpty, !comparisonTiers.isEmpty, !snapshot.tierDeltas.isEmpty else {
            return nil
        }

        let comparisonByName = Dictionary(uniqueKeysWithValues: comparisonTiers.map { ($0.tierName, $0) })
        let deltasByName = Dictionary(uniqueKeysWithValues: snapshot.tierDeltas.map { ($0.tierName, $0) })

        let section = UIView()
        section.backgroundColor = GambogePalette.midnightSlate
        section.layer.cornerRadius = 16
        section.layer.borderWidth = 1
        section.layer.borderColor = GambogePalette.twilightPlume.cgColor

        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 12
        stack.translatesAutoresizingMaskIntoConstraints = false

        let titleLabel = UILabel()
        titleLabel.text = "Tier Breakdown"
        titleLabel.textColor = .white
        titleLabel.font = CinnabarTypography.slateAmpleMedium()
        stack.addArrangedSubview(titleLabel)

        for baselineTier in baselineTiers {
            guard let comparisonTier = comparisonByName[baselineTier.tierName],
                  let delta = deltasByName[baselineTier.tierName] else { continue }
            stack.addArrangedSubview(
                makeTierDeltaRow(
                    tierName: baselineTier.tierName,
                    baseline: baselineTier,
                    comparison: comparisonTier,
                    delta: delta
                )
            )
        }

        section.addSubview(stack)

        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: section.topAnchor, constant: 14),
            stack.leadingAnchor.constraint(equalTo: section.leadingAnchor, constant: 14),
            stack.trailingAnchor.constraint(equalTo: section.trailingAnchor, constant: -14),
            stack.bottomAnchor.constraint(equalTo: section.bottomAnchor, constant: -14)
        ])

        return stack.arrangedSubviews.count > 1 ? section : nil
    }

    private func makeTierDeltaRow(
        tierName: String,
        baseline: HistoryRecord.MetricsSummary.TierSummary,
        comparison: HistoryRecord.MetricsSummary.TierSummary,
        delta: ComparisonSnapshot.TierDelta
    ) -> UIView {
        let container = UIStackView()
        container.axis = .vertical
        container.spacing = 8

        let header = UILabel()
        header.text = tierName
        header.textColor = .white
        header.font = CinnabarTypography.slateModerateRegular()
        container.addArrangedSubview(header)

        let metricsRow = UIStackView()
        metricsRow.axis = .horizontal
        metricsRow.distribution = .fillEqually
        metricsRow.spacing = 8
        metricsRow.addArrangedSubview(makeTierMetricColumn(
            label: "Likelihood",
            baseline: formattedPercent(baseline.likelihood),
            comparison: formattedPercent(comparison.likelihood),
            delta: formattedSignedPercent(delta.likelihoodDelta),
            deltaValue: delta.likelihoodDelta
        ))
        metricsRow.addArrangedSubview(makeTierMetricColumn(
            label: "RTP Fragment",
            baseline: formattedPercent(baseline.rtpFragment),
            comparison: formattedPercent(comparison.rtpFragment),
            delta: formattedSignedPercent(delta.rtpDelta),
            deltaValue: delta.rtpDelta
        ))
        container.addArrangedSubview(metricsRow)

        let divider = UIView()
        divider.backgroundColor = GambogePalette.twilightPlume
        divider.heightAnchor.constraint(equalToConstant: 1).isActive = true
        container.addArrangedSubview(divider)

        return container
    }

    private func makeTierMetricColumn(
        label: String,
        baseline: String,
        comparison: String,
        delta: String,
        deltaValue: Double
    ) -> UIView {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 4

        let labelView = UILabel()
        labelView.text = label
        labelView.textColor = GambogePalette.silverHaze
        labelView.font = CinnabarTypography.slateModerateRegular()

        let baselineView = UILabel()
        baselineView.text = "B: \(baseline)"
        baselineView.textColor = .white
        baselineView.font = CinnabarTypography.slateModerateRegular()

        let comparisonView = UILabel()
        comparisonView.text = "C: \(comparison)"
        comparisonView.textColor = .white
        comparisonView.font = CinnabarTypography.slateModerateRegular()

        let deltaView = UILabel()
        deltaView.text = "Δ: \(delta)"
        deltaView.textColor = deltaColor(for: deltaValue)
        deltaView.font = CinnabarTypography.slateAmpleMedium()

        [labelView, baselineView, comparisonView, deltaView].forEach { stack.addArrangedSubview($0) }
        return stack
    }

    private func deltaColor(for value: Double) -> UIColor {
        if value > 0 { return GambogePalette.verdantTeal }
        if value < 0 { return GambogePalette.crimsonFlare }
        return GambogePalette.silverHaze
    }

    private func formattedPercent(_ value: Double) -> String {
        String(format: "%.2f%%", value * 100)
    }

    private func formattedSignedPercent(_ value: Double) -> String {
        String(format: "%@%.2f%%", value >= 0 ? "+" : "", value * 100)
    }

    private func formattedDecimal(_ value: Double) -> String {
        String(format: "%.4f", value)
    }

    private func formattedSignedDecimal(_ value: Double) -> String {
        String(format: "%@%.4f", value >= 0 ? "+" : "", value)
    }

    private func formattedMultiplier(_ value: Double) -> String {
        String(format: "%.2fx", value)
    }

    private func formattedSignedMultiplier(_ value: Double) -> String {
        String(format: "%@%.2fx", value >= 0 ? "+" : "", value)
    }

    private func selectedRoleText(for record: HistoryRecord) -> String? {
        if selectedBaselineId == record.id { return "Baseline" }
        if selectedComparisonId == record.id { return "Comparison" }
        return nil
    }

    @objc private func compareTapped() {
        guard let baselineId = selectedBaselineId,
              let comparisonId = selectedComparisonId,
              let baseline = viewModel.history.first(where: { $0.id == baselineId }),
              let comparison = viewModel.history.first(where: { $0.id == comparisonId }) else {
            return
        }

        displayedSnapshot = ComparisonSnapshot(
            id: UUID(),
            baselineRecord: baseline,
            comparisonRecord: comparison,
            createdAt: Date()
        )
        showResultMode()
    }

    @objc private func dismissTapped() {
        dismiss(animated: true)
    }
}

extension ComparisonScreen: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.history.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ComparisonSelectableHistoryCell.reuseIdentifier, for: indexPath) as? ComparisonSelectableHistoryCell else {
            return UITableViewCell()
        }

        let record = viewModel.history[indexPath.row]
        let title = timestampFormatter.string(from: record.timestamp)
        let metrics = "RTP \(formattedPercent(record.metricsSummary.rtp)) · Hit \(formattedPercent(record.metricsSummary.collisionFrequency)) · EV \(formattedDecimal(record.metricsSummary.evValue))"
        cell.configure(title: title, metrics: metrics, selectedRole: selectedRoleText(for: record))
        return cell
    }
}

extension ComparisonScreen: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let tapped = viewModel.history[indexPath.row]

        if selectedBaselineId == tapped.id {
            selectedBaselineId = nil
        } else if selectedComparisonId == tapped.id {
            selectedComparisonId = nil
        } else if selectedBaselineId == nil {
            selectedBaselineId = tapped.id
        } else if selectedComparisonId == nil {
            selectedComparisonId = tapped.id
        } else {
            selectedComparisonId = tapped.id
        }

        refreshSelectionModeUI()
    }
}

private final class ComparisonSelectableHistoryCell: UITableViewCell {
    static let reuseIdentifier = "ComparisonSelectableHistoryCell"

    private let cardView = UIView()
    private let titleLabel = UILabel()
    private let metricsLabel = UILabel()
    private let roleBadge = UILabel()
    private let stackView = UIStackView()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureAppearance()
        configureLayout()
        sutureConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(title: String, metrics: String, selectedRole: String?) {
        titleLabel.text = title
        metricsLabel.text = metrics
        roleBadge.text = selectedRole
        roleBadge.isHidden = selectedRole == nil

        if selectedRole == nil {
            cardView.layer.borderColor = GambogePalette.twilightPlume.cgColor
        } else {
            cardView.layer.borderColor = GambogePalette.auroraViolet.cgColor
        }
    }

    private func configureAppearance() {
        backgroundColor = .clear
        selectionStyle = .none
        contentView.backgroundColor = .clear

        cardView.backgroundColor = GambogePalette.midnightSlate
        cardView.layer.cornerRadius = 16
        cardView.layer.borderWidth = 1
        cardView.layer.borderColor = GambogePalette.twilightPlume.cgColor
        cardView.translatesAutoresizingMaskIntoConstraints = false

        titleLabel.font = CinnabarTypography.slateAmpleMedium()
        titleLabel.textColor = .white

        metricsLabel.font = CinnabarTypography.slateModerateRegular()
        metricsLabel.textColor = GambogePalette.silverHaze
        metricsLabel.numberOfLines = 0

        roleBadge.font = CinnabarTypography.slateModerateRegular()
        roleBadge.textColor = .white
        roleBadge.backgroundColor = GambogePalette.auroraViolet
        roleBadge.layer.cornerRadius = 10
        roleBadge.clipsToBounds = true
        roleBadge.textAlignment = .center
        roleBadge.translatesAutoresizingMaskIntoConstraints = false

        stackView.axis = .vertical
        stackView.spacing = 8
        stackView.translatesAutoresizingMaskIntoConstraints = false
    }

    private func configureLayout() {
        contentView.addSubview(cardView)
        cardView.addSubview(stackView)
        cardView.addSubview(roleBadge)
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(metricsLabel)
    }

    private func sutureConstraints() {
        NSLayoutConstraint.activate([
            cardView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            cardView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),

            roleBadge.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 12),
            roleBadge.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -12),
            roleBadge.heightAnchor.constraint(equalToConstant: 20),
            roleBadge.widthAnchor.constraint(greaterThanOrEqualToConstant: 82),

            stackView.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 14),
            stackView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 14),
            stackView.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -14),
            stackView.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -14)
        ])
    }
}
