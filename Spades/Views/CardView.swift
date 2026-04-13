import SwiftUI

struct CardView: View {
    let card: Card
    let isFaceUp: Bool
    var isPlayable: Bool = true
    var scale: CGFloat = 1.0

    private var width: CGFloat { AppTheme.cardWidth * scale }
    private var height: CGFloat { AppTheme.cardHeight * scale }
    private var corner: CGFloat { AppTheme.cardCorner * scale }

    var body: some View {
        ZStack {
            if isFaceUp {
                faceUpCard
            } else {
                faceDownCard
            }
        }
        .frame(width: width, height: height)
        .clipShape(RoundedRectangle(cornerRadius: corner))
        .shadow(color: .black.opacity(0.3), radius: 3 * scale, x: 0, y: 2 * scale)
        .opacity(isPlayable ? 1.0 : 0.45)
    }

    // MARK: - Face Up

    private var faceUpCard: some View {
        ZStack {
            RoundedRectangle(cornerRadius: corner)
                .fill(AppTheme.cardWhite)

            // Top-left rank and suit
            VStack(spacing: 0) {
                Text(card.rank.displayValue)
                    .font(.system(size: 14 * scale, weight: .bold, design: .rounded))
                    .foregroundColor(card.suit.isRed ? AppTheme.suitRed : AppTheme.suitBlack)
                Text(card.suit.symbol)
                    .font(.system(size: 12 * scale))
                    .foregroundColor(card.suit.isRed ? AppTheme.suitRed : AppTheme.suitBlack)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .padding(.leading, 5 * scale)
            .padding(.top, 4 * scale)

            // Center suit symbol
            Text(card.suit.symbol)
                .font(.system(size: 28 * scale))
                .foregroundColor(card.suit.isRed ? AppTheme.suitRed : AppTheme.suitBlack)

            // Bottom-right rank and suit (rotated)
            VStack(spacing: 0) {
                Text(card.rank.displayValue)
                    .font(.system(size: 14 * scale, weight: .bold, design: .rounded))
                    .foregroundColor(card.suit.isRed ? AppTheme.suitRed : AppTheme.suitBlack)
                Text(card.suit.symbol)
                    .font(.system(size: 12 * scale))
                    .foregroundColor(card.suit.isRed ? AppTheme.suitRed : AppTheme.suitBlack)
            }
            .rotationEffect(.degrees(180))
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
            .padding(.trailing, 5 * scale)
            .padding(.bottom, 4 * scale)
        }
    }

    // MARK: - Face Down

    private var faceDownCard: some View {
        ZStack {
            RoundedRectangle(cornerRadius: corner)
                .fill(AppTheme.cardBack)

            RoundedRectangle(cornerRadius: corner - 2 * scale)
                .stroke(AppTheme.secondaryText.opacity(0.3), lineWidth: 1)
                .padding(3 * scale)

            // Subtle center pattern
            Text("♠")
                .font(.system(size: 16 * scale))
                .foregroundColor(AppTheme.secondaryText.opacity(0.2))
        }
    }
}

// MARK: - Mini Card (for opponent hands)

struct MiniCardView: View {
    let isFaceUp: Bool
    var card: Card? = nil

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 4)
                .fill(isFaceUp ? AppTheme.cardWhite : AppTheme.cardBack)
                .frame(width: AppTheme.miniCardWidth, height: AppTheme.miniCardHeight)

            if !isFaceUp {
                RoundedRectangle(cornerRadius: 3)
                    .stroke(AppTheme.secondaryText.opacity(0.2), lineWidth: 0.5)
                    .frame(width: AppTheme.miniCardWidth - 4, height: AppTheme.miniCardHeight - 4)
            }
        }
        .shadow(color: .black.opacity(0.2), radius: 1, x: 0, y: 1)
    }
}
