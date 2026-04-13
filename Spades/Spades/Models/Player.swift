import Foundation

enum PlayerPosition: Int, CaseIterable, Codable, Hashable {
    case bottom = 0
    case left = 1
    case top = 2
    case right = 3

    var next: PlayerPosition {
        PlayerPosition(rawValue: (rawValue + 1) % 4)!
    }

    var displayName: String {
        switch self {
        case .bottom: return "You"
        case .left: return "West"
        case .top: return "North"
        case .right: return "East"
        }
    }

    var isHuman: Bool {
        self == .bottom
    }

    var teamId: Int {
        switch self {
        case .bottom, .top: return 0
        case .left, .right: return 1
        }
    }

    var partner: PlayerPosition {
        switch self {
        case .bottom: return .top
        case .top: return .bottom
        case .left: return .right
        case .right: return .left
        }
    }
}

struct Player: Identifiable {
    let id: PlayerPosition
    let name: String
    let isHuman: Bool

    var hand: [Card] = []
    var bid: Int? = nil
    var tricksWon: Int = 0
    var totalScore: Int = 0
    var bags: Int = 0

    var hasBid: Bool { bid != nil }
    var isNilBid: Bool { bid == 0 }
    var position: PlayerPosition { id }

    init(position: PlayerPosition) {
        self.id = position
        self.name = position.displayName
        self.isHuman = position.isHuman
    }

    mutating func resetForNewRound() {
        hand = []
        bid = nil
        tricksWon = 0
    }
}
