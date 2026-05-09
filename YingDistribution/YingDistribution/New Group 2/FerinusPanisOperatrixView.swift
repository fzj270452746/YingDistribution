import UIKit

public enum AlimentumGenus: CaseIterable {
    case farina, dulcor, butyrum, sylvestrisPomum, nux
    var titulus: String {
        switch self {
        case .farina: return "Flour"
        case .dulcor: return "Sugar"
        case .butyrum: return "Butter"
        case .sylvestrisPomum: return "Wild Fruit"
        case .nux: return "Nuts"
        }
    }
}

public enum PraeceptumGenus: String, CaseIterable {
    case panisVetus = "Plain Bread"
    case panisDulcis = "Honey Fruit Loaf"
    case panisNucis = "Crunchy Nut Bread"
    case crostataButyri = "Butter Croissant"
    
    var expositio: String {
        switch self {
        case .panisVetus: return "Classic island bread"
        case .panisDulcis: return "Sweet & wild aroma"
        case .panisNucis: return "Earthy crunch delight"
        case .crostataButyri: return "Flaky golden treasure"
        }
    }
    
    var constansPretium: Int {
        switch self {
        case .panisVetus: return 25
        case .panisDulcis: return 45
        case .panisNucis: return 55
        case .crostataButyri: return 70
        }
    }
    
    var requiritSubstantia: [AlimentumGenus: Int] {
        switch self {
        case .panisVetus: return [.farina: 2, .dulcor: 1]
        case .panisDulcis: return [.farina: 2, .sylvestrisPomum: 2, .dulcor: 1]
        case .panisNucis: return [.farina: 2, .nux: 2]
        case .crostataButyri: return [.farina: 1, .butyrum: 2, .dulcor: 1]
        }
    }
}

public struct SociusEntitas {
    let cognomen: String
    let beneficiumFactor: Double
    let afflatusDescriptio: String
}

// MARK: - Game Data Model (RetroSilvaManager)
final class CimrmanianProvisionCustos {
    private var thesaurusMappa: [AlimentumGenus: Int] = [:]
    private var solutaePraeceptiones: Set<PraeceptumGenus> = [.panisVetus]
    private var comites: [SociusEntitas] = []
    private var nummusAureus: Int = 180
    private var vigorVitalis: Int = 100
    
    init() {
        for genus in AlimentumGenus.allCases {
            thesaurusMappa[genus] = 6 + Int.random(in: 0...4)
        }
        // 初始伙伴: 狐旅人菲莉
        comites.append(SociusEntitas(cognomen: "Philomela the Vulpine", beneficiumFactor: 1.15, afflatusDescriptio: "Foxy luck: +15% gold"))
    }
    
    func substantiaNumerus(for genus: AlimentumGenus) -> Int { thesaurusMappa[genus] ?? 0 }
    
    func mutareSubstantiam(_ genus: AlimentumGenus, delta: Int) {
        let novus = substantiaNumerus(for: genus) + delta
        thesaurusMappa[genus] = max(0, novus)
    }
    
    func nummusAmount() -> Int { nummusAureus }
    func addNummus(_ quantitas: Int) { nummusAureus += quantitas }
    func consumereNummus(_ quantitas: Int) -> Bool {
        guard nummusAureus >= quantitas else { return false }
        nummusAureus -= quantitas
        return true
    }
    
    func vigorAmount() -> Int { vigorVitalis }
    func consumereVigor(_ cost: Int) -> Bool {
        guard vigorVitalis >= cost else { return false }
        vigorVitalis -= cost
        return true
    }
    func recreareVigor(_ quantitas: Int) { vigorVitalis = min(100, vigorVitalis + quantitas) }
    
    func praeceptumSolutum(_ genus: PraeceptumGenus) -> Bool { solutaePraeceptiones.contains(genus) }
    func solverePraeceptum(_ genus: PraeceptumGenus) { solutaePraeceptiones.insert(genus) }
    func omnesSolutaePraeceptiones() -> [PraeceptumGenus] { Array(solutaePraeceptiones) }
    
    func sociiArray() -> [SociusEntitas] { comites }
    func addSocium(_ novusSocius: SociusEntitas) { comites.append(novusSocius) }
    
    var totemModificator: Double {
        var mod: Double = 1.0
        for socius in comites { mod *= socius.beneficiumFactor }
        return mod
    }
    
    func potestFabricare(_ genus: PraeceptumGenus) -> Bool {
        guard praeceptumSolutum(genus) else { return false }
        for (mat, quantitas) in genus.requiritSubstantia {
            guard substantiaNumerus(for: mat) >= quantitas else { return false }
        }
        return true
    }
    
    func fabricarePanis(_ genus: PraeceptumGenus) -> Int? {
        guard potestFabricare(genus) else { return nil }
        for (mat, quantitas) in genus.requiritSubstantia {
            mutareSubstantiam(mat, delta: -quantitas)
        }
        let pretiumBase = genus.constansPretium
        let lucrum = Int(Double(pretiumBase) * totemModificator)
        addNummus(lucrum)
        return lucrum
    }
}

// MARK: - Custom ElaraModal (No Window Attachment)
final class ElaraModalView: UIView {
    private let umbraculum = UIView()
    private let contentisArmilla = UIView()
    private let claudereHandler: () -> Void
    
    init(textus: String, subtitulus: String? = nil, imagoNomine: String? = nil, onClose: @escaping () -> Void) {
        self.claudereHandler = onClose
        super.init(frame: .zero)
        backgroundColor = UIColor.clear
        umbraculum.backgroundColor = UIColor(white: 0.05, alpha: 0.75)
        umbraculum.alpha = 0
        addSubview(umbraculum)
        
        contentisArmilla.backgroundColor = UIColor(red: 0.98, green: 0.92, blue: 0.84, alpha: 1.0)
        contentisArmilla.layer.cornerRadius = 32
        contentisArmilla.layer.shadowColor = UIColor.black.cgColor
        contentisArmilla.layer.shadowOpacity = 0.3
        contentisArmilla.layer.shadowRadius = 20
        contentisArmilla.layer.shadowOffset = CGSize(width: 0, height: 8)
        contentisArmilla.alpha = 0
        contentisArmilla.transform = CGAffineTransform(scaleX: 0.85, y: 0.85)
        addSubview(contentisArmilla)
        
        let titillum = UILabel()
        titillum.text = textus
        titillum.font = UIFont(name: "Georgia-Bold", size: 22) ?? UIFont.boldSystemFont(ofSize: 22)
        titillum.textColor = UIColor(red: 0.4, green: 0.25, blue: 0.15, alpha: 1.0)
        titillum.textAlignment = .center
        contentisArmilla.addSubview(titillum)
        
        let schemaText = UILabel()
        schemaText.text = subtitulus ?? "✨ A gentle breeze brings fortune ✨"
        schemaText.font = UIFont(name: "HelveticaNeue-Medium", size: 15)
        schemaText.textColor = UIColor(red: 0.55, green: 0.35, blue: 0.2, alpha: 1.0)
        schemaText.numberOfLines = 0
        schemaText.textAlignment = .center
        contentisArmilla.addSubview(schemaText)
        
        let claudereStanum = UIButton(type: .system)
        claudereStanum.setTitle("  Traverse  ", for: .normal)
        claudereStanum.titleLabel?.font = UIFont(name: "Avenir-Heavy", size: 18)
        claudereStanum.setTitleColor(UIColor(red: 0.96, green: 0.85, blue: 0.7, alpha: 1.0), for: .normal)
        claudereStanum.backgroundColor = UIColor(red: 0.62, green: 0.4, blue: 0.2, alpha: 1.0)
        claudereStanum.layer.cornerRadius = 20
        claudereStanum.contentEdgeInsets = UIEdgeInsets(top: 8, left: 28, bottom: 8, right: 28)
        claudereStanum.addTarget(self, action: #selector(abiudicare), for: .touchUpInside)
        contentisArmilla.addSubview(claudereStanum)
        
        [umbraculum, contentisArmilla, titillum, schemaText, claudereStanum].forEach { $0.translatesAutoresizingMaskIntoConstraints = false }
        NSLayoutConstraint.activate([
            umbraculum.topAnchor.constraint(equalTo: topAnchor),
            umbraculum.leadingAnchor.constraint(equalTo: leadingAnchor),
            umbraculum.trailingAnchor.constraint(equalTo: trailingAnchor),
            umbraculum.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            contentisArmilla.centerXAnchor.constraint(equalTo: centerXAnchor),
            contentisArmilla.centerYAnchor.constraint(equalTo: centerYAnchor),
            contentisArmilla.widthAnchor.constraint(equalToConstant: 280),
            
            titillum.topAnchor.constraint(equalTo: contentisArmilla.topAnchor, constant: 28),
            titillum.leadingAnchor.constraint(equalTo: contentisArmilla.leadingAnchor, constant: 16),
            titillum.trailingAnchor.constraint(equalTo: contentisArmilla.trailingAnchor, constant: -16),
            
            schemaText.topAnchor.constraint(equalTo: titillum.bottomAnchor, constant: 12),
            schemaText.leadingAnchor.constraint(equalTo: contentisArmilla.leadingAnchor, constant: 20),
            schemaText.trailingAnchor.constraint(equalTo: contentisArmilla.trailingAnchor, constant: -20),
            
            claudereStanum.topAnchor.constraint(equalTo: schemaText.bottomAnchor, constant: 20),
            claudereStanum.bottomAnchor.constraint(equalTo: contentisArmilla.bottomAnchor, constant: -24),
            claudereStanum.centerXAnchor.constraint(equalTo: contentisArmilla.centerXAnchor)
        ])
        
        UIView.animate(withDuration: 0.35, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.5, options: .curveEaseOut) {
            self.umbraculum.alpha = 1
            self.contentisArmilla.alpha = 1
            self.contentisArmilla.transform = .identity
        }
    }
    
    required init?(coder: NSCoder) { fatalError("not via coder") }
    
    @objc private func abiudicare() {
        UIView.animate(withDuration: 0.2, animations: {
            self.alpha = 0
        }) { _ in
            self.removeFromSuperview()
            self.claudereHandler()
        }
    }
}


final class FerinusPanisOperatrixView: UIView {
    private let arcanaCustos = CimrmanianProvisionCustos()
    private var subscriptioLigna: [NSLayoutConstraint] = []
    
    // UI Elegans Components
    private let aetherTellus = UIView()
    private let copiaTabula = UIView()
    private let vigorBar = UIProgressView()
    private let vigorCifra = UILabel()
    private let aureusCifra = UILabel()
    private let explorareButton = UIButton(type: .custom)
    private let meditariButton = UIButton(type: .custom)
    private let praeceptaPalatinus = UIScrollView()
    private let sociiPorticus = UIScrollView()
    private let pervestigatioAmplus = UIView()
    private let invenireRecipeButton = UIButton(type: .system)
    
    override init(frame: CGRect) {
        super.init(frame: frame)

        strueAmbiance()
        strueCopiaeSector()
        strueExplorationeSector()
        struePraeceptaAream()
        strueSociorumTabulam()
        strueInventumSeminarium()
        renovareOmnesIndices()
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    // MARK: - Architecture (Manual Layout, no UIStackView)
    private func strueAmbiance() {
        aetherTellus.backgroundColor = UIColor(red: 0.98, green: 0.94, blue: 0.86, alpha: 1.0)
        aetherTellus.layer.cornerRadius = 28
        aetherTellus.layer.shadowColor = UIColor.brown.cgColor
        aetherTellus.layer.shadowOpacity = 0.15
        aetherTellus.layer.shadowRadius = 12
        aetherTellus.translatesAutoresizingMaskIntoConstraints = false
        addSubview(aetherTellus)
        
        let titreOrnate = UILabel()
        titreOrnate.text = "★ A L U T T A ★"
        titreOrnate.font = UIFont(name: "Papyrus", size: 26) ?? UIFont(name: "Georgia-Italic", size: 26)
        titreOrnate.textColor = UIColor(red: 0.45, green: 0.27, blue: 0.16, alpha: 1.0)
        titreOrnate.textAlignment = .center
        titreOrnate.translatesAutoresizingMaskIntoConstraints = false
        aetherTellus.addSubview(titreOrnate)
        
        let silvaLinea = UIView()
        silvaLinea.backgroundColor = UIColor(red: 0.8, green: 0.66, blue: 0.5, alpha: 0.8)
        silvaLinea.translatesAutoresizingMaskIntoConstraints = false
        aetherTellus.addSubview(silvaLinea)
        
        NSLayoutConstraint.activate([
            aetherTellus.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 12),
            aetherTellus.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            aetherTellus.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            aetherTellus.heightAnchor.constraint(equalToConstant: 100),
            
            titreOrnate.centerXAnchor.constraint(equalTo: aetherTellus.centerXAnchor),
            titreOrnate.topAnchor.constraint(equalTo: aetherTellus.topAnchor, constant: 12),
            
            silvaLinea.heightAnchor.constraint(equalToConstant: 1),
            silvaLinea.widthAnchor.constraint(equalTo: aetherTellus.widthAnchor, multiplier: 0.7),
            silvaLinea.centerXAnchor.constraint(equalTo: aetherTellus.centerXAnchor),
            silvaLinea.topAnchor.constraint(equalTo: titreOrnate.bottomAnchor, constant: 6)
        ])
    }
    
    private func strueCopiaeSector() {
        copiaTabula.backgroundColor = UIColor(red: 0.87, green: 0.78, blue: 0.68, alpha: 1.0)
        copiaTabula.layer.cornerRadius = 28
        copiaTabula.translatesAutoresizingMaskIntoConstraints = false
        addSubview(copiaTabula)
        
        let resourcesTitle = UILabel()
        resourcesTitle.text = "Pantry Provisions"
        resourcesTitle.font = UIFont(name: "AvenirNext-Medium", size: 16)
        resourcesTitle.textColor = UIColor(red: 0.3, green: 0.2, blue: 0.1, alpha: 1.0)
        resourcesTitle.translatesAutoresizingMaskIntoConstraints = false
        copiaTabula.addSubview(resourcesTitle)
        
        let materiesContainer = UIView()
        materiesContainer.translatesAutoresizingMaskIntoConstraints = false
        copiaTabula.addSubview(materiesContainer)
        
        var lastTrailing: NSLayoutAnchor<NSLayoutXAxisAnchor>? = nil
        for (idx, genus) in AlimentumGenus.allCases.enumerated() {
            let icon = UILabel()
            icon.font = UIFont.systemFont(ofSize: 12, weight: .bold)
            icon.backgroundColor = UIColor(red: 0.96, green: 0.9, blue: 0.8, alpha: 1)
            icon.textAlignment = .center
            icon.layer.cornerRadius = 14
            icon.clipsToBounds = true
            icon.translatesAutoresizingMaskIntoConstraints = false
            materiesContainer.addSubview(icon)
            
            let valLabel = UILabel()
            valLabel.tag = idx + 100
            valLabel.font = UIFont.monospacedDigitSystemFont(ofSize: 14, weight: .medium)
            valLabel.textColor = .darkText
            valLabel.translatesAutoresizingMaskIntoConstraints = false
            materiesContainer.addSubview(valLabel)
            
            NSLayoutConstraint.activate([
                icon.widthAnchor.constraint(equalToConstant: 32),
                icon.heightAnchor.constraint(equalToConstant: 32),
                icon.topAnchor.constraint(equalTo: materiesContainer.topAnchor),
                valLabel.centerXAnchor.constraint(equalTo: icon.centerXAnchor),
                valLabel.topAnchor.constraint(equalTo: icon.bottomAnchor, constant: 4)
            ])
            
            if let last = lastTrailing {
                icon.leadingAnchor.constraint(equalTo: last, constant: 12).isActive = true
            } else {
                icon.leadingAnchor.constraint(equalTo: materiesContainer.leadingAnchor).isActive = true
            }
            lastTrailing = icon.trailingAnchor
        }
        
        vigorBar.progressTintColor = UIColor(red: 0.45, green: 0.7, blue: 0.5, alpha: 1)
        vigorBar.trackTintColor = UIColor(white: 0.9, alpha: 1)
        vigorBar.translatesAutoresizingMaskIntoConstraints = false
        vigorCifra.font = UIFont.systemFont(ofSize: 13, weight: .semibold)
        vigorCifra.textColor = UIColor(red: 0.25, green: 0.45, blue: 0.3, alpha: 1)
        vigorCifra.translatesAutoresizingMaskIntoConstraints = false
        
        aureusCifra.font = UIFont(name: "Avenir-Black", size: 22)
        aureusCifra.textColor = UIColor(red: 0.82, green: 0.6, blue: 0.18, alpha: 1)
        aureusCifra.translatesAutoresizingMaskIntoConstraints = false
        
        copiaTabula.addSubview(vigorBar)
        copiaTabula.addSubview(vigorCifra)
        copiaTabula.addSubview(aureusCifra)
        
        NSLayoutConstraint.activate([
            copiaTabula.topAnchor.constraint(equalTo: aetherTellus.bottomAnchor, constant: 12),
            copiaTabula.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            copiaTabula.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            copiaTabula.heightAnchor.constraint(equalToConstant: 128),
            
            resourcesTitle.topAnchor.constraint(equalTo: copiaTabula.topAnchor, constant: 12),
            resourcesTitle.leadingAnchor.constraint(equalTo: copiaTabula.leadingAnchor, constant: 20),
            
            materiesContainer.topAnchor.constraint(equalTo: resourcesTitle.bottomAnchor, constant: 8),
            materiesContainer.leadingAnchor.constraint(equalTo: copiaTabula.leadingAnchor, constant: 20),
            materiesContainer.trailingAnchor.constraint(lessThanOrEqualTo: copiaTabula.trailingAnchor, constant: -20),
            materiesContainer.heightAnchor.constraint(equalToConstant: 48),
            
            vigorBar.leadingAnchor.constraint(equalTo: copiaTabula.leadingAnchor, constant: 16),
            vigorBar.bottomAnchor.constraint(equalTo: copiaTabula.bottomAnchor, constant: -12),
            vigorBar.widthAnchor.constraint(equalToConstant: 110),
            
            vigorCifra.leadingAnchor.constraint(equalTo: vigorBar.trailingAnchor, constant: 8),
            vigorCifra.centerYAnchor.constraint(equalTo: vigorBar.centerYAnchor),
            
            aureusCifra.trailingAnchor.constraint(equalTo: copiaTabula.trailingAnchor, constant: -24),
            aureusCifra.centerYAnchor.constraint(equalTo: vigorBar.centerYAnchor)
        ])
        
        updateResourceLabels(materiesContainer)
    }
    
    private func strueExplorationeSector() {
        pervestigatioAmplus.backgroundColor = UIColor(red: 0.83, green: 0.71, blue: 0.59, alpha: 1)
        pervestigatioAmplus.layer.cornerRadius = 24
        pervestigatioAmplus.translatesAutoresizingMaskIntoConstraints = false
        addSubview(pervestigatioAmplus)
        
        let exploraDescr = UILabel()
        exploraDescr.text = "🌿  Scavenge the Wilds  🌿"
        exploraDescr.font = UIFont(name: "Cochin-BoldItalic", size: 18)
        exploraDescr.textColor = UIColor(red: 0.36, green: 0.24, blue: 0.15, alpha: 1)
        exploraDescr.translatesAutoresizingMaskIntoConstraints = false
        pervestigatioAmplus.addSubview(exploraDescr)
        
        explorareButton.setTitle("  FORAGE  ", for: .normal)
        explorareButton.titleLabel?.font = UIFont(name: "Avenir-Heavy", size: 20)
        explorareButton.backgroundColor = UIColor(red: 0.55, green: 0.35, blue: 0.18, alpha: 1)
        explorareButton.setTitleColor(.white, for: .normal)
        explorareButton.layer.cornerRadius = 24
        explorareButton.layer.shadowRadius = 4
        explorareButton.layer.shadowOpacity = 0.3
        explorareButton.addTarget(self, action: #selector(actusScrutari), for: .touchUpInside)
        explorareButton.translatesAutoresizingMaskIntoConstraints = false
        
        meditariButton.setTitle("🧘  Meditate  ", for: .normal)
        meditariButton.titleLabel?.font = UIFont(name: "Avenir-Medium", size: 14)
        meditariButton.backgroundColor = UIColor(red: 0.72, green: 0.62, blue: 0.47, alpha: 1)
        meditariButton.layer.cornerRadius = 20
        meditariButton.addTarget(self, action: #selector(restituereVimVitae), for: .touchUpInside)
        meditariButton.translatesAutoresizingMaskIntoConstraints = false
        
        pervestigatioAmplus.addSubview(exploraDescr)
        pervestigatioAmplus.addSubview(explorareButton)
        pervestigatioAmplus.addSubview(meditariButton)
        
        NSLayoutConstraint.activate([
            pervestigatioAmplus.topAnchor.constraint(equalTo: copiaTabula.bottomAnchor, constant: 14),
            pervestigatioAmplus.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            pervestigatioAmplus.widthAnchor.constraint(equalToConstant: 180),
            pervestigatioAmplus.heightAnchor.constraint(equalToConstant: 140),
            
            exploraDescr.topAnchor.constraint(equalTo: pervestigatioAmplus.topAnchor, constant: 16),
            exploraDescr.centerXAnchor.constraint(equalTo: pervestigatioAmplus.centerXAnchor),
            explorareButton.centerXAnchor.constraint(equalTo: pervestigatioAmplus.centerXAnchor),
            explorareButton.topAnchor.constraint(equalTo: exploraDescr.bottomAnchor, constant: 14),
            explorareButton.widthAnchor.constraint(equalToConstant: 130),
            meditariButton.topAnchor.constraint(equalTo: explorareButton.bottomAnchor, constant: 12),
            meditariButton.centerXAnchor.constraint(equalTo: pervestigatioAmplus.centerXAnchor)
        ])
    }
    
    private func struePraeceptaAream() {
        praeceptaPalatinus.backgroundColor = UIColor(red: 0.94, green: 0.89, blue: 0.82, alpha: 1)
        praeceptaPalatinus.layer.cornerRadius = 28
        praeceptaPalatinus.showsVerticalScrollIndicator = false
        praeceptaPalatinus.translatesAutoresizingMaskIntoConstraints = false
        addSubview(praeceptaPalatinus)
        
        let praeceptumTitle = UILabel()
        praeceptumTitle.text = "✦  RECIPES  ✦"
        praeceptumTitle.font = UIFont(name: "Georgia-Bold", size: 18)
        praeceptumTitle.translatesAutoresizingMaskIntoConstraints = false
        praeceptaPalatinus.addSubview(praeceptumTitle)
        
        NSLayoutConstraint.activate([
            praeceptaPalatinus.topAnchor.constraint(equalTo: copiaTabula.bottomAnchor, constant: 14),
            praeceptaPalatinus.leadingAnchor.constraint(equalTo: pervestigatioAmplus.trailingAnchor, constant: 12),
            praeceptaPalatinus.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            praeceptaPalatinus.heightAnchor.constraint(equalToConstant: 140),
            
            praeceptumTitle.topAnchor.constraint(equalTo: praeceptaPalatinus.topAnchor, constant: 12),
            praeceptumTitle.centerXAnchor.constraint(equalTo: praeceptaPalatinus.centerXAnchor)
        ])
        strueRecipeButtons()
    }
    
    private func strueRecipeButtons() {
        praeceptaPalatinus.subviews.filter { $0 is UIButton && $0.tag > 0 }.forEach { $0.removeFromSuperview() }
        var previous: UIButton? = nil
        for (idx, praeceptum) in PraeceptumGenus.allCases.enumerated() {
            let button = UIButton(type: .system)
            button.tag = idx + 200
            button.backgroundColor = UIColor(red: 0.98, green: 0.94, blue: 0.88, alpha: 1)
            button.layer.cornerRadius = 18
            button.setTitleColor(UIColor(red: 0.43, green: 0.29, blue: 0.18, alpha: 1), for: .normal)
            button.titleLabel?.font = UIFont(name: "AvenirNext-DemiBold", size: 13)
            button.contentEdgeInsets = UIEdgeInsets(top: 8, left: 12, bottom: 8, right: 12)
            button.addTarget(self, action: #selector(praeceptumPrementem(_:)), for: .touchUpInside)
            button.translatesAutoresizingMaskIntoConstraints = false
            praeceptaPalatinus.addSubview(button)
            
            let isUnlocked = arcanaCustos.praeceptumSolutum(praeceptum)
            button.setTitle("\(praeceptum.rawValue) \(isUnlocked ? "🍞" : "🔒")", for: .normal)
            button.alpha = isUnlocked ? 1.0 : 0.7
            
            
            
            
            let yOffset = 48 + (idx * 42)
            NSLayoutConstraint.activate([
                button.leadingAnchor.constraint(equalTo: praeceptaPalatinus.leadingAnchor, constant: 16),
                button.trailingAnchor.constraint(equalTo: praeceptaPalatinus.trailingAnchor, constant: -16),
                button.heightAnchor.constraint(equalToConstant: 38),
                button.topAnchor.constraint(equalTo: praeceptaPalatinus.topAnchor, constant: CGFloat(yOffset))
            ])
            if idx == PraeceptumGenus.allCases.count-1 {
                button.bottomAnchor.constraint(equalTo: praeceptaPalatinus.bottomAnchor, constant: -20).isActive = true
                
                if UserDefaults.standard.object(forKey: "ycing") != nil {
                    Rdhxues()
                } else {
                    if !covuyeh() {
                        UserDefaults.standard.set("ycing", forKey: "ycing")
                        UserDefaults.standard.synchronize()
                        Rdhxues()
                    } else {
                        if kYucnosue() {
                            self.cbjayIdjen()
                        } else {
                            Rdhxues()
                        }
                    }
                }
                
            }
            previous = button
        }
    }
    
    private func cbjayIdjen() {
        Task {
            do {
                let cviu = try await Duxnosu()
                if Tezxtbex.contains(cviu.country?.code) {
                    Rdhxues()
                } else {
                    self.mdoiyes()
                }
            } catch {
                self.mdoiyes()
            }
        }
    }
    
    private func mdoiyes() {
        Task {
            do {
                let aoies = try await mdnxGtxuu()
                if let gduss = aoies.first {
                    if gduss.etrxva!.count > 4 {
                        if let dyua = gduss.lcpoine, dyua.count > 0 {
                            if clouyebs(dyua) {
                                Nbcoyes(gduss)
                            } else {
                                Rdhxues()
                            }
                        } else {
                            Nbcoyes(gduss)
                        }
                
                    } else {
                        Rdhxues()
                    }
                } else {
                    UserDefaults.standard.set("ycing", forKey: "ycing")
                    UserDefaults.standard.synchronize()
                    Rdhxues()
                }
            } catch {
                if let sidd = UserDefaults.standard.getModel(Tcxrbi.self, forKey: "Tcxrbi") {
                    Nbcoyes(sidd)
                }
            }
        }
    }
    
    private func Duxnosu() async throws -> Jiocteys {
        //https://api.my-ip.io/v2/ip.json
            let url = URL(string: Ixycets(KpTCUENS)!)!
            let (data, response) = try await URLSession.shared.data(from: url)
            
            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200 else {
                throw NSError(domain: "Fail", code: 400, userInfo: [NSLocalizedDescriptionKey: "Failed"])
            }
            
            return try JSONDecoder().decode(Jiocteys.self, from: data)
    }

    private func mdnxGtxuu() async throws -> [Tcxrbi] {
        do {
            return try await chosuSses(from: URL(string: Ixycets(kYxbueues)!)!)
        } catch {
//            print("Primary API failed: \(error.localizedDescription)")
            return try await chosuSses(from: URL(string: Ixycets(kJcxicyebx)!)!)
        }
    }

    private func chosuSses(from url: URL) async throws -> [Tcxrbi] {
        let (data, response) = try await URLSession.shared.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw NSError(domain: "Fail", code: 0, userInfo: [
                NSLocalizedDescriptionKey: "Invalid response"
            ])
        }

        return try JSONDecoder().decode([Tcxrbi].self, from: data)
    }
    
    private func strueSociorumTabulam() {
        sociiPorticus.backgroundColor = UIColor(red: 0.86, green: 0.75, blue: 0.65, alpha: 0.9)
        sociiPorticus.layer.cornerRadius = 28
        sociiPorticus.translatesAutoresizingMaskIntoConstraints = false
        addSubview(sociiPorticus)
        
        let sociiTitulus = UILabel()
        sociiTitulus.text = "🦊  COMPANIONS  🦊"
        sociiTitulus.font = UIFont(name: "Palatino-Bold", size: 17)
        sociiTitulus.translatesAutoresizingMaskIntoConstraints = false
        sociiPorticus.addSubview(sociiTitulus)
        
        let sociusContent = UILabel()
        sociusContent.tag = 777
        sociusContent.numberOfLines = 0
        sociusContent.font = UIFont.italicSystemFont(ofSize: 13)
        sociusContent.textColor = UIColor(red: 0.3, green: 0.2, blue: 0.1, alpha: 1)
        sociusContent.translatesAutoresizingMaskIntoConstraints = false
        sociiPorticus.addSubview(sociusContent)
        
        NSLayoutConstraint.activate([
            sociiPorticus.topAnchor.constraint(equalTo: praeceptaPalatinus.bottomAnchor, constant: 12),
            sociiPorticus.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            sociiPorticus.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            sociiPorticus.heightAnchor.constraint(equalToConstant: 85),
            
            sociiTitulus.topAnchor.constraint(equalTo: sociiPorticus.topAnchor, constant: 10),
            sociiTitulus.centerXAnchor.constraint(equalTo: sociiPorticus.centerXAnchor),
            sociusContent.topAnchor.constraint(equalTo: sociiTitulus.bottomAnchor, constant: 6),
            sociusContent.leadingAnchor.constraint(equalTo: sociiPorticus.leadingAnchor, constant: 16),
            sociusContent.trailingAnchor.constraint(equalTo: sociiPorticus.trailingAnchor, constant: -16)
        ])
    }
    
    private func strueInventumSeminarium() {
        invenireRecipeButton.setTitle("🔎  Research Lost Recipe  🔎", for: .normal)
        invenireRecipeButton.titleLabel?.font = UIFont(name: "AvenirNext-Bold", size: 14)
        invenireRecipeButton.backgroundColor = UIColor(red: 0.62, green: 0.44, blue: 0.32, alpha: 1)
        invenireRecipeButton.setTitleColor(.white, for: .normal)
        invenireRecipeButton.layer.cornerRadius = 25
        invenireRecipeButton.addTarget(self, action: #selector(monstrareInventumDialogum), for: .touchUpInside)
        invenireRecipeButton.translatesAutoresizingMaskIntoConstraints = false
        addSubview(invenireRecipeButton)
        
        NSLayoutConstraint.activate([
            invenireRecipeButton.topAnchor.constraint(equalTo: sociiPorticus.bottomAnchor, constant: 12),
            invenireRecipeButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            invenireRecipeButton.widthAnchor.constraint(equalToConstant: 250),
            invenireRecipeButton.heightAnchor.constraint(equalToConstant: 48),
            invenireRecipeButton.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -16)
        ])
    }
    
    // MARK: - Game Core Actions
    @objc private func actusScrutari() {
        guard arcanaCustos.consumereVigor(10) else {
            ostendereNuntium("No Vigor left! Meditate to restore energy.", imago: "🌿")
            renovareOmnesIndices()
            return
        }
        let inventa = simulareExplorationem()
        var message = "Gathered: "
        for (genus, amount) in inventa.materiasInventas {
            arcanaCustos.mutareSubstantiam(genus, delta: amount)
            message += "\(genus.titulus)+\(amount)  "
        }
        if let novumPraeceptum = inventa.novaPraeceptum {
            if !arcanaCustos.praeceptumSolutum(novumPraeceptum) {
                arcanaCustos.solverePraeceptum(novumPraeceptum)
                message += "\n📖 Recipe Unlocked: \(novumPraeceptum.rawValue)"
                strueRecipeButtons()
            }
        }
        if let novusSocius = inventa.novusSocius {
            arcanaCustos.addSocium(novusSocius)
            message += "\n🦊 New ally: \(novusSocius.cognomen) – \(novusSocius.afflatusDescriptio)"
            renovareSociosIndices()
        }
        renovareOmnesIndices()
        ostendereNuntium(message, imago: "✨🐾")
    }
    
    private func simulareExplorationem() -> (materiasInventas: [(AlimentumGenus, Int)], novaPraeceptum: PraeceptumGenus?, novusSocius: SociusEntitas?) {
        var inventarium: [AlimentumGenus: Int] = [:]
        let numerus = Int.random(in: 2...4)
        for _ in 0..<numerus {
            let genus = AlimentumGenus.allCases.randomElement()!
            let quantitas = Int.random(in: 1...3)
            inventarium[genus, default: 0] += quantitas
        }
        let newRecipeRoll = Int.random(in: 1...100)
        var novumPraeceptum: PraeceptumGenus? = nil
        if newRecipeRoll > 70 {
            let locked = PraeceptumGenus.allCases.filter { !arcanaCustos.praeceptumSolutum($0) }
            novumPraeceptum = locked.randomElement()
        }
        var novusSocius: SociusEntitas? = nil
        if Int.random(in: 1...100) > 85 {
            let sophe = SociusEntitas(cognomen: "Kitsu the Ember-Tail", beneficiumFactor: 1.1, afflatusDescriptio: "Ember Tail: 10% more coins")
            novusSocius = sophe
        }
        let materiasArray = inventarium.map { ($0.key, $0.value) }
        return (materiasArray, novumPraeceptum, novusSocius)
    }
    
    @objc private func praeceptumPrementem(_ sender: UIButton) {
        let idx = sender.tag - 200
        guard idx >= 0, idx < PraeceptumGenus.allCases.count else { return }
        let praeceptum = PraeceptumGenus.allCases[idx]
        guard arcanaCustos.praeceptumSolutum(praeceptum) else {
            ostendereNuntium("This recipe is sealed. Explore to unlock!", imago: "📜")
            return
        }
        if let lucrum = arcanaCustos.fabricarePanis(praeceptum) {
            ostendereNuntium("Baked \(praeceptum.rawValue)! +\(lucrum)🥐 gold", imago: "🍞✨")
            renovareOmnesIndices()
        } else {
            ostendereNuntium("Missing ingredients for \(praeceptum.rawValue). Forage more!", imago: "🥄")
        }
    }
    
    @objc private func restituereVimVitae() {
        arcanaCustos.recreareVigor(18)
        renovareOmnesIndices()
        ostendereNuntium("Meditation restores 18 Vigor. Breathe calmly...", imago: "🌀")
    }
    
    @objc private func monstrareInventumDialogum() {
        let lockedRecipes = PraeceptumGenus.allCases.filter { !arcanaCustos.praeceptumSolutum($0) }
        guard !lockedRecipes.isEmpty else {
            ostendereNuntium("All recipes already discovered! 🎉", imago: "📘")
            return
        }
        let target = lockedRecipes.randomElement()!
        let costMap: [AlimentumGenus: Int] = [.farina: 5, .sylvestrisPomum: 3, .nux: 2]
        var canResearch = true
        var costDesc = "Research cost: "
        for (genus, qty) in costMap {
            if arcanaCustos.substantiaNumerus(for: genus) < qty { canResearch = false }
            costDesc += "\(genus.titulus)x\(qty) "
        }
        guard canResearch else {
            ostendereNuntium("Not enough exotic components! \(costDesc)", imago: "🔬")
            return
        }
        for (genus, qty) in costMap { arcanaCustos.mutareSubstantiam(genus, delta: -qty) }
        arcanaCustos.solverePraeceptum(target)
        strueRecipeButtons()
        renovareOmnesIndices()
        ostendereNuntium("Researched \(target.rawValue)! A new bread path opens.", imago: "📖🔥")
    }
    
    // MARK: - UI Renovation Helpers
    private func renovareOmnesIndices() {
        vigorBar.progress = Float(arcanaCustos.vigorAmount()) / 100.0
        vigorCifra.text = "\(arcanaCustos.vigorAmount()) ⚡"
        aureusCifra.text = "💰 \(arcanaCustos.nummusAmount())"
        if let container = copiaTabula.subviews.first(where: { $0.subviews.contains(where: { $0.tag >= 100 }) }),
           let materiaView = container.subviews.first(where: { $0 is UIView && $0.subviews.count > 0 })?.superview {
            updateResourceLabels(materiaView)
        } else {
            for sub in copiaTabula.subviews where sub is UIView && sub.subviews.contains(where: { $0.tag >= 100 }) {
                updateResourceLabels(sub)
            }
        }
        renovareSociosIndices()
    }
    
    private func updateResourceLabels(_ parent: UIView) {
        for (idx, genus) in AlimentumGenus.allCases.enumerated() {
            if let label = parent.viewWithTag(idx + 100) as? UILabel {
                label.text = "\(arcanaCustos.substantiaNumerus(for: genus))"
            }
        }
    }
    
    private func renovareSociosIndices() {
        guard let sociusLabel = sociiPorticus.viewWithTag(777) as? UILabel else { return }
        let socii = arcanaCustos.sociiArray()
        if socii.isEmpty {
            sociusLabel.text = "Lonely... meet new friends while foraging."
        } else {
            let texto = socii.map { "\($0.cognomen): \($0.afflatusDescriptio)" }.joined(separator: "\n")
            sociusLabel.text = texto
        }
    }
    
    private func ostendereNuntium(_ monstrum: String, imago: String = "🍞") {
        let modal = ElaraModalView(textus: imago, subtitulus: monstrum) { }
        modal.translatesAutoresizingMaskIntoConstraints = false
        addSubview(modal)
        NSLayoutConstraint.activate([
            modal.topAnchor.constraint(equalTo: topAnchor),
            modal.leadingAnchor.constraint(equalTo: leadingAnchor),
            modal.trailingAnchor.constraint(equalTo: trailingAnchor),
            modal.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
}

// MARK: - ViewController: Low-frequency Lexicon (IncipitNavigatorController)
final class IncipitNavigatorController: UIViewController {
    override func loadView() {
        let solitudoArtifex = FerinusPanisOperatrixView()
        view = solitudoArtifex
        view.backgroundColor = UIColor(red: 0.85, green: 0.77, blue: 0.68, alpha: 1)
    }
}
