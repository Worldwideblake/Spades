import SwiftUI

struct ScoreboardOverlayView: View {
    let teams: [Team]
    let roundHistory: [RoundSummary]
    let isGameOver: Bool
    let winningTeam: Int?
    let onContinue: () -> Void
    let onNewGame: () -> Void

    var body: some View {
        ZStack {
            Color.black.opacity(0.6)
                .ignoresSafeArea()

            VStack(spacing: 16) {
                // Header
                if isGameOver {
                    gameOverHeader
                } else {
                    Text("ROUND \(roundHistory.count) COMPLETE")
                        .font(AppTheme.headingFont)
                        .foregroundColor(AppTheme.primaryText)
                        .tracking(1.5)
                }

                // Score columns
                scoreTable

                // Totals
                totalScores

                Spacer().frame(height: 4)

                // Action buttons
                if isGameOver {
                    actionButton(title: "NEW GAME", color: AppTheme.accentColor, action: onNewGame)
                } else {
                    actionButton(title: "NEXT ROUND", color: AppTheme.accentColor, action: onContinue)
                }
            }
            .padding(24)
            .background(
                RoundedRectangle(cornerRadius: AppTheme.overlayCorner)
                    .fill(AppTheme.overlayBackground)
            )
            .padding(.horizontal, 24)
        }
    }

    // MARK: - Game Over Header

    private var gameOverHeader: some View {
        VStack(spacing: 6) {
            Text("GAME OVER")
                .font(AppTheme.headingFont)
                .foregroundColor(AppTheme.primaryText)
                .tracking(2)

            if let winner = winningTeam {
                Text(winner == 0 ? "You Win!" : "Opponents Win")
                    .font(AppTheme.subheadingFont)
                    .foregroundColor(winner == 0 ? AppTheme.accentGreen : AppTheme.warningColor)
            }
        }
    }

    // MARK: - Score Table

    private var scoreTable: some View {
        VStack(spacing: 0) {
            // Header row
            HStack {
                Text("Round")
                    .frame(width: 50, alignment: .leading)
                Spacer()
                Text("US")
                    .foregroundColor(AppTheme.teamOneColor)
                    .frame(width: 70)
                Text("THEM")
                    .foregroundColor(AppTheme.teamTwoColor)
                    .frame(width: 70)
            }
            .font(AppTheme.captionFont)
            .foregroundColor(AppTheme.secondaryText)
            .padding(.bottom, 8)

            Divider()
                .background(AppTheme.secondaryText.opacity(0.3))

            // Round rows
            ScrollView {
                VStack(spacing: 0) {
                    ForEach(roundHistory) { round in
                        roundRow(round)
                    }
                }
            }
            .frame(maxHeight: 200)
        }
    }

    private func roundRow(_ round: RoundSummary) -> some View {
        HStack {
            Text("R\(round.roundNumber)")
                .font(AppTheme.captionFont)
                .foregroundColor(AppTheme.secondaryText)
                .frame(width: 50, alignment: .leading)

            Spacer()

            VStack(spacing: 1) {
                let delta0 = round.teamScoreDeltas[0] ?? 0
                Text(scoreString(delta0))
                    .font(AppTheme.captionFont)
                    .foregroundColor(delta0 >= 0 ? AppTheme.accentGreen : AppTheme.warningColor)

                let bid0 = round.teamBids[0] ?? 0
                let tricks0 = round.teamTricks[0] ?? 0
                Text("\(tricks0)/\(bid0)")
                    .font(AppTheme.tinyFont)
                    .foregroundColor(AppTheme.secondaryText)
            }
            .frame(width: 70)

            VStack(spacing: 1) {
                let delta1 = round.teamScoreDeltas[1] ?? 0
                Text(scoreString(delta1))
                    .font(AppTheme.captionFont)
                    .foregroundColor(delta1 >= 0 ? AppTheme.accentGreen : AppTheme.warningColor)

                let bid1 = round.teamBids[1] ?? 0
                let tricks1 = round.teamTricks[1] ?? 0
                Text("\(tricks1)/\(bid1)")
                    .font(AppTheme.tinyFont)
                    .foregroundColor(AppTheme.secondaryText)
            }
            .frame(width: 70)
        }
        .padding(.vertical, 6)
    }

    // MARK: - Totals

    private var totalScores: some View {
        VStack(spacing: 8) {
            Divider()
                .background(AppTheme.secondaryText.opacity(0.3))

            HStack {
                Text("TOTAL")
                    .font(AppTheme.captionFont)
                    .foregroundColor(AppTheme.secondaryText)
                    .frame(width: 50, alignment: .leading)

                Spacer()

                VStack(spacing: 1) {
                    Text("\(teams[0].totalScore)")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundColor(AppTheme.teamOneColor)
                    Text("\(teams[0].bags) bags")
                        .font(AppTheme.tinyFont)
                        .foregroundColor(AppTheme.secondaryText)
                }
                .frame(width: 70)

                VStack(spacing: 1) {
                    Text("\(teams[1].totalScore)")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundColor(AppTheme.teamTwoColor)
                    Text("\(teams[1].bags) bags")
                        .font(AppTheme.tinyFont)
                        .foregroundColor(AppTheme.secondaryText)
                }
                .frame(width: 70)
            }
        }
    }

    // MARK: - Helpers

    private func scoreString(_ value: Int) -> String {
        value >= 0 ? "+\(value)" : "\(value)"
    }

    private func actionButton(title: String, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 48)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(color)
                )
        }
    }
}
