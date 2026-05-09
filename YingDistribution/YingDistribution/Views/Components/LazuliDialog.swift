import UIKit

final class LazuliDialog: UIView {

    enum Demeanor {
        case herald
        case admonition
        case flourish
        case inquiry
    }

    private let curtainView = UIView()
    private let plaqueView = UIView()
    private let titleLabel = UILabel()
    private let bodyLabel = UILabel()
    private var actionClosures: [() -> Void] = []

    static func manifest(
        in parent: UIViewController,
        demeanor: Demeanor = .herald,
        title: String,
        body: String,
        primaryLabel: String = "Confirm",
        secondaryLabel: String? = nil,
        primaryAction: @escaping () -> Void = {},
        secondaryAction: (() -> Void)? = nil
    ) {
        let dialog = LazuliDialog(frame: .zero)
        dialog.translatesAutoresizingMaskIntoConstraints = false
        dialog.concoctContent(demeanor: demeanor, title: title, body: body,
                              primaryLabel: primaryLabel, secondaryLabel: secondaryLabel,
                              primaryAction: primaryAction, secondaryAction: secondaryAction)
        dialog.alpha = 0

        if let windowScene = parent.view.window?.windowScene,
           let window = windowScene.windows.first(where: { $0.isKeyWindow }) {
            window.addSubview(dialog)
            NSLayoutConstraint.activate([
                dialog.topAnchor.constraint(equalTo: window.topAnchor),
                dialog.bottomAnchor.constraint(equalTo: window.bottomAnchor),
                dialog.leadingAnchor.constraint(equalTo: window.leadingAnchor),
                dialog.trailingAnchor.constraint(equalTo: window.trailingAnchor)
            ])
        } else {
            parent.view.addSubview(dialog)
            NSLayoutConstraint.activate([
                dialog.topAnchor.constraint(equalTo: parent.view.topAnchor),
                dialog.bottomAnchor.constraint(equalTo: parent.view.bottomAnchor),
                dialog.leadingAnchor.constraint(equalTo: parent.view.leadingAnchor),
                dialog.trailingAnchor.constraint(equalTo: parent.view.trailingAnchor)
            ])
        }

        dialog.quenchIn()
    }

    private func concoctContent(demeanor: Demeanor, title: String, body: String,
                                 primaryLabel: String, secondaryLabel: String?,
                                 primaryAction: @escaping () -> Void, secondaryAction: (() -> Void)?) {
        curtainView.backgroundColor = UIColor.black.withAlphaComponent(0.65)
        curtainView.translatesAutoresizingMaskIntoConstraints = false
        curtainView.alpha = 0
        addSubview(curtainView)

        plaqueView.backgroundColor = GambogePalette.midnightSlate
        plaqueView.enshroud(with: 24)
        plaqueView.strokeBorder(color: GambogePalette.auroraViolet.withAlphaComponent(0.3))
        plaqueView.embossGlow(color: GambogePalette.auroraViolet, radius: 20, opacity: 0.3)
        plaqueView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(plaqueView)

        let iconView = UIImageView()
        iconView.contentMode = .scaleAspectFit
        iconView.tintColor = demeanorIconColor(demeanor)
        iconView.image = UIImage(systemName: demeanorSymbol(demeanor))
        iconView.translatesAutoresizingMaskIntoConstraints = false
        plaqueView.addSubview(iconView)

        titleLabel.text = title
        titleLabel.font = CinnabarTypography.slateGrandSemibold()
        titleLabel.textColor = .white
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        plaqueView.addSubview(titleLabel)

        bodyLabel.text = body
        bodyLabel.font = CinnabarTypography.slateModerateRegular()
        bodyLabel.textColor = GambogePalette.silverHaze
        bodyLabel.textAlignment = .center
        bodyLabel.numberOfLines = 0
        bodyLabel.translatesAutoresizingMaskIntoConstraints = false
        plaqueView.addSubview(bodyLabel)

        let buttonStack = UIStackView.onyxRow(spacing: 12)
        buttonStack.distribution = .fillEqually
        buttonStack.translatesAutoresizingMaskIntoConstraints = false
        plaqueView.addSubview(buttonStack)

        if let secondaryLabel = secondaryLabel, let secondaryAction = secondaryAction {
            let secondaryBtn = UIButton.berylOutlined(title: secondaryLabel)
            secondaryBtn.addAction(UIAction { [weak self] _ in
                secondaryAction()
                self?.dissolve()
            }, for: .touchUpInside)
            buttonStack.addArrangedSubview(secondaryBtn)
        }

        let primaryBtn = UIButton.amethystFilled(title: primaryLabel)
        primaryBtn.addAction(UIAction { [weak self] _ in
            primaryAction()
            self?.dissolve()
        }, for: .touchUpInside)
        primaryBtn.translatesAutoresizingMaskIntoConstraints = false
        buttonStack.addArrangedSubview(primaryBtn)

        NSLayoutConstraint.activate([
            curtainView.topAnchor.constraint(equalTo: topAnchor),
            curtainView.bottomAnchor.constraint(equalTo: bottomAnchor),
            curtainView.leadingAnchor.constraint(equalTo: leadingAnchor),
            curtainView.trailingAnchor.constraint(equalTo: trailingAnchor),

            plaqueView.centerXAnchor.constraint(equalTo: centerXAnchor),
            plaqueView.centerYAnchor.constraint(equalTo: centerYAnchor),
            plaqueView.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.82),
            plaqueView.heightAnchor.constraint(greaterThanOrEqualToConstant: 220),

            iconView.topAnchor.constraint(equalTo: plaqueView.topAnchor, constant: 24),
            iconView.centerXAnchor.constraint(equalTo: plaqueView.centerXAnchor),
            iconView.widthAnchor.constraint(equalToConstant: 40),
            iconView.heightAnchor.constraint(equalToConstant: 40),

            titleLabel.topAnchor.constraint(equalTo: iconView.bottomAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: plaqueView.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: plaqueView.trailingAnchor, constant: -20),

            bodyLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            bodyLabel.leadingAnchor.constraint(equalTo: plaqueView.leadingAnchor, constant: 20),
            bodyLabel.trailingAnchor.constraint(equalTo: plaqueView.trailingAnchor, constant: -20),

            buttonStack.topAnchor.constraint(equalTo: bodyLabel.bottomAnchor, constant: 24),
            buttonStack.leadingAnchor.constraint(equalTo: plaqueView.leadingAnchor, constant: 20),
            buttonStack.trailingAnchor.constraint(equalTo: plaqueView.trailingAnchor, constant: -20),
            buttonStack.bottomAnchor.constraint(equalTo: plaqueView.bottomAnchor, constant: -20)
        ])
    }

    private func demeanorSymbol(_ demeanor: Demeanor) -> String {
        switch demeanor {
        case .herald: return "sparkles"
        case .admonition: return "exclamationmark.triangle.fill"
        case .flourish: return "checkmark.circle.fill"
        case .inquiry: return "questionmark.circle.fill"
        }
    }

    private func demeanorIconColor(_ demeanor: Demeanor) -> UIColor {
        switch demeanor {
        case .herald: return GambogePalette.neonCyan
        case .admonition: return GambogePalette.flareOrange
        case .flourish: return GambogePalette.verdantTeal
        case .inquiry: return GambogePalette.emberGold
        }
    }

    private func quenchIn() {
        UIView.animate(withDuration: 0.25) {
            self.curtainView.alpha = 1
            self.alpha = 1
        }
        plaqueView.transform = CGAffineTransform(scaleX: 0.85, y: 0.85)
        UIView.animate(withDuration: 0.35, delay: 0.05, usingSpringWithDamping: 0.75, initialSpringVelocity: 0.5, options: .curveEaseOut) {
            self.plaqueView.transform = .identity
        }
    }

    private func dissolve() {
        UIView.animate(withDuration: 0.2, animations: {
            self.curtainView.alpha = 0
            self.plaqueView.alpha = 0
            self.plaqueView.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        }) { _ in
            self.removeFromSuperview()
        }
    }
}
