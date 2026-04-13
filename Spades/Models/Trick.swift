import Foundation

struct TrickPlay: Identifiable, Equatable {
    let id = UUID()
    let playerPosition: PlayerPosition
    let card: Card

    static func == (lhs: TrickPlay, rhs: TrickPlay) -> Bool {
        lhs.playerPosition == rhs.playerPosition && lhs.card == rhs.card
    }
}

struct Trick: Equatable {
    var plays: [TrickPlay] = []
    var leadPosition: PlayerPosition

    var leadSuit: Suit? { plays.first?.card.suit }
    var isComplete: Bool { plays.count == 4 }
    var isEmpty: Bool { plays.isEmpty }
    var playCount: Int { plays.count }

    func card(for position: PlayerPosition) -> Card? {
        plays.first(where: { $0.playerPosition == position })?.card
    }

    static func == (lhs: Trick, rhs: Trick) -> Bool {
        lhs.plays.count == rhs.plays.count &&
        lhs.leadPosition == rhs.leadPosition &&
        zip(lhs.plays, rhs.plays).allSatisfy { $0 == $1 }
    }
}

struct RoundSummary: Identifiable {
    let id = UUID()
    let roundNumber: Int
    let teamBids: [Int: Int]
    let teamTricks: [Int: Int]
    let teamScoreDeltas: [Int: Int]
    let teamBagDeltas: [Int: Int]
    let nilResults: [PlayerPosition: Bool]
}
