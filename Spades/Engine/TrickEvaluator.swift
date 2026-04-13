import Foundation

struct TrickEvaluator {

    /// Returns all cards the player can legally play given the current trick state.
    func legalPlays(hand: [Card], trick: Trick, spadesAreBroken: Bool) -> [Card] {
        guard !hand.isEmpty else { return [] }

        // If leading (first play in trick)
        if trick.isEmpty {
            return legalLeads(hand: hand, spadesAreBroken: spadesAreBroken)
        }

        // If following
        guard let leadSuit = trick.leadSuit else { return hand }
        return legalFollows(hand: hand, leadSuit: leadSuit)
    }

    /// Determines which player won the completed trick.
    func trickWinner(trick: Trick) -> PlayerPosition {
        guard let leadSuit = trick.leadSuit else {
            return trick.leadPosition
        }

        // Check if any spades (trump) were played
        let spadePlays = trick.plays.filter { $0.card.suit == .spades }

        if !spadePlays.isEmpty {
            // Highest spade wins
            let winner = spadePlays.max(by: { $0.card.rank < $1.card.rank })!
            return winner.playerPosition
        }

        // No trump played — highest card of lead suit wins
        let leadSuitPlays = trick.plays.filter { $0.card.suit == leadSuit }
        let winner = leadSuitPlays.max(by: { $0.card.rank < $1.card.rank })!
        return winner.playerPosition
    }

    // MARK: - Private

    private func legalLeads(hand: [Card], spadesAreBroken: Bool) -> [Card] {
        if spadesAreBroken {
            return hand
        }

        // Spades not broken — cannot lead spades unless hand is all spades
        let nonSpades = hand.filter { !$0.isSpade }
        if nonSpades.isEmpty {
            // Hand is all spades — must allow leading spades
            return hand
        }
        return nonSpades
    }

    private func legalFollows(hand: [Card], leadSuit: Suit) -> [Card] {
        let suitCards = hand.filter { $0.suit == leadSuit }
        if !suitCards.isEmpty {
            // Must follow suit
            return suitCards
        }
        // Void in lead suit — can play anything (including spades)
        return hand
    }
}
