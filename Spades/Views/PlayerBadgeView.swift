import SwiftUI

struct PlayerBadgeView: View {
    let player: Player
    let isCurrentTurn: Bool
    let compact: Bool

    init(player: Player, isCurrentTurn: Bool, compact: Bool = false) {
        self.player = player
        self.isCurrentTurn = isCurrentTurn
        self.compact = compact
    }

    var body: some View {
        VStack(spacing: compact ? 3 : 5) {
            // Player name
            Text(player.name)
                .font(compact ? AppTheme.tinyFont : AppTheme.playerNameFont)
                .foregroundColor(isCurrentTurn ? AppTheme.accentColor : AppTheme.primaryText)

            // Stats row
            HStack(spacing: compact ? 6 : 10) {
                StatPill(label: "Bid", value: bidDisplay, compact: compact)
                StatPill(label: "Won", value: "\(player.tricksWon)", compact: compact)
            }
        }
        .padding(.horizontal, compact ? 6 : 10)
        .padding(.vertical, compact ? 4 : 7)
        .background(
            RoundedRectangle(cornerRadius: AppTheme.badgeCorner)
                .fill(AppTheme.badgeBackground)
                .overlay(
                    RoundedRectangle(cornerRadius: AppTheme.badgeCorner)
                        .stroke(
                            isCurrentTurn ? AppTheme.accentColor.opacity(0.6) : Color.clear,
                            lineWidth: 1.5
                        )
                )
        )
    }

    private var bidDisplay: String {
        guard let bid = player.bid else { return "-" }
        return bid == 0 ? "Nil" : "\(bid)"
    }
}

// MARK: - Stat Pill

struct StatPill: View {
    let label: String
    let value: String
    var compact: Bool = false

    var body: some View {
        VStack(spacing: 1) {
            Text(label)
                .font(compact ? .system(size: 7, weight: .medium) : AppTheme.tinyFont)
                .foregroundColor(AppTheme.secondaryText)
            Text(value)
                .font(compact ? .system(size: 11, weight: .bold, design: .rounded) : AppTheme.playerNameFont)
                .foregroundColor(value == "Nil" ? AppTheme.warningColor : AppTheme.primaryText)
        }
    }
}

// MARK: - Score Banner

struct ScoreBannerView: View {
    let teams: [Team]

    var body: some View {
        HStack(spacing: 16) {
            teamScore(team: teams[0], label: "US", color: AppTheme.teamOneColor)

            Rectangle()
                .fill(AppTheme.secondaryText.opacity(0.3))
                .frame(width: 1, height: 24)

            teamScore(team: teams[1], label: "THEM", color: AppTheme.teamTwoColor)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: AppTheme.badgeCorner)
                .fill(AppTheme.surfaceColor)
        )
    }

    private func teamScore(team: Team, label: String, color: Color) -> some View {
        VStack(spacing: 2) {
            Text(label)
                .font(AppTheme.tinyFont)
                .foregroundColor(AppTheme.secondaryText)
            Text("\(team.totalScore)")
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundColor(color)
            if team.bags > 0 {
                Text("\(team.bags) bags")
                    .font(.system(size: 8, weight: .medium))
                    .foregroundColor(AppTheme.secondaryText)
            }
        }
        .frame(minWidth: 50)
    }
}
