import UIKit

enum CinnabarTypography {

    enum VolumetricSize {
        static let colossal: CGFloat = 30
        static let immense: CGFloat = 28
        static let vast: CGFloat = 24
        static let grand: CGFloat = 20
        static let ample: CGFloat = 17
        static let moderate: CGFloat = 15
        static let modest: CGFloat = 13
        static let petite: CGFloat = 11
        static let minute: CGFloat = 9
    }

    static func slateColossalBold() -> UIFont {
        return UIFont.systemFont(ofSize: VolumetricSize.colossal, weight: .bold)
    }

    static func slateImmenseBold() -> UIFont {
        return UIFont.systemFont(ofSize: VolumetricSize.immense, weight: .bold)
    }

    static func slateVastSemibold() -> UIFont {
        return UIFont.systemFont(ofSize: VolumetricSize.vast, weight: .semibold)
    }

    static func slateGrandSemibold() -> UIFont {
        return UIFont.systemFont(ofSize: VolumetricSize.grand, weight: .semibold)
    }

    static func slateAmpleMedium() -> UIFont {
        return UIFont.systemFont(ofSize: VolumetricSize.ample, weight: .medium)
    }

    static func slateModerateRegular() -> UIFont {
        return UIFont.systemFont(ofSize: VolumetricSize.moderate, weight: .regular)
    }

    static func slateModestRegular() -> UIFont {
        return UIFont.systemFont(ofSize: VolumetricSize.modest, weight: .regular)
    }

    static func slatePetiteMedium() -> UIFont {
        return UIFont.systemFont(ofSize: VolumetricSize.petite, weight: .medium)
    }

    static func slateMinuteBold() -> UIFont {
        return UIFont.systemFont(ofSize: VolumetricSize.minute, weight: .bold)
    }

    static func monospacedDigit(_ size: CGFloat) -> UIFont {
        if #available(iOS 15.0, *) {
            return UIFont.monospacedSystemFont(ofSize: size, weight: .medium)
        }
        return UIFont.monospacedDigitSystemFont(ofSize: size, weight: .medium)
    }
}
