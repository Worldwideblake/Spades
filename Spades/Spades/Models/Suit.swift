import SwiftUI

enum Suit: Int, CaseIterable, Comparable, Codable, Hashable {
    case clubs = 0
    case diamonds = 1
    case hearts = 2
    case spades = 3

    static func < (lhs: Suit, rhs: Suit) -> Bool {
        lhs.rawValue < rhs.rawValue
    }

    var symbol: String {
        switch self {
        case .clubs: return "♣"
        case .diamonds: return "♦"
        case .hearts: return "♥"
        case .spades: return "♠"
        }
    }

    var color: Color {
        isRed ? Color(hex: "#E55656") : Color(hex: "#2C2C2C")
    }

    var isRed: Bool {
        self == .diamonds || self == .hearts
    }

    var displayName: String {
        switch self {
        case .clubs: return "Clubs"
        case .diamonds: return "Diamonds"
        case .hearts: return "Hearts"
        case .spades: return "Spades"
        }
    }
}
