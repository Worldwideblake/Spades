import Foundation

struct BotAI {

    // MARK: - Bidding

    func chooseBid(hand: [Card], position: PlayerPosition, partnerBid: Int?) -> Int {
        var trickEstimate: Double = 0

        let spades = hand.filter { $0.isSpade }
        let nonSpades = hand.filter { !$0.isSpade }

        // Count high spades
        for card in spades {
            switch card.rank {
            case .ace: trickEstimate += 1.0
            case .king: trickEstimate += 0.9
            case .queen: trickEstimate += 0.7
            case .jack: trickEstimate += 0.4
            default: break
            }
        }

        // Long spade suit bonus
        if spades.count >= 5 {
            trickEstimate += Double(spades.count - 4) * 0.5
        }

        // Count high cards in side suits
        let suitGroups = Dictionary(grouping: nonSpades, by: { $0.suit })
        for (_, cards) in suitGroups {
            let sorted = cards.sorted(by: { $0.rank > $1.rank })
            let length = sorted.count

            for (index, card) in sorted.enumerated() {
                switch card.rank {
                case .ace:
                    trickEstimate += 1.0
                case .king:
                    trickEstimate += length >= 2 ? 0.8 : 0.3
                case .queen:
                    trickEstimate += length >= 3 ? 0.5 : 0.1
                default:
                    break
                }
                if index >= 2 { break }
            }
        }

        // Void suit bonus (can trump)
        let suitsInHand = Set(hand.map { $0.suit })
        let voidSuits = Suit.allCases.filter { !suitsInHand.contains($0) && $0 != .spades }
        if !spades.isEmpty {
            trickEstimate += Double(voidSuits.count) * 0.7
        }

        let bid = max(1, Int(trickEstimate.rounded()))
        return min(bid, 13)
    }

    // MARK: - Card Play

    func chooseCard(
        hand: [Card],
        trick: Trick,
        legalPlays: [Card],
        spadesAreBroken: Bool,
        teamBid: Int,
        teamTricks: Int,
        myBid: Int,
        myTricks: Int
    ) -> Card {
        guard !legalPlays.isEmpty else { return hand[0] }
        guard legalPlays.count > 1 else { return legalPlays[0] }

        let needTricks = myTricks < myBid

        if trick.isEmpty {
            return chooseLead(legalPlays: legalPlays, needTricks: needTricks)
        }

        return chooseFollow(
            legalPlays: legalPlays,
            trick: trick,
            needTricks: needTricks
        )
    }

    // MARK: - Private

    private func chooseLead(legalPlays: [Card], needTricks: Bool) -> Card {
        if needTricks {
            // Lead highest non-spade, or highest spade if only spades
            let nonSpades = legalPlays.filter { !$0.isSpade }
            if let best = nonSpades.max(by: { $0.rank < $1.rank }) {
                return best
            }
            return legalPlays.max(by: { $0.rank < $1.rank })!
        } else {
            // Lead lowest card to avoid overtricks
            return legalPlays.min(by: { $0.rank < $1.rank })!
        }
    }

    private func chooseFollow(
        legalPlays: [Card],
        trick: Trick,
        needTricks: Bool
    ) -> Card {
        guard let leadSuit = trick.leadSuit else {
            return legalPlays.min(by: { $0.rank < $1.rank })!
        }

        let canFollowSuit = legalPlays.contains(where: { $0.suit == leadSuit })

        if canFollowSuit {
            return chooseFollowSuit(
                legalPlays: legalPlays,
                trick: trick,
                leadSuit: leadSuit,
                needTricks: needTricks
            )
        } else {
            return chooseDiscard(
                legalPlays: legalPlays,
                trick: trick,
                needTricks: needTricks
            )
        }
    }

    private func chooseFollowSuit(
        legalPlays: [Card],
        trick: Trick,
        leadSuit: Suit,
        needTricks: Bool
    ) -> Card {
        let suitCards = legalPlays.filter { $0.suit == leadSuit }

        // Find highest card of lead suit currently in the trick
        let currentBest = trick.plays
            .filter { $0.card.suit == leadSuit }
            .max(by: { $0.card.rank < $1.card.rank })?.card

        // Check if anyone trumped already
        let hasTrump = trick.plays.contains(where: { $0.card.suit == .spades && leadSuit != .spades })

        if hasTrump && leadSuit != .spades {
            // Someone already trumped — can't win by following suit, play lowest
            return suitCards.min(by: { $0.rank < $1.rank })!
        }

        // Cards that can win
        let winners = suitCards.filter { card in
            guard let best = currentBest else { return true }
            return card.rank > best.rank
        }

        if needTricks && !winners.isEmpty {
            // Play lowest winning card
            return winners.min(by: { $0.rank < $1.rank })!
        } else if !winners.isEmpty && !needTricks {
            // Don't need tricks — duck with lowest
            return suitCards.min(by: { $0.rank < $1.rank })!
        } else {
            // Can't win — play lowest
            return suitCards.min(by: { $0.rank < $1.rank })!
        }
    }

    private func chooseDiscard(
        legalPlays: [Card],
        trick: Trick,
        needTricks: Bool
    ) -> Card {
        let spades = legalPlays.filter { $0.isSpade }
        let nonSpades = legalPlays.filter { !$0.isSpade }

        if needTricks && !spades.isEmpty {
            // Trump with lowest spade that beats existing trumps
            let existingTrumps = trick.plays.filter { $0.card.suit == .spades }
            let highestTrump = existingTrumps.max(by: { $0.card.rank < $1.card.rank })?.card

            let winningSpades = spades.filter { card in
                guard let highest = highestTrump else { return true }
                return card.rank > highest.rank
            }

            if let lowestWinner = winningSpades.min(by: { $0.rank < $1.rank }) {
                return lowestWinner
            }
            // Can't beat existing trump — discard lowest non-spade or lowest spade
            if let lowest = nonSpades.min(by: { $0.rank < $1.rank }) {
                return lowest
            }
            return spades.min(by: { $0.rank < $1.rank })!
        }

        // Don't need tricks — discard lowest non-spade
        if let lowest = nonSpades.min(by: { $0.rank < $1.rank }) {
            return lowest
        }
        // Only spades left — play lowest
        return spades.min(by: { $0.rank < $1.rank })!
    }
}
