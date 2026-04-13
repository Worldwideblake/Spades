import Foundation

struct DeckManager {
    func createShuffledDeck() -> [Card] {
        var deck = Card.fullDeck()
        deck.shuffle()
        return deck
    }

    func deal(deck: [Card]) -> [[Card]] {
        var hands: [[Card]] = [[], [], [], []]
        for (index, card) in deck.enumerated() {
            hands[index % 4].append(card)
        }
        return hands.map { $0.sorted() }
    }
}
