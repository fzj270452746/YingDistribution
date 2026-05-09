import UIKit

private let historyScreenIntegerFormatter: NumberFormatter = {
    let formatter = NumberFormatter()
    formatter.numberStyle = .decimal
    return formatter
}()

private let historyScreenCurrencyFormatter: NumberFormatter = {
    let formatter = NumberFormatter()
    formatter.numberStyle = .currency
    formatter.currencyCode = "USD"
    formatter.locale = Locale(identifier: "en_US_POSIX")
    formatter.minimumFractionDigits = 2
    formatter.maximumFractionDigits = 2
    return formatter
}()

final class HistoryScreen: UIViewController {

    private let viewModel = VermilionDashboardVM.shared
    private let tableView = UITableView(frame: .zero, style: .plain)
    private let emptyStateLabel = UILabel()
    private lazy var dismissBtn = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(dismissTapped))

    private let timestampFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, yyyy · HH:mm"
        return formatter
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = GambogePalette.abyss
        title = "History"
        navigationItem.rightBarButtonItem = dismissBtn
        configureTableView()
        configureEmptyState()
        concoctLayout()
        sutureConstraints()
        refreshHistoryUI()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        refreshHistoryUI()
    }

    private func configureTableView() {
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
        tableView.contentInset = UIEdgeInsets(top: 16, left: 0, bottom: 24, right: 0)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 112
        tableView.register(HistoryRecordCell.self, forCellReuseIdentifier: HistoryRecordCell.reuseIdentifier)
    }

    private func configureEmptyState() {
        emptyStateLabel.text = "No history yet"
        emptyStateLabel.textColor = GambogePalette.silverHaze
        emptyStateLabel.font = CinnabarTypography.slateAmpleMedium()
        emptyStateLabel.textAlignment = .center
        emptyStateLabel.translatesAutoresizingMaskIntoConstraints = false
    }

    private func concoctLayout() {
        view.addSubview(tableView)
        view.addSubview(emptyStateLabel)
    }

    private func sutureConstraints() {
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            emptyStateLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyStateLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    private func refreshHistoryUI() {
        tableView.reloadData()
        emptyStateLabel.isHidden = !viewModel.history.isEmpty
    }

    private func configSummary(for record: HistoryRecord) -> String {
        let mode = record.configSummary.cascadeMode
            .replacingOccurrences(of: "_", with: " ")
            .capitalized
        return "\(formatInteger(record.configSummary.iterationQuantum)) spins · \(formatCurrency(record.configSummary.wagerAmount)) · \(mode)"
    }

    private func metricsSummary(for record: HistoryRecord) -> String {
        let rtp = String(format: "%.2f%%", record.metricsSummary.rtp * 100)
        let hitRate = String(format: "%.2f%%", record.metricsSummary.collisionFrequency * 100)
        return "RTP \(rtp) · Hit \(hitRate)"
    }

    private func formatInteger(_ value: Int) -> String {
        historyScreenIntegerFormatter.string(from: NSNumber(value: value)) ?? "\(value)"
    }

    private func formatCurrency(_ value: Double) -> String {
        historyScreenCurrencyFormatter.string(from: NSNumber(value: value)) ?? String(format: "$%.2f", value)
    }

    @objc private func dismissTapped() {
        dismiss(animated: true)
    }
}

extension HistoryScreen: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.history.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: HistoryRecordCell.reuseIdentifier, for: indexPath) as? HistoryRecordCell else {
            return UITableViewCell()
        }

        let record = viewModel.history[indexPath.row]
        cell.configure(
            title: timestampFormatter.string(from: record.timestamp),
            configSummary: configSummary(for: record),
            metricsSummary: metricsSummary(for: record)
        )
        return cell
    }
}

extension HistoryScreen: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let record = viewModel.history[indexPath.row]
        viewModel.restoreFromHistory(record)
        dismiss(animated: true)
    }

    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let record = viewModel.history[indexPath.row]
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { [weak self] _, _, completion in
            guard let self else {
                completion(false)
                return
            }

            self.viewModel.deleteHistoryRecord(id: record.id)
            self.refreshHistoryUI()
            completion(true)
        }
        deleteAction.backgroundColor = GambogePalette.crimsonFlare

        let configuration = UISwipeActionsConfiguration(actions: [deleteAction])
        configuration.performsFirstActionWithFullSwipe = true
        return configuration
    }
}

private final class HistoryRecordCell: UITableViewCell {
    static let reuseIdentifier = "HistoryRecordCell"

    private let cardView = UIView()
    private let titleLabel = UILabel()
    private let configLabel = UILabel()
    private let metricsLabel = UILabel()
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

    func configure(title: String, configSummary: String, metricsSummary: String) {
        titleLabel.text = title
        configLabel.text = configSummary
        metricsLabel.text = metricsSummary
    }

    private func configureAppearance() {
        backgroundColor = .clear
        selectionStyle = .none

        contentView.backgroundColor = .clear

        cardView.backgroundColor = GambogePalette.midnightSlate
        cardView.layer.cornerRadius = 18
        cardView.layer.borderWidth = 1
        cardView.layer.borderColor = GambogePalette.twilightPlume.cgColor
        cardView.translatesAutoresizingMaskIntoConstraints = false

        titleLabel.font = CinnabarTypography.slateAmpleMedium()
        titleLabel.textColor = .white
        titleLabel.numberOfLines = 1

        configLabel.font = CinnabarTypography.slateModerateRegular()
        configLabel.textColor = GambogePalette.silverHaze
        configLabel.numberOfLines = 0

        metricsLabel.font = CinnabarTypography.slateModerateRegular()
        metricsLabel.textColor = GambogePalette.silverHaze
        metricsLabel.numberOfLines = 0

        stackView.axis = .vertical
        stackView.spacing = 8
        stackView.translatesAutoresizingMaskIntoConstraints = false
    }

    private func configureLayout() {
        contentView.addSubview(cardView)
        cardView.addSubview(stackView)
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(configLabel)
        stackView.addArrangedSubview(metricsLabel)
    }

    private func sutureConstraints() {
        NSLayoutConstraint.activate([
            cardView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            cardView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),

            stackView.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 16),
            stackView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16),
            stackView.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -16)
        ])
    }
}
