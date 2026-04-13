import SwiftUI

struct TrickAreaView: View {
    let trick: Trick
    let lastWinner: PlayerPosition?

    var body: some View {
        ZStack {
            // Subtle play area indicator
            RoundedRectangle(cornerRadius: 16)
                .fill(AppTheme.cardAreaBackground.opacity(0.5))
                .frame(width: 180, height: 180)

            // Position labels (subtle)
            positionIndicators

            // Played cards
            ForEach(trick.plays) { play in
                CardView(card: play.card, isFaceUp: true, scale: 0.75)
                    .offset(cardOffset(for: play.playerPosition))
                    .transition(.asymmetric(
                        insertion: .move(edge: insertionEdge(for: play.playerPosition))
                            .combined(with: .opacity),
                        removal: .scale.combined(with: .opacity)
                    ))
            }

            // Winner indicator
            if let winner = lastWinner, trick.isComplete {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 20))
                    .foregroundColor(AppTheme.accentGreen)
                    .offset(cardOffset(for: winner))
                    .offset(y: -30)
                    .transition(.scale.combined(with: .opacity))
            }
        }
        .frame(width: 200, height: 200)
        .animation(.easeInOut(duration: 0.35), value: trick.playCount)
    }

    // MARK: - Card Positioning

    private func cardOffset(for position: PlayerPosition) -> CGSize {
        switch position {
        case .bottom: return CGSize(width: 0, height: 40)
        case .top:    return CGSize(width: 0, height: -40)
        case .left:   return CGSize(width: -48, height: 0)
        case .right:  return CGSize(width: 48, height: 0)
        }
    }

    private func insertionEdge(for position: PlayerPosition) -> Edge {
        switch position {
        case .bottom: return .bottom
        case .top:    return .top
        case .left:   return .leading
        case .right:  return .trailing
        }
    }

    // MARK: - Position Indicators

    private var positionIndicators: some View {
        ZStack {
            ForEach(PlayerPosition.allCases, id: \.self) { pos in
                if trick.card(for: pos) == nil && !trick.isComplete {
                    Circle()
                        .fill(AppTheme.secondaryText.opacity(0.15))
                        .frame(width: 8, height: 8)
                        .offset(dotOffset(for: pos))
                }
            }
        }
    }

    private func dotOffset(for position: PlayerPosition) -> CGSize {
        switch position {
        case .bottom: return CGSize(width: 0, height: 40)
        case .top:    return CGSize(width: 0, height: -40)
        case .left:   return CGSize(width: -48, height: 0)
        case .right:  return CGSize(width: 48, height: 0)
        }
    }
}
