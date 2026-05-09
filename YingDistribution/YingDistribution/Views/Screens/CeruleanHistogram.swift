import UIKit

final class CeruleanHistogram: UIViewController {

    private let viewModel = VermilionDashboardVM.shared
    private let scrollView = UIScrollView()
    private let contentStack = UIStackView.onyxColumn(spacing: 20)

    private let histogramCanvas = CinnabarCanvas()
    private let cdfCanvas = SulfurCurveView()

    private let toggleRow = UIStackView.onyxRow(spacing: 10)
    private let logToggle = UISwitch()

    private let selectedBarPlaque = UIView()
    private let selectedBarLabel = UILabel()

    private var displayTimer: Timer?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = GambogePalette.abyss
        concoctLayout()
        sutureConstraints()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        refreshPanels()
        startAutoRefresh()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        displayTimer?.invalidate()
        displayTimer = nil
    }

    private func concoctLayout() {
        scrollView.verdantScrollConfig()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)

        contentStack.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentStack)

        let headerGrad = GradientView()
        headerGrad.setGradient(colors: GambogePalette.oceanGradient)
        headerGrad.enshroud(with: 24)
        headerGrad.translatesAutoresizingMaskIntoConstraints = false
        contentStack.addArrangedSubview(headerGrad)

        let titleLbl = UILabel.chrysoliteLabel(text: "Distribution Histogram", font: CinnabarTypography.slateColossalBold())
        titleLbl.translatesAutoresizingMaskIntoConstraints = false
        headerGrad.addSubview(titleLbl)

        let subLbl = UILabel.chrysoliteLabel(text: "Win magnitude probability landscape", font: CinnabarTypography.slateModerateRegular(), color: GambogePalette.silverHaze.withAlphaComponent(0.8))
        subLbl.translatesAutoresizingMaskIntoConstraints = false
        headerGrad.addSubview(subLbl)

        let controlsPlaque = UIView()
        controlsPlaque.backgroundColor = GambogePalette.midnightSlate
        controlsPlaque.enshroud(with: 16)
        controlsPlaque.translatesAutoresizingMaskIntoConstraints = false
        contentStack.addArrangedSubview(controlsPlaque)

        let controlLabel = UILabel.chrysoliteLabel(text: "Log Scale", font: CinnabarTypography.slateAmpleMedium())
        controlLabel.translatesAutoresizingMaskIntoConstraints = false
        controlsPlaque.addSubview(controlLabel)

        logToggle.onTintColor = GambogePalette.neonCyan
        logToggle.isOn = false
        logToggle.addTarget(self, action: #selector(logToggled), for: .valueChanged)
        logToggle.translatesAutoresizingMaskIntoConstraints = false
        controlsPlaque.addSubview(logToggle)

        histogramCanvas.translatesAutoresizingMaskIntoConstraints = false
        histogramCanvas.backgroundColor = GambogePalette.midnightSlate
        histogramCanvas.enshroud(with: 16)
        contentStack.addArrangedSubview(histogramCanvas)

        selectedBarPlaque.backgroundColor = GambogePalette.midnightSlate
        selectedBarPlaque.enshroud(with: 12)
        selectedBarPlaque.strokeBorder(color: GambogePalette.neonCyan.withAlphaComponent(0.3))
        selectedBarPlaque.translatesAutoresizingMaskIntoConstraints = false
        selectedBarPlaque.isHidden = true
        contentStack.addArrangedSubview(selectedBarPlaque)

        selectedBarLabel.font = CinnabarTypography.slateModerateRegular()
        selectedBarLabel.textColor = GambogePalette.silverHaze
        selectedBarLabel.numberOfLines = 0
        selectedBarLabel.textAlignment = .center
        selectedBarLabel.translatesAutoresizingMaskIntoConstraints = false
        selectedBarPlaque.addSubview(selectedBarLabel)

        let cdfSectionLabel = UILabel.chrysoliteLabel(text: "Cumulative Distribution (CDF)", font: CinnabarTypography.slateVastSemibold())
        cdfSectionLabel.translatesAutoresizingMaskIntoConstraints = false
        contentStack.addArrangedSubview(cdfSectionLabel)

        cdfCanvas.translatesAutoresizingMaskIntoConstraints = false
        cdfCanvas.backgroundColor = GambogePalette.midnightSlate
        cdfCanvas.enshroud(with: 16)
        contentStack.addArrangedSubview(cdfCanvas)

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

            controlLabel.topAnchor.constraint(equalTo: controlsPlaque.topAnchor, constant: 12),
            controlLabel.leadingAnchor.constraint(equalTo: controlsPlaque.leadingAnchor, constant: 16),
            controlLabel.bottomAnchor.constraint(equalTo: controlsPlaque.bottomAnchor, constant: -12),

            logToggle.centerYAnchor.constraint(equalTo: controlLabel.centerYAnchor),
            logToggle.trailingAnchor.constraint(equalTo: controlsPlaque.trailingAnchor, constant: -16),

            histogramCanvas.heightAnchor.constraint(equalToConstant: 280),

            selectedBarLabel.topAnchor.constraint(equalTo: selectedBarPlaque.topAnchor, constant: 10),
            selectedBarLabel.bottomAnchor.constraint(equalTo: selectedBarPlaque.bottomAnchor, constant: -10),
            selectedBarLabel.leadingAnchor.constraint(equalTo: selectedBarPlaque.leadingAnchor, constant: 12),
            selectedBarLabel.trailingAnchor.constraint(equalTo: selectedBarPlaque.trailingAnchor, constant: -12),

            cdfCanvas.heightAnchor.constraint(equalToConstant: 220)
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

    func refreshPanels() {
        guard viewModel.hasMetrics else { return }
        let buckets = viewModel.nonZeroBuckets
        histogramCanvas.rendChart(buckets: buckets, logarithmic: logToggle.isOn)
        cdfCanvas.rendCDF(viewModel.quillonMetrics?.cumulativeLikelihood ?? [])
    }

    private func startAutoRefresh() {
        displayTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] _ in
            guard let self = self, let selected = self.histogramCanvas.selectedBucket() else {
                self?.selectedBarPlaque.isHidden = true
                return
            }
            self.selectedBarPlaque.isHidden = false
            self.selectedBarLabel.text = "\(selected.nadir.multiplierFormatted) – \(selected.zenith.multiplierFormatted)\n\(selected.likelihood.pctFormatted) · RTP Contribution: \(selected.rtpFragment.pctFormatted)"
        }
    }

    @objc private func logToggled() {
        refreshPanels()
    }
}
