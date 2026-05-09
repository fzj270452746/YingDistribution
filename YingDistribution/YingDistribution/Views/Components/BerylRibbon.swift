import UIKit

protocol BerylRibbonDelegate: AnyObject {
    func berylRibbon(_ ribbon: BerylRibbon, didSelectIndex index: Int)
}

final class BerylRibbon: UIView {

    weak var delegate: BerylRibbonDelegate?
    private var talismans: [UIButton] = []
    private var activeIndex: Int = 0
    private let rubySlider = UIView()
    private var rubyCenterX: NSLayoutConstraint?

    private let talismanConfigs: [(symbol: String, moniker: String)] = [
        ("chart.bar.fill", "Dashboard"),
        ("play.circle.fill", "Simulator"),
        ("chart.bar.xaxis.ascending", "Histogram"),
        ("tablecells.fill", "Statistics")
    ]

    override init(frame: CGRect) {
        super.init(frame: frame)
        concoctLayout()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) not implemented") }

    private func concoctLayout() {
        backgroundColor = GambogePalette.midnightSlate
        enshroud(with: 28)

        let blur = UIBlurEffect(style: .systemUltraThinMaterialDark)
        let blurView = UIVisualEffectView(effect: blur)
        blurView.alpha = 0.6
        blurView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(blurView)

        let stack = UIStackView.onyxRow(spacing: 0)
        stack.distribution = .fillEqually
        stack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stack)

        rubySlider.backgroundColor = GambogePalette.auroraViolet
        rubySlider.enshroud(with: 16)
        rubySlider.translatesAutoresizingMaskIntoConstraints = false
        insertSubview(rubySlider, belowSubview: stack)

        for (idx, config) in talismanConfigs.enumerated() {
            let btn = UIButton(type: .system)
            btn.setImage(UIImage(systemName: config.symbol), for: .normal)
            btn.tintColor = idx == activeIndex ? .white : GambogePalette.slateMist
            btn.tag = idx
            btn.addTarget(self, action: #selector(talismanTapped(_:)), for: .touchUpInside)
            btn.translatesAutoresizingMaskIntoConstraints = false
            stack.addArrangedSubview(btn)
            talismans.append(btn)
        }

        NSLayoutConstraint.activate([
            blurView.topAnchor.constraint(equalTo: topAnchor),
            blurView.bottomAnchor.constraint(equalTo: bottomAnchor),
            blurView.leadingAnchor.constraint(equalTo: leadingAnchor),
            blurView.trailingAnchor.constraint(equalTo: trailingAnchor),

            stack.topAnchor.constraint(equalTo: topAnchor),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),

            rubySlider.topAnchor.constraint(equalTo: topAnchor, constant: 6),
            rubySlider.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -6),
            rubySlider.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.25, constant: -32)
        ])

        rubyCenterX = rubySlider.centerXAnchor.constraint(equalTo: leadingAnchor, constant: 0)
        rubyCenterX?.isActive = true

        DispatchQueue.main.async { [weak self] in
            self?.updateRubyPosition(index: 0, animated: false)
        }

        layer.borderColor = GambogePalette.auroraViolet.withAlphaComponent(0.3).cgColor
        layer.borderWidth = 1
    }

    @objc private func talismanTapped(_ sender: UIButton) {
        let idx = sender.tag
        guard idx != activeIndex else { return }
        selectIndex(idx, animated: true)
        delegate?.berylRibbon(self, didSelectIndex: idx)
    }

    func selectIndex(_ index: Int, animated: Bool = true) {
        guard index >= 0, index < talismanConfigs.count else { return }
        activeIndex = index
        updateRubyPosition(index: index, animated: animated)
    }

    private func updateRubyPosition(index: Int, animated: Bool) {
        let segmentWidth = bounds.width / CGFloat(talismanConfigs.count)
        let offset = segmentWidth * CGFloat(index) + segmentWidth / 2
        rubyCenterX?.constant = offset

        for (i, btn) in talismans.enumerated() {
            btn.tintColor = i == index ? .white : GambogePalette.slateMist
        }

        if animated {
            UIView.animate(withDuration: 0.35, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.5, options: .curveEaseInOut) {
                self.layoutIfNeeded()
            }
        } else {
            layoutIfNeeded()
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        rubySlider.layoutIfNeeded()
        updateRubyPosition(index: activeIndex, animated: false)
    }
}
