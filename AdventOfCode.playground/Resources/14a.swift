import UIKit

guard let fileURL = Bundle.main.url(forResource: "input", withExtension: "txt") else {
    print("can't locate file")
    exit(1)
}

guard let input = try? String(contentsOfFile: fileURL.path()) else {
    print("can't read file")
    exit(1)
}

let rockFormationRows = input.split(separator: "\n").map({ String($0) })

var rockFormations: [[(column: Int, row: Int)]] = []

var minColumn = 500
var maxColumn = 500
var maxRow = 0

for rockFormationRow in rockFormationRows {
    let rockPoints = rockFormationRow.split(separator: " -> ").map({ String($0) })
    var rockFormation: [(column: Int, row: Int)] = []
    for rockPoint in rockPoints {
        let rockCoordinates = rockPoint.split(separator: ",").map({ String($0) })
        let column = Int(rockCoordinates[0])!
        minColumn = min(minColumn, column)
        maxColumn = max(maxColumn, column)
        let row = Int(rockCoordinates[1])!
        maxRow = max(maxRow, row)
        rockFormation.append((column: column, row: row))
    }
    rockFormations.append(rockFormation)
}

enum State: Character {
    case rock = "#"
    case air = "."
    case sand = "o"
    case sandSource = "+"
}

print(minColumn)
print(maxColumn)
print(maxRow)

var gameBoard: [[State]] = []

func transformedColumn(_ column: Int) -> Int { return column - minColumn }

for i in 0...maxRow {
    gameBoard.append([])
    for _ in 0...(transformedColumn(maxColumn)) {
        gameBoard[i].append(.air)
    }
}

gameBoard[0][transformedColumn(500)] = .sandSource

for formation in rockFormations {
    var previousPoint = formation.first!
    for point in formation {
        for row in min(previousPoint.row, point.row)...max(previousPoint.row, point.row) {
            for column in min(previousPoint.column, point.column)...max(previousPoint.column, point.column) {
                gameBoard[row][transformedColumn(column)] = .rock
            }
        }
        previousPoint = point
    }
}

func printBoard() {
    for row in gameBoard {
        var rowString = ""
        for column in row {
            rowString += String(column.rawValue)
        }
        print(rowString)
    }
    print("\n\n\n")
}

var currentSandParticle = 0
while(true) {
    currentSandParticle += 1
    var currentRow = 0
    var currentColumn = transformedColumn(500)
    var inMotion = true
    while (true) {
        if (currentRow == maxRow) { break }
        let below = gameBoard[currentRow+1][currentColumn]
        if (below == .air) {
            currentRow += 1
            continue
        }
        // We need to move left diagonally
        if (currentColumn == 0) { break }
        let leftDiag = gameBoard[currentRow+1][currentColumn-1]
        if (leftDiag == .air) {
            currentRow += 1
            currentColumn -= 1
            continue
        }
        // We need to move right diagonally
        if (currentColumn == (gameBoard[0].count - 1)) { break }
        let rightDiag = gameBoard[currentRow+1][currentColumn+1]
        if (rightDiag == .air) {
            currentRow += 1
            currentColumn += 1
            continue
        }
        // We stay on current spot
        inMotion = false
        gameBoard[currentRow][currentColumn] = .sand
        break
    }
    if (currentSandParticle % 100 == 0) {
        printBoard()
    }
    if (!inMotion) { continue }
    print("end state \(currentRow), \(currentColumn), \(inMotion)")
    if (currentRow == maxRow || currentColumn == 0 || currentColumn == gameBoard[0].count-1) { break }
}
