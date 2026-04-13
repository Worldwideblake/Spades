import SwiftUI

@MainActor
final class SpadesGameEngine: ObservableObject {

    // MARK: - Published State

    @Published var players: [Player] = []
    @Published var phase: GamePhase = .notStarted
    @Published var currentTrick: Trick = Trick(leadPosition: .bottom)
    @Published var spadesAreBroken: Bool = false
    @Published var dealerPosition: PlayerPosition = .bottom
    @Published var roundNumber: Int = 0
    @Published var teams: [Team] = Team.defaultTeams()
    @Published var roundHistory: [RoundSummary] = []
    @Published var showScoreboard: Bool = false
    @Published var humanBidSelection: Int = 3
    @Published var lastTrickWinner: PlayerPosition? = nil
    @Published var trickNumber: Int = 0

    // MARK: - Dependencies

    private let deckManager = DeckManager()
    private let trickEvaluator = TrickEvaluator()
    private let scoringEngine = ScoringEngine()
    private let botAI = BotAI()

    private var gameTask: Task<Void, Never>?

    // MARK: - Initialization

    init() {
        setupPlayers()
    }

    // MARK: - Public Methods

    func startNewGame() {
        gameTask?.cancel()
        setupPlayers()
        teams = Team.defaultTeams()
        roundHistory = []
        roundNumber = 0
        dealerPosition = PlayerPosition.allCases.randomElement()!
        startNewRound()
    }

    func submitHumanBid(_ bid: Int) {
        guard case .bidding(let currentBidder) = phase,
              currentBidder == .bottom else { return }

        players[PlayerPosition.bottom.rawValue].bid = bid
        advanceBidding(from: .bottom)
    }

    func playHumanCard(_ card: Card) {
        guard case .playing(let currentPlayer) = phase,
              currentPlayer == .bottom else { return }

        let legal = legalPlaysForHuman()
        guard legal.contains(card) else { return }

        playCard(card, for: .bottom)
    }

    func legalPlaysForHuman() -> [Card] {
        let human = players[PlayerPosition.bottom.rawValue]
        return trickEvaluator.legalPlays(
            hand: human.hand,
            trick: currentTrick,
            spadesAreBroken: spadesAreBroken
        )
    }

    func isLegalPlay(_ card: Card) -> Bool {
        legalPlaysForHuman().contains(card)
    }

    func continueAfterScoreboard() {
        showScoreboard = false
        if case .gameOver = phase {
            // Stay on game over
            return
        }
        startNewRound()
    }

    func startNewGameAfterGameOver() {
        startNewGame()
    }

    // MARK: - Player for Position

    func player(at position: PlayerPosition) -> Player {
        players[position.rawValue]
    }

    func team(for position: PlayerPosition) -> Team {
        teams[position.teamId]
    }

    func partnerBid(for position: PlayerPosition) -> Int? {
        players[position.partner.rawValue].bid
    }

    // MARK: - Private: Setup

    private func setupPlayers() {
        players = PlayerPosition.allCases.map { Player(position: $0) }
    }

    // MARK: - Private: Round Lifecycle

    private func startNewRound() {
        roundNumber += 1
        spadesAreBroken = false
        trickNumber = 0
        lastTrickWinner = nil

        for i in players.indices {
            players[i].resetForNewRound()
        }

        // Deal cards
        let deck = deckManager.createShuffledDeck()
        let hands = deckManager.deal(deck: deck)
        for (index, hand) in hands.enumerated() {
            players[index].hand = hand
        }

        // Start bidding from left of dealer
        let firstBidder = dealerPosition.next
        phase = .bidding(currentBidder: firstBidder)

        if !firstBidder.isHuman {
            scheduleBotBid(for: firstBidder)
        }
    }

    // MARK: - Private: Bidding

    private func advanceBidding(from position: PlayerPosition) {
        let nextBidder = position.next

        // Check if all players have bid
        if players.allSatisfy({ $0.hasBid }) {
            startPlayPhase()
            return
        }

        phase = .bidding(currentBidder: nextBidder)

        if !nextBidder.isHuman {
            scheduleBotBid(for: nextBidder)
        }
    }

    private func scheduleBotBid(for position: PlayerPosition) {
        gameTask?.cancel()
        gameTask = Task { [weak self] in
            try? await Task.sleep(nanoseconds: GameConstants.botThinkDelay)
            guard !Task.isCancelled else { return }
            await self?.performBotBid(for: position)
        }
    }

    private func performBotBid(for position: PlayerPosition) {
        let hand = players[position.rawValue].hand
        let partner = partnerBid(for: position)
        let bid = botAI.chooseBid(hand: hand, position: position, partnerBid: partner)
        players[position.rawValue].bid = bid
        advanceBidding(from: position)
    }

    // MARK: - Private: Play Phase

    private func startPlayPhase() {
        // Leader is left of dealer
        let leader = dealerPosition.next
        trickNumber = 1
        currentTrick = Trick(leadPosition: leader)
        phase = .playing(currentPlayer: leader)

        if !leader.isHuman {
            scheduleBotPlay(for: leader)
        }
    }

    private func playCard(_ card: Card, for position: PlayerPosition) {
        // Remove card from hand
        players[position.rawValue].hand.removeAll(where: { $0 == card })

        // Check if spades are broken
        if card.isSpade && currentTrick.leadSuit != nil && currentTrick.leadSuit != .spades {
            spadesAreBroken = true
        }
        // Also broken if spades are led (when all hand was spades)
        if card.isSpade && currentTrick.isEmpty {
            spadesAreBroken = true
        }

        // Add to trick
        currentTrick.plays.append(TrickPlay(playerPosition: position, card: card))

        // Check if trick is complete
        if currentTrick.isComplete {
            completeTrick()
        } else {
            let nextPlayer = position.next
            phase = .playing(currentPlayer: nextPlayer)
            if !nextPlayer.isHuman {
                scheduleBotPlay(for: nextPlayer)
            }
        }
    }

    private func scheduleBotPlay(for position: PlayerPosition) {
        gameTask?.cancel()
        gameTask = Task { [weak self] in
            try? await Task.sleep(nanoseconds: GameConstants.botThinkDelay)
            guard !Task.isCancelled else { return }
            await self?.performBotPlay(for: position)
        }
    }

    private func performBotPlay(for position: PlayerPosition) {
        let hand = players[position.rawValue].hand
        let legal = trickEvaluator.legalPlays(
            hand: hand,
            trick: currentTrick,
            spadesAreBroken: spadesAreBroken
        )

        let teamId = position.teamId
        let teamPlayers = teams[teamId].playerPositions.map { players[$0.rawValue] }
        let teamBid = teamPlayers.compactMap(\.bid).reduce(0, +)
        let teamTricks = teamPlayers.map(\.tricksWon).reduce(0, +)
        let myBid = players[position.rawValue].bid ?? 1
        let myTricks = players[position.rawValue].tricksWon

        let card = botAI.chooseCard(
            hand: hand,
            trick: currentTrick,
            legalPlays: legal,
            spadesAreBroken: spadesAreBroken,
            teamBid: teamBid,
            teamTricks: teamTricks,
            myBid: myBid,
            myTricks: myTricks
        )

        playCard(card, for: position)
    }

    // MARK: - Private: Trick Resolution

    private func completeTrick() {
        let winner = trickEvaluator.trickWinner(trick: currentTrick)
        players[winner.rawValue].tricksWon += 1
        lastTrickWinner = winner
        phase = .trickWon(winner: winner)

        gameTask?.cancel()
        gameTask = Task { [weak self] in
            try? await Task.sleep(nanoseconds: GameConstants.trickAnimationDelay)
            guard !Task.isCancelled else { return }
            await self?.afterTrickAnimation(winner: winner)
        }
    }

    private func afterTrickAnimation(winner: PlayerPosition) {
        // Check if round is over (all cards played)
        if players[0].hand.isEmpty {
            endRound()
            return
        }

        // Start new trick, winner leads
        trickNumber += 1
        currentTrick = Trick(leadPosition: winner)
        phase = .playing(currentPlayer: winner)

        if !winner.isHuman {
            scheduleBotPlay(for: winner)
        }
    }

    // MARK: - Private: Scoring

    private func endRound() {
        let result = scoringEngine.scoreRound(players: players, teams: teams)

        // Apply score deltas
        for teamId in [0, 1] {
            teams[teamId].totalScore += result.teamScoreDeltas[teamId] ?? 0
            let newBags = result.teamBagDeltas[teamId] ?? 0
            teams[teamId].bags += newBags

            // Apply bag penalty
            if result.bagPenalties[teamId] == true {
                teams[teamId].totalScore += GameConstants.bagPenalty
                teams[teamId].bags -= GameConstants.bagPenaltyThreshold
            }
        }

        // Sync team scores to players
        for position in PlayerPosition.allCases {
            players[position.rawValue].totalScore = teams[position.teamId].totalScore
            players[position.rawValue].bags = teams[position.teamId].bags
        }

        // Build round summary
        var teamBids: [Int: Int] = [:]
        var teamTricks: [Int: Int] = [:]
        for team in teams {
            let tp = team.playerPositions.map { players[$0.rawValue] }
            teamBids[team.id] = tp.compactMap(\.bid).reduce(0, +)
            teamTricks[team.id] = tp.map(\.tricksWon).reduce(0, +)
        }

        let summary = RoundSummary(
            roundNumber: roundNumber,
            teamBids: teamBids,
            teamTricks: teamTricks,
            teamScoreDeltas: result.teamScoreDeltas,
            teamBagDeltas: result.teamBagDeltas,
            nilResults: result.nilResults
        )
        roundHistory.append(summary)

        // Check for game over
        let winningTeam = teams.first(where: { $0.totalScore >= GameConstants.winningScore })
        let losingTeam = teams.first(where: { $0.totalScore <= -200 })

        if let winner = winningTeam {
            phase = .gameOver(winningTeam: winner.id)
        } else if let loser = losingTeam {
            let winnerId = loser.id == 0 ? 1 : 0
            phase = .gameOver(winningTeam: winnerId)
        } else {
            // Rotate dealer and show scoreboard
            dealerPosition = dealerPosition.next
            phase = .roundEnd
            showScoreboard = true
        }
    }
}
