import UIKit

final class CinnabarCanvas: UIView {

    private var bucketData: [ZirconBucket] = []
    private var curvePoints: [CGPoint] = []
    private var barRects: [CGRect] = []
    private var useLogarithmic: Bool = false
    private var tappedIndex: Int?
    private let haptic = UIImpactFeedbackGenerator(style: .light)

    private let margin: UIEdgeInsets = UIEdgeInsets(top: 20, left: 50, bottom: 40, right: 20)

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        addGestureRecognizer(tap)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) not implemented") }

    func rendChart(buckets: [ZirconBucket], logarithmic: Bool = false) {
        bucketData = buckets.filter { $0.nadir > 0 }
        useLogarithmic = logarithmic
        setNeedsDisplay()
    }

    override func draw(_ rect: CGRect) {
        guard let ctx = UIGraphicsGetCurrentContext(), !bucketData.isEmpty else {
            drawEmptyState(in: rect)
            return
        }

        ctx.setShouldAntialias(true)
        parchGridlines(ctx: ctx, rect: rect)
        parchBars(ctx: ctx, rect: rect)
        parchAxes(ctx: ctx, rect: rect)
    }

    private func parchGridlines(ctx: CGContext, rect: CGRect) {
        let chartW = rect.width - margin.left - margin.right
        let chartH = rect.height - margin.top - margin.bottom
        let gridCount: CGFloat = 5

        for i in 0...Int(gridCount) {
            let y = margin.top + chartH * CGFloat(i) / gridCount
            ctx.setStrokeColor(GambogePalette.twilightPlume.cgColor)
            ctx.setLineWidth(0.5)
            ctx.move(to: CGPoint(x: margin.left, y: y))
            ctx.addLine(to: CGPoint(x: margin.left + chartW, y: y))
            ctx.strokePath()
        }
    }

    private func parchBars(ctx: CGContext, rect: CGRect) {
        let chartW = rect.width - margin.left - margin.right
        let chartH = rect.height - margin.top - margin.bottom
        let maxLikelihood = bucketData.map(\.likelihood).max() ?? 0.01
        let barCount = bucketData.count
        let barWidth = chartW / CGFloat(barCount) * 0.65
        let gap = chartW / CGFloat(barCount) * 0.35

        barRects.removeAll()

        for (index, bucket) in bucketData.enumerated() {
            let value = useLogarithmic ? log10(max(bucket.likelihood * 10000, 0.01)) : bucket.likelihood
            let maxValue = useLogarithmic ? log10(max(maxLikelihood * 10000, 0.01)) : maxLikelihood
            let barHeight = chartH * CGFloat(value / maxValue)

            let x = margin.left + CGFloat(index) * (barWidth + gap)
            let y = margin.top + chartH - barHeight
            let barRect = CGRect(x: x, y: y, width: barWidth, height: barHeight)
            barRects.append(barRect)

            let colorIdx = index % GambogePalette.chartPalette.count
            let isTapped = (tappedIndex == index)
            let color = isTapped ? GambogePalette.chartPalette[colorIdx].withAlphaComponent(1.0)
                                 : GambogePalette.chartPalette[colorIdx].withAlphaComponent(0.85)

            let path = UIBezierPath(roundedRect: barRect, cornerRadius: 4)
            ctx.setFillColor(color.cgColor)
            ctx.addPath(path.cgPath)
            ctx.fillPath()
        }
    }

    private func parchAxes(ctx: CGContext, rect: CGRect) {
        let chartH = rect.height - margin.top - margin.bottom
        let maxLikelihood = bucketData.map(\.likelihood).max() ?? 0.01
        let gridCount: CGFloat = 5

        for i in 0...Int(gridCount) {
            let fraction = CGFloat(gridCount - CGFloat(i)) / gridCount
            let y = margin.top + chartH * (1.0 - CGFloat(i) / gridCount)

            let displayStr: String
            if useLogarithmic {
                let logMax = log10(max(maxLikelihood * 10000, 0.01))
                let logVal = logMax * Double(fraction)
                let linearVal = pow(10, logVal) / 10000
                displayStr = String(format: "%.2f%%", linearVal * 100)
            } else {
                let rawVal = maxLikelihood * Double(fraction)
                displayStr = String(format: "%.1f%%", rawVal * 100)
            }

            let attr: [NSAttributedString.Key: Any] = [
                .font: CinnabarTypography.slateMinuteBold(),
                .foregroundColor: GambogePalette.slateMist
            ]
            let size = displayStr.size(withAttributes: attr)
            displayStr.draw(at: CGPoint(x: margin.left - size.width - 6, y: y - size.height / 2), withAttributes: attr)
        }
    }

    private func drawEmptyState(in rect: CGRect) {
        let attr: [NSAttributedString.Key: Any] = [
            .font: CinnabarTypography.slateModerateRegular(),
            .foregroundColor: GambogePalette.slateMist
        ]
        let msg = "No Distribution Data"
        let size = msg.size(withAttributes: attr)
        msg.draw(at: CGPoint(x: (rect.width - size.width) / 2, y: (rect.height - size.height) / 2), withAttributes: attr)
    }

    @objc private func handleTap(_ tap: UITapGestureRecognizer) {
        let location = tap.location(in: self)
        for (idx, rect) in barRects.enumerated() {
            if rect.contains(location) {
                haptic.impactOccurred()
                tappedIndex = (tappedIndex == idx) ? nil : idx
                setNeedsDisplay()
                return
            }
        }
        tappedIndex = nil
        setNeedsDisplay()
    }

    func selectedBucket() -> ZirconBucket? {
        guard let idx = tappedIndex, idx < bucketData.count else { return nil }
        return bucketData[idx]
    }
}

final class SulfurCurveView: UIView {

    private var cdfValues: [Double] = []
    private let margin: UIEdgeInsets = UIEdgeInsets(top: 20, left: 40, bottom: 40, right: 20)

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) not implemented") }

    func rendCDF(_ values: [Double]) {
        cdfValues = values
        setNeedsDisplay()
    }

    override func draw(_ rect: CGRect) {
        guard let ctx = UIGraphicsGetCurrentContext(), cdfValues.count > 1 else { return }

        let chartW = rect.width - margin.left - margin.right
        let chartH = rect.height - margin.top - margin.bottom

        ctx.setStrokeColor(GambogePalette.neonCyan.cgColor)
        ctx.setLineWidth(2.5)
        ctx.setLineCap(.round)
        ctx.setLineJoin(.round)

        let path = UIBezierPath()
        for (i, val) in cdfValues.enumerated() {
            let x = margin.left + chartW * CGFloat(i) / CGFloat(cdfValues.count - 1)
            let y = margin.top + chartH * CGFloat(1.0 - val)
            let point = CGPoint(x: x, y: y)
            if i == 0 { path.move(to: point) } else { path.addLine(to: point) }
        }

        ctx.addPath(path.cgPath)
        ctx.strokePath()

        let glowPath = UIBezierPath(cgPath: path.cgPath)
        ctx.setStrokeColor(GambogePalette.neonCyan.withAlphaComponent(0.3).cgColor)
        ctx.setLineWidth(6)
        ctx.addPath(glowPath.cgPath)
        ctx.strokePath()

        for i in 0...4 {
            let y = margin.top + chartH * CGFloat(1.0 - Double(i) / 4.0)
            let text = "\(i * 25)%"
            let attr: [NSAttributedString.Key: Any] = [
                .font: CinnabarTypography.slateMinuteBold(),
                .foregroundColor: GambogePalette.slateMist
            ]
            text.draw(at: CGPoint(x: 2, y: y - 8), withAttributes: attr)
        }
    }
}
