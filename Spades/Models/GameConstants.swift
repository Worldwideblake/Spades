import Foundation

enum GameConstants {
    static let winningScore = 500
    static let bagPenaltyThreshold = 10
    static let bagPenalty = -100
    static let nilBonus = 100
    static let nilPenalty = -100
    static let cardsPerPlayer = 13
    static let totalPlayers = 4
    static let botThinkDelay: UInt64 = 800_000_000  // 0.8 seconds in nanoseconds
    static let trickAnimationDelay: UInt64 = 1_000_000_000  // 1.0 seconds
    static let dealAnimationDelay: UInt64 = 300_000_000  // 0.3 seconds
}
