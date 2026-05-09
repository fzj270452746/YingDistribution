import UIKit

private let presetsScreenIntegerFormatter: NumberFormatter = {
    let formatter = NumberFormatter()
    formatter.numberStyle = .decimal
    return formatter
}()

private let presetsScreenCurrencyFormatter: NumberFormatter = {
    let formatter = NumberFormatter()
    formatter.numberStyle = .currency
    formatter.currencyCode = "USD"
    formatter.locale = Locale(identifier: "en_US_POSIX")
    formatter.minimumFractionDigits = 2
    formatter.maximumFractionDigits = 2
    return formatter
}()

final class PresetsScreen: UIViewController {

    private let viewModel = VermilionDashboardVM.shared
    private let tableView = UITableView(frame: .zero, style: .plain)
    private let emptyStateLabel = UILabel()
    private lazy var saveButton = UIBarButtonItem(title: "Save Current", style: .plain, target: self, action: #selector(saveCurrentTapped))
    private lazy var dismissButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(dismissTapped))

    private let timestampFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, yyyy · HH:mm"
        return formatter
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = GambogePalette.abyss
        title = "Presets"
        navigationItem.leftBarButtonItem = saveButton
        navigationItem.rightBarButtonItem = dismissButton
        configureTableView()
        configureEmptyState()
        concoctLayout()
        sutureConstraints()
        refreshPresetsUI()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.loadPresets()
        refreshPresetsUI()
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
        tableView.register(PresetCell.self, forCellReuseIdentifier: PresetCell.reuseIdentifier)
    }

    private func configureEmptyState() {
        emptyStateLabel.text = "No presets saved"
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

    private func refreshPresetsUI() {
        tableView.reloadData()
        emptyStateLabel.isHidden = !viewModel.presets.isEmpty
    }

    private func summary(for preset: PresetEntity) -> String {
        let iterations = formatInteger(preset.config.iterationQuantum)
        let wager = formatCurrency(preset.config.wagerAmount)
        let mode = preset.config.cascadeMode.rawValue
        return "\(iterations) spins · \(wager) · \(mode)"
    }

    private func formatInteger(_ value: Int) -> String {
        presetsScreenIntegerFormatter.string(from: NSNumber(value: value)) ?? "\(value)"
    }

    private func formatCurrency(_ value: Double) -> String {
        presetsScreenCurrencyFormatter.string(from: NSNumber(value: value)) ?? String(format: "$%.2f", value)
    }

    private func presentDuplicateNameAlert() {
        let alert = UIAlertController(
            title: "Unable to Save Preset",
            message: "A preset with this name already exists. Please choose a different name.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    private func presentEmptyNameAlert() {
        let alert = UIAlertController(
            title: "Preset name required",
            message: "Please enter a preset name.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    @objc private func saveCurrentTapped() {
        let alert = UIAlertController(title: "Save Preset", message: nil, preferredStyle: .alert)
        alert.addTextField { textField in
            textField.placeholder = "Preset name"
            textField.clearButtonMode = .whileEditing
        }

        let saveAction = UIAlertAction(title: "Save", style: .default) { [weak self, weak alert] _ in
            guard let self else { return }
            let rawName = alert?.textFields?.first?.text ?? ""
            let name = rawName.trimmingCharacters(in: .whitespacesAndNewlines)

            guard !name.isEmpty else {
                self.presentEmptyNameAlert()
                return
            }

            if self.viewModel.savePreset(name: name) {
                self.refreshPresetsUI()
            } else {
                self.presentDuplicateNameAlert()
            }
        }

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(saveAction)
        present(alert, animated: true)
    }

    @objc private func dismissTapped() {
        dismiss(animated: true)
    }
}

extension PresetsScreen: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.presets.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: PresetCell.reuseIdentifier, for: indexPath) as? PresetCell else {
            return UITableViewCell()
        }

        let preset = viewModel.presets[indexPath.row]
        cell.configure(
            name: preset.name,
            summary: summary(for: preset),
            createdAt: timestampFormatter.string(from: preset.createdAt)
        )
        return cell
    }
}

extension PresetsScreen: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let preset = viewModel.presets[indexPath.row]
        viewModel.activeConfig = preset.config
        dismiss(animated: true)
    }

    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let preset = viewModel.presets[indexPath.row]
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { [weak self] _, _, completion in
            guard let self else {
                completion(false)
                return
            }

            self.viewModel.deletePreset(id: preset.id)
            self.refreshPresetsUI()
            completion(true)
        }
        deleteAction.backgroundColor = GambogePalette.crimsonFlare

        let configuration = UISwipeActionsConfiguration(actions: [deleteAction])
        configuration.performsFirstActionWithFullSwipe = true
        return configuration
    }
}

private final class PresetCell: UITableViewCell {
    static let reuseIdentifier = "PresetCell"

    private let cardView = UIView()
    private let nameLabel = UILabel()
    private let summaryLabel = UILabel()
    private let createdAtLabel = UILabel()
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

    func configure(name: String, summary: String, createdAt: String) {
        nameLabel.text = name
        summaryLabel.text = summary
        createdAtLabel.text = createdAt
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

        nameLabel.font = CinnabarTypography.slateAmpleMedium()
        nameLabel.textColor = .white
        nameLabel.numberOfLines = 1

        summaryLabel.font = CinnabarTypography.slateModerateRegular()
        summaryLabel.textColor = GambogePalette.silverHaze
        summaryLabel.numberOfLines = 0

        createdAtLabel.font = CinnabarTypography.slateModerateRegular()
        createdAtLabel.textColor = GambogePalette.silverHaze
        createdAtLabel.numberOfLines = 1

        stackView.axis = .vertical
        stackView.spacing = 8
        stackView.translatesAutoresizingMaskIntoConstraints = false
    }

    private func configureLayout() {
        contentView.addSubview(cardView)
        cardView.addSubview(stackView)
        stackView.addArrangedSubview(nameLabel)
        stackView.addArrangedSubview(summaryLabel)
        stackView.addArrangedSubview(createdAtLabel)
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
