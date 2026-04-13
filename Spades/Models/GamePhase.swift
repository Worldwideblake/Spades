import Foundation

enum GamePhase: Equatable {
    case notStarted
    case dealing
    case bidding(currentBidder: PlayerPosition)
    case playing(currentPlayer: PlayerPosition)
    case trickWon(winner: PlayerPosition)
    case roundEnd
    case gameOver(winningTeam: Int)

    var isPlaying: Bool {
        if case .playing = self { return true }
        return false
    }

    var isBidding: Bool {
        if case .bidding = self { return true }
        return false
    }

    var currentPlayerPosition: PlayerPosition? {
        switch self {
        case .bidding(let pos): return pos
        case .playing(let pos): return pos
        case .trickWon(let pos): return pos
        default: return nil
        }
    }
}
