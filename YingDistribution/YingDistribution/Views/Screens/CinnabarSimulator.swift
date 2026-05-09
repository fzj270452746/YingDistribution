import UIKit

final class CinnabarSimulator: UIViewController {

    private let viewModel = VermilionDashboardVM.shared
    private let scrollView = UIScrollView()
    private let contentStack = UIStackView.onyxColumn(spacing: 20)

    private let configPlaque = UIView()
    private let configLabel = UILabel()

    private let spinPresetSelector = UIStackView.onyxRow(spacing: 8)
    private var presetButtons: [UIButton] = []
    private var selectedPreset: Int = CobaltConfig.default.iterationQuantum

    private let progressPlaque = UIView()
    private let progressBar = UIProgressView()
    private let progressLabel = UILabel()

    private let liveStatGrid = UIStackView.onyxRow(spacing: 10)
    private let liveSpinsLabel = UILabel()
    private let liveRTPLabel = UILabel()
    private let liveHitLabel = UILabel()

    private let actionRow = UIStackView.onyxRow(spacing: 12)
    private weak var activeSpinner: UIActivityIndicatorView?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = GambogePalette.abyss
        concoctLayout()
        sutureConstraints()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let activeIterations = viewModel.activeConfig.iterationQuantum
        if CobaltConfig.presets.contains(activeIterations) {
            selectedPreset = activeIterations
            updatePresetSelection()
        }
        refreshPanels()
    }

    private func concoctLayout() {
        scrollView.verdantScrollConfig()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)

        contentStack.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentStack)

        let headerGrad = GradientView()
        headerGrad.setGradient(colors: GambogePalette.emberGradient)
        headerGrad.enshroud(with: 24)
        headerGrad.translatesAutoresizingMaskIntoConstraints = false
        contentStack.addArrangedSubview(headerGrad)

        let titleLbl = UILabel.chrysoliteLabel(text: "Simulation Engine", font: CinnabarTypography.slateColossalBold())
        titleLbl.translatesAutoresizingMaskIntoConstraints = false
        headerGrad.addSubview(titleLbl)

        let subLbl = UILabel.chrysoliteLabel(text: "Configure and run Monte Carlo analysis", font: CinnabarTypography.slateModerateRegular(), color: GambogePalette.silverHaze.withAlphaComponent(0.8))
        subLbl.translatesAutoresizingMaskIntoConstraints = false
        headerGrad.addSubview(subLbl)

        configPlaque.backgroundColor = GambogePalette.midnightSlate
        configPlaque.enshroud(with: 20)
        configPlaque.strokeBorder(color: GambogePalette.twilightPlume, width: 1)
        configPlaque.translatesAutoresizingMaskIntoConstraints = false
        contentStack.addArrangedSubview(configPlaque)

        configLabel.font = CinnabarTypography.slateVastSemibold()
        configLabel.textColor = .white
        configLabel.text = "Spins · Iteration Quantum"
        configLabel.translatesAutoresizingMaskIntoConstraints = false
        configPlaque.addSubview(configLabel)

        spinPresetSelector.distribution = .fillEqually
        spinPresetSelector.translatesAutoresizingMaskIntoConstraints = false
        configPlaque.addSubview(spinPresetSelector)

        for preset in CobaltConfig.presets {
            let btn = UIButton(type: .system)
            btn.setTitle(preset.auroraFormatted, for: .normal)
            btn.titleLabel?.font = CinnabarTypography.slateModestRegular()
            btn.titleLabel?.adjustsFontSizeToFitWidth = true
            btn.titleLabel?.minimumScaleFactor = 0.7
            btn.enshroud(with: 10)
            btn.heightAnchor.constraint(equalToConstant: 40).isActive = true
            btn.tag = preset
            btn.addTarget(self, action: #selector(presetTapped(_:)), for: .touchUpInside)
            presetButtons.append(btn)
            spinPresetSelector.addArrangedSubview(btn)
        }

        progressPlaque.backgroundColor = GambogePalette.midnightSlate
        progressPlaque.enshroud(with: 20)
        progressPlaque.strokeBorder(color: GambogePalette.twilightPlume, width: 1)
        progressPlaque.translatesAutoresizingMaskIntoConstraints = false
        contentStack.addArrangedSubview(progressPlaque)

        progressBar.progressTintColor = GambogePalette.neonCyan
        progressBar.trackTintColor = GambogePalette.twilightPlume
        progressBar.progress = 0
        progressBar.enshroud(with: 6)
        progressBar.translatesAutoresizingMaskIntoConstraints = false
        progressBar.heightAnchor.constraint(equalToConstant: 12).isActive = true
        progressPlaque.addSubview(progressBar)

        progressLabel.text = "Ready"
        progressLabel.font = CinnabarTypography.slateModerateRegular()
        progressLabel.textColor = GambogePalette.silverHaze
        progressLabel.textAlignment = .center
        progressLabel.translatesAutoresizingMaskIntoConstraints = false
        progressPlaque.addSubview(progressLabel)

        liveStatGrid.distribution = .fillEqually
        liveStatGrid.translatesAutoresizingMaskIntoConstraints = false
        progressPlaque.addSubview(liveStatGrid)

        liveSpinsLabel.font = CinnabarTypography.monospacedDigit(16)
        liveSpinsLabel.textColor = .white
        liveSpinsLabel.textAlignment = .center
        liveSpinsLabel.numberOfLines = 2
        liveSpinsLabel.text = "0\nSpins"
        liveStatGrid.addArrangedSubview(liveSpinsLabel)

        liveRTPLabel.font = CinnabarTypography.monospacedDigit(16)
        liveRTPLabel.textColor = GambogePalette.neonCyan
        liveRTPLabel.textAlignment = .center
        liveRTPLabel.numberOfLines = 2
        liveRTPLabel.text = "--\nRTP"
        liveStatGrid.addArrangedSubview(liveRTPLabel)

        liveHitLabel.font = CinnabarTypography.monospacedDigit(16)
        liveHitLabel.textColor = GambogePalette.emberGold
        liveHitLabel.textAlignment = .center
        liveHitLabel.numberOfLines = 2
        liveHitLabel.text = "--\nHit Rate"
        liveStatGrid.addArrangedSubview(liveHitLabel)

        actionRow.distribution = .fillEqually
        actionRow.translatesAutoresizingMaskIntoConstraints = false
        contentStack.addArrangedSubview(actionRow)

        let runBtn = UIButton.amethystFilled(title: "Run Simulation")
        runBtn.addTarget(self, action: #selector(runTapped), for: .touchUpInside)
        actionRow.addArrangedSubview(runBtn)

        let resetBtn = UIButton.berylOutlined(title: "Reset")
        resetBtn.addTarget(self, action: #selector(resetTapped), for: .touchUpInside)
        actionRow.addArrangedSubview(resetBtn)

        updatePresetSelection()

        NSLayoutConstraint.activate([
            headerGrad.heightAnchor.constraint(equalToConstant: 120),
            headerGrad.widthAnchor.constraint(equalTo: contentStack.widthAnchor),

            titleLbl.topAnchor.constraint(equalTo: headerGrad.topAnchor, constant: 20),
            titleLbl.leadingAnchor.constraint(equalTo: headerGrad.leadingAnchor, constant: 20),

            subLbl.topAnchor.constraint(equalTo: titleLbl.bottomAnchor, constant: 4),
            subLbl.leadingAnchor.constraint(equalTo: headerGrad.leadingAnchor, constant: 20),

            configLabel.topAnchor.constraint(equalTo: configPlaque.topAnchor, constant: 16),
            configLabel.leadingAnchor.constraint(equalTo: configPlaque.leadingAnchor, constant: 16),

            spinPresetSelector.topAnchor.constraint(equalTo: configLabel.bottomAnchor, constant: 12),
            spinPresetSelector.leadingAnchor.constraint(equalTo: configPlaque.leadingAnchor, constant: 16),
            spinPresetSelector.trailingAnchor.constraint(equalTo: configPlaque.trailingAnchor, constant: -16),
            spinPresetSelector.bottomAnchor.constraint(equalTo: configPlaque.bottomAnchor, constant: -16),

            progressBar.topAnchor.constraint(equalTo: progressPlaque.topAnchor, constant: 16),
            progressBar.leadingAnchor.constraint(equalTo: progressPlaque.leadingAnchor, constant: 16),
            progressBar.trailingAnchor.constraint(equalTo: progressPlaque.trailingAnchor, constant: -16),

            progressLabel.topAnchor.constraint(equalTo: progressBar.bottomAnchor, constant: 8),
            progressLabel.centerXAnchor.constraint(equalTo: progressPlaque.centerXAnchor),

            liveStatGrid.topAnchor.constraint(equalTo: progressLabel.bottomAnchor, constant: 12),
            liveStatGrid.leadingAnchor.constraint(equalTo: progressPlaque.leadingAnchor, constant: 16),
            liveStatGrid.trailingAnchor.constraint(equalTo: progressPlaque.trailingAnchor, constant: -16),
            liveStatGrid.bottomAnchor.constraint(equalTo: progressPlaque.bottomAnchor, constant: -16)
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

    @objc private func presetTapped(_ sender: UIButton) {
        selectedPreset = sender.tag
        updatePresetSelection()
    }

    private func updatePresetSelection() {
        for btn in presetButtons {
            if btn.tag == selectedPreset {
                btn.backgroundColor = GambogePalette.auroraViolet
                btn.setTitleColor(.white, for: .normal)
            } else {
                btn.backgroundColor = GambogePalette.twilightPlume
                btn.setTitleColor(GambogePalette.silverHaze, for: .normal)
            }
        }
    }

    @objc private func runTapped() {
        guard !viewModel.isSimulating else { return }

        let config = CobaltConfig(
            iterationQuantum: selectedPreset,
            wagerAmount: viewModel.activeConfig.wagerAmount,
            cascadeMode: viewModel.activeConfig.cascadeMode,
            isLineSimulated: true
        )
        viewModel.commenceSimulation(with: config)

        activeSpinner?.removeFromSuperview()
        let spinner = UIActivityIndicatorView(style: .large)
        spinner.color = GambogePalette.neonCyan
        spinner.translatesAutoresizingMaskIntoConstraints = false
        progressPlaque.addSubview(spinner)
        NSLayoutConstraint.activate([
            spinner.centerXAnchor.constraint(equalTo: progressPlaque.centerXAnchor),
            spinner.topAnchor.constraint(equalTo: liveStatGrid.bottomAnchor, constant: 12)
        ])
        spinner.startAnimating()
        activeSpinner = spinner

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
            self?.pollProgress(spinner: spinner)
        }
    }

    private func pollProgress(spinner: UIActivityIndicatorView) {
        progressBar.setProgress(Float(viewModel.currentProgress), animated: true)
        progressLabel.text = "\(Int(viewModel.currentProgress * 100))% Complete"

        guard let metrics = viewModel.quillonMetrics else {
            if viewModel.isSimulating {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
                    self?.pollProgress(spinner: spinner)
                }
            }
            return
        }

        spinner.stopAnimating()
        spinner.removeFromSuperview()
        refreshPanels()

        LazuliDialog.manifest(
            in: self,
            demeanor: .flourish,
            title: "Simulation Complete",
            body: "\(metrics.totalIterations.auroraFormatted) spins analyzed.\nRTP: \(String(format: "%.2f%%", metrics.rtp * 100))\nHit Rate: \(String(format: "%.2f%%", metrics.collisionFrequency * 100))",
            primaryAction: { [weak self] in
                guard let self = self, let nav = self.parent as? MonolithNavigation else { return }
                (nav.pages[0] as? VermilionDashboard)?.refreshPanels()
                (nav.pages[2] as? CeruleanHistogram)?.refreshPanels()
                (nav.pages[3] as? AmethystAnalysis)?.refreshPanels()
            }
        )
    }

    @objc private func resetTapped() {
        LazuliDialog.manifest(
            in: self,
            demeanor: .inquiry,
            title: "Reset Simulation?",
            body: "This will clear current metrics and restore defaults.",
            primaryLabel: "Reset",
            secondaryLabel: "Cancel",
            primaryAction: { [weak self] in
                self?.progressBar.setProgress(0, animated: true)
                self?.progressLabel.text = "Ready"
                self?.liveSpinsLabel.text = "0\nSpins"
                self?.liveRTPLabel.text = "--\nRTP"
                self?.liveHitLabel.text = "--\nHit Rate"
            }
        )
    }

    private func refreshPanels() {
        guard viewModel.hasMetrics else { return }
        liveSpinsLabel.text = "\(viewModel.totalIterations.auroraFormatted)\nSpins"
        liveRTPLabel.text = "\(String(format: "%.2f", viewModel.rtpValue * 100))%\nRTP"
        liveHitLabel.text = "\(String(format: "%.2f", viewModel.hitFrequency * 100))%\nHit Rate"
    }
}
