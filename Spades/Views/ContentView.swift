import SwiftUI

struct ContentView: View {
    @StateObject private var engine = SpadesGameEngine()

    var body: some View {
        ZStack {
            // Background
            AppTheme.backgroundColor
                .ignoresSafeArea()

            // Main game layout
            gameLayout

            // Overlays
            overlays
        }
        .onAppear {
            engine.startNewGame()
        }
    }

    // MARK: - Game Layout

    private var gameLayout: some View {
        VStack(spacing: 0) {
            // Score banner at top
            ScoreBannerView(teams: engine.teams)
                .padding(.top, 8)

            // Top player area
            topPlayerArea
                .padding(.top, 4)

            Spacer(minLength: 0)

            // Middle row: Left player - Trick Area - Right player
            middleRow

            Spacer(minLength: 0)

            // Bottom: Human's info and hand
            bottomPlayerArea
        }
        .padding(.horizontal, 8)
    }

    // MARK: - Top Player

    private var topPlayerArea: some View {
        VStack(spacing: 6) {
            PlayerBadgeView(
                player: engine.player(at: .top),
                isCurrentTurn: engine.phase.currentPlayerPosition == .top,
                compact: true
            )
            OpponentHandView(cardCount: engine.player(at: .top).hand.count, position: .top)
        }
    }

    // MARK: - Middle Row

    private var middleRow: some View {
        HStack(spacing: 0) {
            // Left player
            VStack(spacing: 6) {
                PlayerBadgeView(
                    player: engine.player(at: .left),
                    isCurrentTurn: engine.phase.currentPlayerPosition == .left,
                    compact: true
                )
                OpponentHandView(cardCount: engine.player(at: .left).hand.count, position: .left)
            }
            .frame(width: 80)

            Spacer(minLength: 0)

            // Trick area (center)
            TrickAreaView(trick: engine.currentTrick, lastWinner: engine.lastTrickWinner)

            Spacer(minLength: 0)

            // Right player
            VStack(spacing: 6) {
                PlayerBadgeView(
                    player: engine.player(at: .right),
                    isCurrentTurn: engine.phase.currentPlayerPosition == .right,
                    compact: true
                )
                OpponentHandView(cardCount: engine.player(at: .right).hand.count, position: .right)
            }
            .frame(width: 80)
        }
    }

    // MARK: - Bottom Player

    private var bottomPlayerArea: some View {
        VStack(spacing: 6) {
            // Turn indicator
            if case .playing(let pos) = engine.phase, pos == .bottom {
                Text("YOUR TURN")
                    .font(AppTheme.captionFont)
                    .foregroundColor(AppTheme.accentColor)
                    .tracking(1)
                    .transition(.opacity)
            }

            // Player badge
            PlayerBadgeView(
                player: engine.player(at: .bottom),
                isCurrentTurn: engine.phase.currentPlayerPosition == .bottom
            )

            // Human's hand
            PlayerHandView(
                cards: engine.player(at: .bottom).hand,
                legalCards: Set(engine.legalPlaysForHuman()),
                isActive: isHumanTurnToPlay,
                onCardTapped: { card in
                    engine.playHumanCard(card)
                }
            )
            .padding(.bottom, 8)
        }
    }

    // MARK: - Overlays

    @ViewBuilder
    private var overlays: some View {
        // Bidding overlay
        if case .bidding(let pos) = engine.phase, pos == .bottom {
            BiddingOverlayView(
                selectedBid: $engine.humanBidSelection,
                partnerBid: engine.partnerBid(for: .bottom),
                onSubmit: { bid in
                    engine.submitHumanBid(bid)
                }
            )
            .transition(.opacity.combined(with: .scale(scale: 0.95)))
            .animation(.easeInOut(duration: 0.25), value: engine.phase.isBidding)
        }

        // Scoreboard overlay
        if engine.showScoreboard || isGameOver {
            ScoreboardOverlayView(
                teams: engine.teams,
                roundHistory: engine.roundHistory,
                isGameOver: isGameOver,
                winningTeam: gameOverWinningTeam,
                onContinue: { engine.continueAfterScoreboard() },
                onNewGame: { engine.startNewGameAfterGameOver() }
            )
            .transition(.opacity.combined(with: .scale(scale: 0.95)))
            .animation(.easeInOut(duration: 0.3), value: engine.showScoreboard)
        }

        // Bot thinking indicator
        if isBotThinking {
            VStack {
                Spacer()
                HStack(spacing: 6) {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: AppTheme.secondaryText))
                        .scaleEffect(0.7)
                    Text("\(currentBotName) is thinking...")
                        .font(AppTheme.captionFont)
                        .foregroundColor(AppTheme.secondaryText)
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(
                    Capsule()
                        .fill(AppTheme.surfaceColor)
                )
                .padding(.bottom, 160)
            }
            .transition(.opacity)
            .animation(.easeInOut(duration: 0.2), value: isBotThinking)
        }
    }

    // MARK: - Computed Helpers

    private var isHumanTurnToPlay: Bool {
        if case .playing(let pos) = engine.phase, pos == .bottom {
            return true
        }
        return false
    }

    private var isBotThinking: Bool {
        switch engine.phase {
        case .playing(let pos) where !pos.isHuman:
            return true
        case .bidding(let pos) where !pos.isHuman:
            return true
        default:
            return false
        }
    }

    private var currentBotName: String {
        engine.phase.currentPlayerPosition?.displayName ?? ""
    }

    private var isGameOver: Bool {
        if case .gameOver = engine.phase { return true }
        return false
    }

    private var gameOverWinningTeam: Int? {
        if case .gameOver(let team) = engine.phase { return team }
        return nil
    }
}
