import Foundation

struct PresetEntity: Codable, Identifiable {
    let id: UUID
    var name: String
    let config: CobaltConfig
    let createdAt: Date
}

extension CobaltConfig: Codable {
    enum CodingKeys: String, CodingKey {
        case iterationQuantum
        case wagerAmount
        case cascadeMode
        case isLineSimulated
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.iterationQuantum = try container.decode(Int.self, forKey: .iterationQuantum)
        self.wagerAmount = try container.decode(Double.self, forKey: .wagerAmount)
        let cascadeModeStr = try container.decode(String.self, forKey: .cascadeMode)
        self.cascadeMode = CascadeMode(rawValue: cascadeModeStr) ?? .universal
        self.isLineSimulated = try container.decode(Bool.self, forKey: .isLineSimulated)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(iterationQuantum, forKey: .iterationQuantum)
        try container.encode(wagerAmount, forKey: .wagerAmount)
        try container.encode(cascadeMode.rawValue, forKey: .cascadeMode)
        try container.encode(isLineSimulated, forKey: .isLineSimulated)
    }
}
