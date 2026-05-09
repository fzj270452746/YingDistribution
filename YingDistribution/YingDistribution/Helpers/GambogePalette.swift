import UIKit

enum GambogePalette {
    static let abyss = UIColor(hex: 0x09091A)
    static let voidstone = UIColor(hex: 0x0F0F23)
    static let midnightSlate = UIColor(hex: 0x1A1A34)
    static let twilightPlume = UIColor(hex: 0x252545)
    static let duskVeil = UIColor(hex: 0x2D2D55)

    static let auroraViolet = UIColor(hex: 0x7C3AED)
    static let astralIndigo = UIColor(hex: 0x6366F1)
    static let phantomBlue = UIColor(hex: 0x3B82F6)
    static let neonCyan = UIColor(hex: 0x06B6D4)
    static let verdantTeal = UIColor(hex: 0x10B981)
    static let emeraldSuccess = verdantTeal

    static let emberGold = UIColor(hex: 0xF59E0B)
    static let flareOrange = UIColor(hex: 0xF97316)
    static let crimsonFlare = UIColor(hex: 0xEF4444)
    static let roseQuartz = UIColor(hex: 0xEC4899)
    static let orchidGlow = UIColor(hex: 0xD946EF)

    static let frostWhite = UIColor(hex: 0xF8FAFC)
    static let silverHaze = UIColor(hex: 0xCBD5E1)
    static let slateMist = UIColor(hex: 0x94A3B8)
    static let graphiteDust = UIColor(hex: 0x64748B)
    static let obsidianShade = UIColor(hex: 0x334155)

    static let auroraGradient: [UIColor] = [auroraViolet, astralIndigo, phantomBlue]
    static let emberGradient: [UIColor] = [flareOrange, emberGold, neonCyan]
    static let duskGradient: [UIColor] = [auroraViolet, orchidGlow, roseQuartz]
    static let oceanGradient: [UIColor] = [phantomBlue, neonCyan, verdantTeal]

    static let chartPalette: [UIColor] = [
        neonCyan, auroraViolet, emberGold, roseQuartz,
        verdantTeal, flareOrange, astralIndigo, orchidGlow,
        phantomBlue, crimsonFlare
    ]

    static let tierColors: [UIColor] = [
        neonCyan, auroraViolet, emberGold, crimsonFlare
    ]

    static let shimmerGradient: [UIColor] = [
        UIColor(hex: 0x7C3AED).withAlphaComponent(0.3),
        UIColor(hex: 0x6366F1).withAlphaComponent(0.1),
        UIColor.clear
    ]
}

private extension UIColor {
    convenience init(hex: UInt64) {
        let r = CGFloat((hex & 0xFF0000) >> 16) / 255.0
        let g = CGFloat((hex & 0x00FF00) >> 8) / 255.0
        let b = CGFloat(hex & 0x0000FF) / 255.0
        self.init(red: r, green: g, blue: b, alpha: 1.0)
    }
}
