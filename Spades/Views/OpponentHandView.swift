import SwiftUI

struct OpponentHandView: View {
    let cardCount: Int
    let position: PlayerPosition

    var body: some View {
        switch position {
        case .top:
            horizontalHand
        case .left:
            verticalHand
        case .right:
            verticalHand
        default:
            EmptyView()
        }
    }

    // MARK: - Horizontal (Top Player)

    private var horizontalHand: some View {
        HStack(spacing: -18) {
            ForEach(0..<displayCount, id: \.self) { index in
                MiniCardView(isFaceUp: false)
                    .rotationEffect(.degrees(fanAngle(index: index, count: displayCount, maxAngle: 15)))
            }
        }
        .overlay(alignment: .trailing) {
            if cardCount > 0 {
                countBadge
                    .offset(x: 20)
            }
        }
    }

    // MARK: - Vertical (Left/Right Players)

    private var verticalHand: some View {
        VStack(spacing: -28) {
            ForEach(0..<displayCount, id: \.self) { index in
                MiniCardView(isFaceUp: false)
                    .rotationEffect(.degrees(90))
                    .rotationEffect(.degrees(fanAngle(index: index, count: displayCount, maxAngle: 12)))
            }
        }
        .overlay(alignment: .bottom) {
            if cardCount > 0 {
                countBadge
                    .offset(y: 16)
            }
        }
    }

    // MARK: - Helpers

    private var displayCount: Int {
        min(cardCount, 7)
    }

    private var countBadge: some View {
        Text("\(cardCount)")
            .font(AppTheme.tinyFont)
            .foregroundColor(AppTheme.secondaryText)
            .padding(.horizontal, 5)
            .padding(.vertical, 2)
            .background(AppTheme.badgeBackground)
            .clipShape(Capsule())
    }

    private func fanAngle(index: Int, count: Int, maxAngle: Double) -> Double {
        guard count > 1 else { return 0 }
        let step = maxAngle / Double(count - 1)
        return -maxAngle / 2 + step * Double(index)
    }
}
