import SwiftUI

struct PlayerHandView: View {
    let cards: [Card]
    let legalCards: Set<Card>
    let isActive: Bool
    let onCardTapped: (Card) -> Void

    @State private var selectedCard: Card? = nil

    private let maxSpread: Double = 40
    private let maxYOffset: CGFloat = 25

    var body: some View {
        GeometryReader { geo in
            let cardWidth = adjustedCardWidth(screenWidth: geo.size.width)
            let scale = cardWidth / AppTheme.cardWidth

            ZStack {
                ForEach(Array(cards.enumerated()), id: \.element.id) { index, card in
                    let isLegal = legalCards.contains(card)
                    let isSelected = selectedCard == card

                    CardView(
                        card: card,
                        isFaceUp: true,
                        isPlayable: isActive ? isLegal : true,
                        scale: scale
                    )
                    .rotationEffect(
                        rotationAngle(for: index),
                        anchor: .bottom
                    )
                    .offset(y: yOffset(for: index) + (isSelected ? -35 : 0))
                    .zIndex(Double(index) + (isSelected ? 100 : 0))
                    .onTapGesture {
                        guard isActive && isLegal else { return }
                        withAnimation(.spring(response: 0.25, dampingFraction: 0.7)) {
                            if selectedCard == card {
                                // Confirm play
                                selectedCard = nil
                                onCardTapped(card)
                            } else {
                                selectedCard = card
                            }
                        }
                    }
                    .animation(.spring(response: 0.3, dampingFraction: 0.8), value: isSelected)
                }
            }
            .frame(width: geo.size.width, height: geo.size.height)
            .position(x: geo.size.width / 2, y: geo.size.height / 2 + 20)
        }
        .frame(height: 140)
        .onChange(of: cards.count) { _ in
            selectedCard = nil
        }
    }

    // MARK: - Layout Math

    private func adjustedCardWidth(screenWidth: CGFloat) -> CGFloat {
        let count = CGFloat(cards.count)
        if count <= 7 { return AppTheme.cardWidth }
        let available = screenWidth * 0.85
        let overlap = available / count
        return min(AppTheme.cardWidth, max(45, overlap))
    }

    private func rotationAngle(for index: Int) -> Angle {
        let count = Double(cards.count)
        guard count > 1 else { return .zero }
        let totalSpread = min(maxSpread, count * 4)
        let step = totalSpread / (count - 1)
        let angle = -totalSpread / 2 + step * Double(index)
        return .degrees(angle)
    }

    private func yOffset(for index: Int) -> CGFloat {
        let count = Double(cards.count)
        guard count > 1 else { return 0 }
        let normalized = (Double(index) / (count - 1)) * 2 - 1
        return CGFloat(normalized * normalized) * maxYOffset
    }
}
