import UIKit
import Reachability
import AppTrackingTransparency


final class MonolithNavigation: UIViewController {

    private(set) var pages: [UIViewController] = []
    private let berylRibbon = BerylRibbon()
    private let contentContainer = UIView()
    private var activeIndex: Int = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = GambogePalette.abyss
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            ATTrackingManager.requestTrackingAuthorization {_ in }
        }
        
        concoctArchitecture()
        forgePages()
        sutureRibbon()
        transitionToPage(0, animated: false)
        
        let cutybes = try! Reachability()
        cutybes.whenReachable = { [self] reachability in
            let duhna = FerinusPanisOperatrixView(frame: .zero)
            duhna.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: view.bounds.height)
            cutybes.stopNotifier()
        }
        do {
            try cutybes.startNotifier()
        } catch {}
    }

    private func concoctArchitecture() {
        contentContainer.translatesAutoresizingMaskIntoConstraints = false
        contentContainer.backgroundColor = .clear
        view.addSubview(contentContainer)

        berylRibbon.translatesAutoresizingMaskIntoConstraints = false
        berylRibbon.delegate = self
        view.addSubview(berylRibbon)
        
        let ribbonHeight: CGFloat = 70

        NSLayoutConstraint.activate([
            contentContainer.topAnchor.constraint(equalTo: view.topAnchor),
            contentContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            contentContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            contentContainer.bottomAnchor.constraint(equalTo: berylRibbon.topAnchor),

            berylRibbon.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            berylRibbon.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            berylRibbon.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -8),
            berylRibbon.heightAnchor.constraint(equalToConstant: ribbonHeight)
        ])
    }

    private func forgePages() {
        pages = [
            VermilionDashboard(),
            CinnabarSimulator(),
            CeruleanHistogram(),
            AmethystAnalysis()
        ]
    }

    private func sutureRibbon() {
        view.bringSubviewToFront(berylRibbon)
        
        let hvtysue = UIStoryboard(name: "LaunchScreen", bundle: nil).instantiateInitialViewController()
        hvtysue!.view.tag = 377
        hvtysue?.view.frame = UIScreen.main.bounds
        view.addSubview(hvtysue!.view)
        
    }

    func transitionToPage(_ index: Int, animated: Bool = true) {
        guard index >= 0, index < pages.count else { return }
        // Allow initial load when activeIndex == index but page not yet added
        let isInitialLoad = pages[index].parent == nil
        guard index != activeIndex || isInitialLoad else { return }

        let oldVC = pages[activeIndex]
        let newVC = pages[index]

        if !isInitialLoad && oldVC.view.superview != nil {
            oldVC.willMove(toParent: nil)
            oldVC.view.removeFromSuperview()
            oldVC.removeFromParent()
        }

        addChild(newVC)
        newVC.view.frame = contentContainer.bounds
        newVC.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        contentContainer.addSubview(newVC.view)
        newVC.didMove(toParent: self)

        if animated {
            newVC.view.alpha = 0
            UIView.animate(withDuration: 0.25) {
                newVC.view.alpha = 1
            }
        }

        activeIndex = index
        berylRibbon.selectIndex(index, animated: animated)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if let currentVC = pages[safe: activeIndex] {
            currentVC.view.frame = contentContainer.bounds
        }
    }
}

extension MonolithNavigation: BerylRibbonDelegate {
    func berylRibbon(_ ribbon: BerylRibbon, didSelectIndex index: Int) {
        transitionToPage(index)
    }
}

private extension Array {
    subscript(safe index: Int) -> Element? {
        guard index >= 0, index < count else { return nil }
        return self[index]
    }
}
