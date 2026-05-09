import UIKit

final class CobaltCard: UIView {

    private let monikerLabel = UILabel()
    private let valueLabel = UILabel()
    private let ornamentIcon = UIImageView()
    private let shimmerLayer = CAGradientLayer()

    override init(frame: CGRect) {
        super.init(frame: frame)
        brewSubviews()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) not implemented") }

    private func brewSubviews() {
        backgroundColor = GambogePalette.midnightSlate
        enshroud(with: 18)
        strokeBorder(color: GambogePalette.twilightPlume, width: 1)

        ornamentIcon.contentMode = .scaleAspectFit
        ornamentIcon.tintColor = GambogePalette.neonCyan
        ornamentIcon.translatesAutoresizingMaskIntoConstraints = false
        addSubview(ornamentIcon)

        monikerLabel.font = CinnabarTypography.slateModestRegular()
        monikerLabel.textColor = GambogePalette.slateMist
        monikerLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(monikerLabel)

        valueLabel.font = CinnabarTypography.monospacedDigit(CinnabarTypography.VolumetricSize.vast)
        valueLabel.textColor = .white
        valueLabel.adjustsFontSizeToFitWidth = true
        valueLabel.minimumScaleFactor = 0.6
        valueLabel.allowsDefaultTighteningForTruncation = true
        valueLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(valueLabel)

        NSLayoutConstraint.activate([
            ornamentIcon.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            ornamentIcon.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            ornamentIcon.widthAnchor.constraint(equalToConstant: 22),
            ornamentIcon.heightAnchor.constraint(equalToConstant: 22),

            monikerLabel.topAnchor.constraint(equalTo: ornamentIcon.bottomAnchor, constant: 12),
            monikerLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            monikerLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),

            valueLabel.topAnchor.constraint(equalTo: monikerLabel.bottomAnchor, constant: 4),
            valueLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            valueLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
            valueLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16)
        ])
    }

    func configure(moniker: String, value: String, icon: String, tint: UIColor = GambogePalette.neonCyan) {
        monikerLabel.text = moniker
        valueLabel.text = value
        ornamentIcon.image = UIImage(systemName: icon)
        ornamentIcon.tintColor = tint
        valueLabel.textColor = tint
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        shimmerLayer.frame = bounds
    }
}

final class TopazBadge: UIView {

    private let badgeLabel = UILabel()

    enum BadgeStyle {
        case aurora, ember, verdant, crimson
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        enshroud(with: 10)
        badgeLabel.font = CinnabarTypography.slatePetiteMedium()
        badgeLabel.textColor = .white
        badgeLabel.textAlignment = .center
        badgeLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(badgeLabel)
        NSLayoutConstraint.activate([
            badgeLabel.topAnchor.constraint(equalTo: topAnchor, constant: 4),
            badgeLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -4),
            badgeLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            badgeLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10)
        ])
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) not implemented") }

    func configure(text: String, style: BadgeStyle) {
        badgeLabel.text = text
        switch style {
        case .aurora:
            backgroundColor = GambogePalette.auroraViolet.withAlphaComponent(0.25)
            badgeLabel.textColor = GambogePalette.auroraViolet.lighter()
        case .ember:
            backgroundColor = GambogePalette.emberGold.withAlphaComponent(0.25)
            badgeLabel.textColor = GambogePalette.emberGold.lighter()
        case .verdant:
            backgroundColor = GambogePalette.verdantTeal.withAlphaComponent(0.25)
            badgeLabel.textColor = GambogePalette.verdantTeal.lighter()
        case .crimson:
            backgroundColor = GambogePalette.crimsonFlare.withAlphaComponent(0.25)
            badgeLabel.textColor = GambogePalette.crimsonFlare.lighter()
        }
    }
}

private extension UIColor {
    func lighter() -> UIColor {
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        getRed(&r, green: &g, blue: &b, alpha: &a)
        return UIColor(red: min(r + 0.2, 1), green: min(g + 0.2, 1), blue: min(b + 0.2, 1), alpha: a)
    }
}
