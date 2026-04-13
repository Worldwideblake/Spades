import Foundation

struct Team: Identifiable {
    let id: Int
    let playerPositions: [PlayerPosition]

    var totalScore: Int = 0
    var bags: Int = 0

    var displayName: String {
        id == 0 ? "You & North" : "West & East"
    }

    static func defaultTeams() -> [Team] {
        [
            Team(id: 0, playerPositions: [.bottom, .top]),
            Team(id: 1, playerPositions: [.left, .right])
        ]
    }
}
