import Foundation

struct Card: Identifiable, Equatable, Hashable, Codable {
    let suit: Suit
    let rank: Rank

    var id: String { "\(rank.rawValue)-\(suit.rawValue)" }
    var isSpade: Bool { suit == .spades }

    static func fullDeck() -> [Card] {
        Suit.allCases.flatMap { suit in
            Rank.allCases.map { rank in Card(suit: suit, rank: rank) }
        }
    }
}

extension Card: Comparable {
    static func < (lhs: Card, rhs: Card) -> Bool {
        if lhs.suit == rhs.suit {
            return lhs.rank < rhs.rank
        }
        return lhs.suit < rhs.suit
    }
}
