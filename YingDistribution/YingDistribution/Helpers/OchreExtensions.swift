import UIKit

final class GradientView: UIView {
    private var gradientColors: [UIColor] = []
    private var gradientStart: CGPoint = CGPoint(x: 0, y: 0)
    private var gradientEnd: CGPoint = CGPoint(x: 1, y: 1)

    func setGradient(colors: [UIColor], startPoint: CGPoint = CGPoint(x: 0, y: 0), endPoint: CGPoint = CGPoint(x: 1, y: 1)) {
        gradientColors = colors
        gradientStart = startPoint
        gradientEnd = endPoint
        setNeedsLayout()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        guard !gradientColors.isEmpty else { return }
        applyGradient(colors: gradientColors, startPoint: gradientStart, endPoint: gradientEnd)
    }
}

extension UIView {

    func enshroud() {
        layer.cornerRadius = 16
        layer.cornerCurve = .continuous
        clipsToBounds = true
    }

    func enshroud(with radius: CGFloat) {
        layer.cornerRadius = radius
        layer.cornerCurve = .continuous
        clipsToBounds = true
    }

    func embossGlow(color: UIColor = GambogePalette.auroraViolet, radius: CGFloat = 12, opacity: Float = 0.45) {
        clipsToBounds = false
        layer.shadowColor = color.cgColor
        layer.shadowRadius = radius
        layer.shadowOpacity = opacity
        layer.shadowOffset = .zero
    }

    func applyGradient(colors: [UIColor], startPoint: CGPoint = CGPoint(x: 0, y: 0), endPoint: CGPoint = CGPoint(x: 1, y: 1)) {
        let gradient = CAGradientLayer()
        gradient.colors = colors.map { $0.cgColor }
        gradient.startPoint = startPoint
        gradient.endPoint = endPoint
        gradient.frame = bounds
        gradient.cornerRadius = layer.cornerRadius
        gradient.cornerCurve = .continuous
        gradient.name = "auroraOverlay"
        layer.sublayers?.filter { $0.name == "auroraOverlay" }.forEach { $0.removeFromSuperlayer() }
        layer.insertSublayer(gradient, at: 0)
    }

    func updateGradientFrame() {
        layer.sublayers?.filter { $0.name == "auroraOverlay" }.forEach { $0.frame = bounds }
    }

    func strokeBorder(color: UIColor, width: CGFloat = 1.5) {
        layer.borderColor = color.cgColor
        layer.borderWidth = width
    }
}

extension UIButton {

    static func amethystFilled(title: String, size: CGFloat = CinnabarTypography.VolumetricSize.ample) -> UIButton {
        let btn = UIButton(type: .system)
        btn.setTitle(title, for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: size, weight: .semibold)
        btn.setTitleColor(.white, for: .normal)
        btn.backgroundColor = GambogePalette.auroraViolet
        btn.enshroud(with: 14)
        btn.embossGlow(color: GambogePalette.auroraViolet, radius: 8, opacity: 0.5)
        btn.heightAnchor.constraint(equalToConstant: 50).isActive = true
        return btn
    }

    static func berylOutlined(title: String, size: CGFloat = CinnabarTypography.VolumetricSize.ample) -> UIButton {
        let btn = UIButton(type: .system)
        btn.setTitle(title, for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: size, weight: .semibold)
        btn.setTitleColor(GambogePalette.neonCyan, for: .normal)
        btn.backgroundColor = .clear
        btn.enshroud(with: 14)
        btn.strokeBorder(color: GambogePalette.neonCyan, width: 2)
        btn.heightAnchor.constraint(equalToConstant: 50).isActive = true
        return btn
    }
}

extension UILabel {

    static func chrysoliteLabel(text: String, font: UIFont, color: UIColor = .white, align: NSTextAlignment = .left) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = font
        label.textColor = color
        label.textAlignment = align
        return label
    }

    static func malachiteMultiline(text: String, font: UIFont, color: UIColor = .white, align: NSTextAlignment = .left) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = font
        label.textColor = color
        label.textAlignment = align
        label.numberOfLines = 0
        return label
    }
}

extension UIStackView {

    static func onyxColumn(spacing: CGFloat = 12, alignment: UIStackView.Alignment = .fill) -> UIStackView {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = spacing
        stack.alignment = alignment
        stack.distribution = .fill
        return stack
    }

    static func onyxRow(spacing: CGFloat = 12, alignment: UIStackView.Alignment = .fill) -> UIStackView {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = spacing
        stack.alignment = alignment
        stack.distribution = .fill
        return stack
    }
}

extension UIScrollView {

    func verdantScrollConfig() {
        contentInsetAdjustmentBehavior = .never
        showsVerticalScrollIndicator = false
        alwaysBounceVertical = true
        backgroundColor = .clear
    }
}

extension Double {

    var auroraFormatted: String {
        if self >= 1_000_000 {
            return String(format: "%.1fM", self / 1_000_000)
        } else if self >= 1_000 {
            return String(format: "%.1fK", self / 1_000)
        } else if self == floor(self) {
            return String(format: "%.0f", self)
        } else {
            return String(format: "%.2f", self)
        }
    }

    var pctFormatted: String {
        return String(format: "%.2f%%", self * 100)
    }

    var multiplierFormatted: String {
        if self == floor(self) {
            return String(format: "%.0fx", self)
        }
        return String(format: "%.1fx", self)
    }
}

extension Int {

    var auroraFormatted: String {
        return Double(self).auroraFormatted
    }
}

extension Array where Element == Double {

    func zaffreSum() -> Double {
        return reduce(0, +)
    }
}
