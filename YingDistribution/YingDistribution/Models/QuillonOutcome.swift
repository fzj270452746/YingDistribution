import Foundation

struct QuillonOutcome {
    let identifier: UUID
    let yieldMultiplier: Double
    let lineIndex: Int
    let scatterCode: Int

    init(yieldMultiplier: Double, lineIndex: Int = 0, scatterCode: Int = 0) {
        self.identifier = UUID()
        self.yieldMultiplier = yieldMultiplier
        self.lineIndex = lineIndex
        self.scatterCode = scatterCode
    }

    var isLacuna: Bool {
        return yieldMultiplier == 0
    }

    var isColossalWin: Bool {
        return yieldMultiplier >= 50
    }
}

extension QuillonOutcome: Equatable {
    static func == (lhs: QuillonOutcome, rhs: QuillonOutcome) -> Bool {
        return lhs.identifier == rhs.identifier
    }
}

extension QuillonOutcome: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(identifier)
    }
}
