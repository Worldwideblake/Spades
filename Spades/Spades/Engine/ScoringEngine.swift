import Foundation

struct ScoringEngine {

    struct RoundResult {
        let teamScoreDeltas: [Int: Int]
        let teamBagDeltas: [Int: Int]
        let nilResults: [PlayerPosition: Bool]
        let bagPenalties: [Int: Bool]
    }

    func scoreRound(players: [Player], teams: [Team]) -> RoundResult {
        var teamScoreDeltas: [Int: Int] = [0: 0, 1: 0]
        var teamBagDeltas: [Int: Int] = [0: 0, 1: 0]
        var nilResults: [PlayerPosition: Bool] = [:]
        var bagPenalties: [Int: Bool] = [0: false, 1: false]

        for team in teams {
            let teamPlayers = team.playerPositions.map { pos in
                players.first(where: { $0.id == pos })!
            }

            // Handle nil bidders separately
            var nilScoreAdjustment = 0
            var nonNilBid = 0
            var nonNilTricks = 0

            for player in teamPlayers {
                guard let bid = player.bid else { continue }

                if bid == 0 {
                    // Nil bid
                    if player.tricksWon == 0 {
                        nilScoreAdjustment += GameConstants.nilBonus
                        nilResults[player.id] = true
                    } else {
                        nilScoreAdjustment -= GameConstants.nilBonus
                        nilResults[player.id] = false
                    }
                } else {
                    nonNilBid += bid
                    nonNilTricks += player.tricksWon
                }
            }

            // Score non-nil portion of the team
            var teamScore = nilScoreAdjustment
            var roundBags = 0

            if nonNilBid > 0 {
                if nonNilTricks >= nonNilBid {
                    // Made the bid
                    teamScore += nonNilBid * 10
                    let overtricks = nonNilTricks - nonNilBid
                    teamScore += overtricks
                    roundBags = overtricks
                } else {
                    // Set (broke) — didn't make bid
                    teamScore -= nonNilBid * 10
                }
            }

            teamScoreDeltas[team.id] = teamScore
            teamBagDeltas[team.id] = roundBags

            // Check for bag penalty
            let totalBagsAfter = team.bags + roundBags
            if totalBagsAfter >= GameConstants.bagPenaltyThreshold {
                bagPenalties[team.id] = true
            }
        }

        return RoundResult(
            teamScoreDeltas: teamScoreDeltas,
            teamBagDeltas: teamBagDeltas,
            nilResults: nilResults,
            bagPenalties: bagPenalties
        )
    }
}
