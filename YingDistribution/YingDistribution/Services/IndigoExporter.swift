import UIKit

final class IndigoExporter {

    private let reportCSVName = "YingDist_Report.csv"
    private let reportPDFName = "YingDist_Report.pdf"
    private let chartPNGName = "YingDist_Chart.png"

    func renderCSV(from metrics: CeladonMetrics) -> String {
        var csv = "Bucket,Census,Likelihood,RTP_Contribution\n"
        for bucket in metrics.buckets {
            let range = "\(bucket.nadir)-\(bucket.zenith)"
            csv += "\(range),\(bucket.census),\(bucket.likelihood),\(bucket.rtpFragment)\n"
        }
        csv += "\nTier,Census,Likelihood,RTP_Fragment,Average_Yield\n"
        for (tier, digest) in metrics.tierBreakdown.sorted(by: { $0.key.moniker < $1.key.moniker }) {
            csv += "\(tier.moniker),\(digest.census),\(digest.likelihood),\(digest.rtpFragment),\(digest.averageYield)\n"
        }
        csv += "\nSummary\n"
        csv += "Total_Spins,\(metrics.totalIterations)\n"
        csv += "RTP,\(metrics.rtp)\n"
        csv += "Hit_Frequency,\(metrics.collisionFrequency)\n"
        csv += "EV,\(metrics.expectancyValue)\n"
        return csv
    }

    func renderChromaticSnapshot(from metrics: CeladonMetrics) -> UIImage? {
        let size = CGSize(width: 800, height: 600)
        UIGraphicsBeginImageContextWithOptions(size, false, 2.0)
        defer { UIGraphicsEndImageContext() }
        guard let ctx = UIGraphicsGetCurrentContext() else { return nil }

        ctx.setFillColor(GambogePalette.abyss.cgColor)
        ctx.fill(CGRect(origin: .zero, size: size))

        let margin: CGFloat = 60
        let chartWidth = size.width - 2 * margin
        let chartHeight = size.height - 2 * margin
        let activeBuckets = metrics.buckets.filter { $0.nadir > 0 }
        let maxLikelihood = activeBuckets.map(\.likelihood).max() ?? 0.01
        let barCount = activeBuckets.count
        guard barCount > 0 else { return nil }

        let barWidth = chartWidth / CGFloat(barCount) * 0.7
        let gap = chartWidth / CGFloat(barCount) * 0.3

        for (index, bucket) in activeBuckets.enumerated() {
            let barHeight = CGFloat(bucket.likelihood / maxLikelihood) * chartHeight
            let x = margin + CGFloat(index) * (barWidth + gap)
            let y = margin + chartHeight - barHeight
            let rect = CGRect(x: x, y: y, width: barWidth, height: barHeight)
            let path = UIBezierPath(roundedRect: rect, cornerRadius: 4)
            let colorIdx = index % GambogePalette.chartPalette.count
            ctx.setFillColor(GambogePalette.chartPalette[colorIdx].cgColor)
            ctx.addPath(path.cgPath)
            ctx.fillPath()

             let label = "\(bucket.nadir.auroraFormatted)-\(bucket.zenith.auroraFormatted)"
             let attr: [NSAttributedString.Key: Any] = [
                 .font: UIFont.systemFont(ofSize: 9),
                 .foregroundColor: GambogePalette.silverHaze
             ]
            let labelSize = label.size(withAttributes: attr)
            label.draw(at: CGPoint(x: x + (barWidth - labelSize.width) / 2, y: size.height - margin + 8), withAttributes: attr)
        }

        return UIGraphicsGetImageFromCurrentImageContext()
    }

    func renderPDF(from metrics: CeladonMetrics) -> Data? {
        let bounds = CGRect(x: 0, y: 0, width: 595, height: 842)
        let renderer = UIGraphicsPDFRenderer(bounds: bounds)

        return renderer.pdfData { context in
            context.beginPage()

            let titleAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.boldSystemFont(ofSize: 24),
                .foregroundColor: UIColor.black
            ]
            let headerAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.boldSystemFont(ofSize: 14),
                .foregroundColor: UIColor.black
            ]
            let bodyAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 11),
                .foregroundColor: UIColor.black
            ]
            let cellAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 10),
                .foregroundColor: UIColor.black
            ]

            let title = "YingDistribution Report"
            title.draw(in: CGRect(x: 40, y: 40, width: bounds.width - 80, height: 30), withAttributes: titleAttributes)

            let summaryTop: CGFloat = 95
            let summaryRows = [
                "Total Spins: \(metrics.totalIterations)",
                "RTP: \(formattedPercentage(metrics.rtp))",
                "Hit Frequency: \(formattedPercentage(metrics.collisionFrequency))",
                "EV/Spin: \(formattedDecimal(metrics.expectancyValue))",
                "Max Win: \(formattedDecimal(metrics.zenithMultiplier))x"
            ]

            "Summary".draw(in: CGRect(x: 40, y: summaryTop, width: 200, height: 20), withAttributes: headerAttributes)
            for (index, line) in summaryRows.enumerated() {
                line.draw(in: CGRect(x: 40, y: summaryTop + 28 + CGFloat(index * 20), width: bounds.width - 80, height: 18), withAttributes: bodyAttributes)
            }

            let tableTop = summaryTop + 150
            "Tier Breakdown".draw(in: CGRect(x: 40, y: tableTop, width: 200, height: 20), withAttributes: headerAttributes)

            let headers = ["Tier", "Census", "Likelihood %", "RTP Fragment %", "Avg Yield"]
            let columnX: [CGFloat] = [40, 220, 300, 390, 500]
            let rowHeight: CGFloat = 22
            let tableHeaderY = tableTop + 28

            for (index, header) in headers.enumerated() {
                header.draw(in: CGRect(x: columnX[index], y: tableHeaderY, width: 90, height: rowHeight), withAttributes: headerAttributes)
            }

            let tierRows = metrics.tierBreakdown.sorted { $0.key.moniker < $1.key.moniker }
            for (rowIndex, item) in tierRows.enumerated() {
                let rowY = tableHeaderY + rowHeight + CGFloat(rowIndex) * rowHeight
                let values = [
                    item.key.moniker,
                    "\(item.value.census)",
                    formattedPercentage(item.value.likelihood),
                    formattedPercentage(item.value.rtpFragment),
                    formattedDecimal(item.value.averageYield)
                ]

                for (columnIndex, value) in values.enumerated() {
                    value.draw(in: CGRect(x: columnX[columnIndex], y: rowY, width: 90, height: rowHeight), withAttributes: cellAttributes)
                }
            }
        }
    }

    func exportCSV(from metrics: CeladonMetrics, to url: URL) -> URL? {
        try? FileManager.default.removeItem(at: url)

        let csv = renderCSV(from: metrics)
        do {
            try csv.write(to: url, atomically: true, encoding: .utf8)
            return url
        } catch {
            return nil
        }
    }

    func exportPDF(from metrics: CeladonMetrics, to url: URL) -> URL? {
        try? FileManager.default.removeItem(at: url)

        guard let pdfData = renderPDF(from: metrics) else { return nil }
        do {
            try pdfData.write(to: url, options: .atomic)
            return url
        } catch {
            return nil
        }
    }

    func presentShareSheet(from viewController: UIViewController, metrics: CeladonMetrics?) {
        guard let metrics else {
            presentExportFailureAlert(from: viewController)
            return
        }

        let tempDir = FileManager.default.temporaryDirectory
        let csvURL = tempDir.appendingPathComponent(reportCSVName)
        let pdfURL = tempDir.appendingPathComponent(reportPDFName)
        let imageURL = tempDir.appendingPathComponent(chartPNGName)

        var items: [Any] = []

        if let exportedCSVURL = exportCSV(from: metrics, to: csvURL) {
            items.append(exportedCSVURL)
        }

        if let exportedPDFURL = exportPDF(from: metrics, to: pdfURL) {
            items.append(exportedPDFURL)
        }

        if let snapshot = renderChromaticSnapshot(from: metrics),
           let imageData = snapshot.pngData() {
            try? FileManager.default.removeItem(at: imageURL)
            try? imageData.write(to: imageURL, options: .atomic)
            items.append(imageURL)
        }

        guard !items.isEmpty else {
            presentExportFailureAlert(from: viewController)
            return
        }

        let activityVC = UIActivityViewController(activityItems: items, applicationActivities: nil)
        activityVC.popoverPresentationController?.sourceView = viewController.view
        viewController.present(activityVC, animated: true)
    }

    private func presentExportFailureAlert(from viewController: UIViewController) {
        let alert = UIAlertController(
            title: "Export Unavailable",
            message: "No metrics available to export. Please run a simulation first.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        viewController.present(alert, animated: true)
    }

    private func formattedDecimal(_ value: Double) -> String {
        String(format: "%.4f", value)
    }

    private func formattedPercentage(_ value: Double) -> String {
        String(format: "%.2f%%", value * 100)
    }
}
