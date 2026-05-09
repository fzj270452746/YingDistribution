import UIKit

struct ZirconBucket {
    let nadir: Double
    let zenith: Double
    var census: Int
    var likelihood: Double
    var rtpFragment: Double

    init(nadir: Double, zenith: Double, census: Int = 0, likelihood: Double = 0, rtpFragment: Double = 0) {
        self.nadir = nadir
        self.zenith = zenith
        self.census = census
        self.likelihood = likelihood
        self.rtpFragment = rtpFragment
    }

    var epithet: String {
        if nadir == 0 && zenith == 0 { return "Lacuna" }
        if zenith < 2 { return "Minuscule" }
        if zenith < 5 { return "Paltry" }
        if zenith < 10 { return "Modest" }
        if zenith < 20 { return "Favorable" }
        if zenith < 50 { return "Substantial" }
        return "Colossal"
    }

    var midpoint: Double { (nadir + zenith) / 2.0 }
}

enum CinnabarTier {
    case lacuna
    case minuscule
    case modest
    case favorable
    case substantial
    case colossal

    var moniker: String {
        switch self {
        case .lacuna: return "Lacuna (0x)"
        case .minuscule: return "Minuscule (< 2x)"
        case .modest: return "Modest (2x–10x)"
        case .favorable: return "Favorable (10x–50x)"
        case .substantial: return "Substantial (50x–100x)"
        case .colossal: return "Colossal (100x+)"
        }
    }

    var tint: UIColor {
        switch self {
        case .lacuna: return GambogePalette.slateMist
        case .minuscule: return GambogePalette.neonCyan
        case .modest: return GambogePalette.auroraViolet
        case .favorable: return GambogePalette.emberGold
        case .substantial: return GambogePalette.flareOrange
        case .colossal: return GambogePalette.crimsonFlare
        }
    }

    static func classify(_ multiplier: Double) -> CinnabarTier {
        if multiplier == 0 { return .lacuna }
        if multiplier < 2 { return .minuscule }
        if multiplier < 10 { return .modest }
        if multiplier < 50 { return .favorable }
        if multiplier < 100 { return .substantial }
        return .colossal
    }
}
