import Foundation

/*
guard let fileURL = Bundle.main.url(forResource: "input", withExtension: "txt") else {
    print("can't locate file")
    exit(1)
}
 
guard let input = try? String(contentsOfFile: fileURL.path()) else {
    print("can't read file")
    exit(1)
}
 */

let filePath = "/Users/filipkirschner/Projects/aoc22/AdventOfCode.playground/Resources/input.txt"

guard let input = try? String(contentsOfFile: filePath) else {
    print("can't read file")
    exit(1)
}

enum State: String {
    case floor = "."
    case wall = "#"
    case meaninglessVoidWeAllFeelInside = " "
    case mark = "X"
}

enum Direction: Int {
    case up = 3
    case right = 0
    case down = 1
    case left = 2
    
    func rotate(_ direction: String) -> Direction {
        if direction == "R" { return Direction(rawValue: (self.rawValue + 1)%4)! }
        else { return Direction(rawValue: (self.rawValue - 1 + 4)%4)! }
    }
}

let data = input.split(separator: "\n\n").map({ String($0) })
var longestRowLength = 0
let mapData = data[0].split(separator: "\n").map({ row in
    let rowString = String(row)
    longestRowLength = max(longestRowLength, rowString.count)
    return rowString
})
var playingField = [[State]](repeating: [State](repeating: .meaninglessVoidWeAllFeelInside, count: longestRowLength), count: mapData.count)
// We need the last distance
var navigationDataString = data[1]
navigationDataString.removeLast()
navigationDataString.append("X")
let navigationData = navigationDataString.groups(for: "(\\d+)([RLX])").map({ ($0[1], $0[2]) })
// print(navigationData)

func printPlayingField() {
    for row in playingField {
        var rowString = ""
        for col in row {
            rowString += col.rawValue
        }
        print(rowString)
    }
}

for row in mapData.enumerated() {
    for column in row.element.enumerated() {
        playingField[row.offset][column.offset] = State(rawValue: String(column.element))!
    }
}

var currentIndex: (Int, Int) = (0, playingField[0].firstIndex(where: { $0 == .floor })!)
var currentDirection = Direction.right

var cubeSize = playingField.count / 4

struct Transition {
    let condition: (Int, Int) -> Bool
    let transition: (Int, Int) -> (Int, Int)
    let newDirection: Direction
}

// Left
let leftTransitions = [
    Transition(condition: { $0 < 50 && $1 == 50 }, transition: { r, c in return (149 - r, 0) }, newDirection: .right),
    Transition(condition: { $0 >= 50 && $0 < 100 && $1 == 50 }, transition: { r, c in return (100, r - 50) }, newDirection: .down),
    Transition(condition: { $0 >= 100 && $0 < 150 && $1 == 0 }, transition: { r, c in return (149 - r, 50) }, newDirection: .right),
    Transition(condition: { $0 >= 150 && $1 == 0 }, transition: { r, c in return (0, r - 100) }, newDirection: .down)
]
// Right
let rightTransitions = [
    Transition(condition: { $0 < 50 && $1 == 149 }, transition: { r, c in return (149 - r, 99) }, newDirection: .left),
    Transition(condition: { $0 >= 50 && $0 < 100 && $1 == 99 }, transition: { r, c in return (49, 100 + (r - 50)) }, newDirection: .up),
    Transition(condition: { $0 >= 100 && $0 < 150 && $1 == 99 }, transition: { r, c in return (49 - (r - 100), 149) }, newDirection: .left),
    Transition(condition: { $0 >= 150 && $1 == 49 }, transition: { r, c in return (149, 50 + (r - 150)) }, newDirection: .up)
]
// Up
let upTransitions = [
    Transition(condition: { $0 == 100 && $1 < 50 }, transition: { r, c in return (50 + c, 50) }, newDirection: .right),
    Transition(condition: { $0 == 0 && $1 >= 50 && $1 < 100 }, transition: { r, c in return (150 + (c - 50), 0) }, newDirection: .right),
    Transition(condition: { $0 == 0 && $1 >= 100 }, transition: { r, c in return (199, c - 100) }, newDirection: .up),
]
// Down
let downTransitions = [
    Transition(condition: { $0 == 199 && $1 < 50 }, transition: { r, c in return (0, c + 100) }, newDirection: .down),
    Transition(condition: { $0 == 149 && $1 >= 50 && $1 < 100 }, transition: { r, c in return (150 + (c - 50), 49) }, newDirection: .left),
    Transition(condition: { $0 == 49 && $1 >= 100 }, transition: { r, c in return (50 + (c - 100), 99) }, newDirection: .left),
]

let transitions: [Direction: [Transition]] = [
    .up: upTransitions,
    .down: downTransitions,
    .left: leftTransitions,
    .right: rightTransitions
]

func nextIndexOnCube(from index: (Int, Int), in direction: Direction) -> ((Int, Int), Direction) {
    var result: ((Int, Int), Direction)!
    switch(direction) {
        case .up: result = (((index.0+playingField.count - 1) % playingField.count, index.1), direction)
        case .right: result = ((index.0, (index.1 + 1) % playingField[0].count), direction)
        case .down: result = (((index.0 + 1) % playingField.count, index.1), direction)
        case .left: result = ((index.0, (index.1+playingField[0].count - 1) % playingField[0].count), direction)
    }
    // print(result!)
    if playingField[result.0.0][result.0.1] == .meaninglessVoidWeAllFeelInside {
        // Transition to different face
        for transition in transitions[direction]! {
            if transition.condition(index.0, index.1) {
                // print("transition for direction \(direction)")
                return (transition.transition(index.0, index.1), transition.newDirection)
            }
        }
        print("error, unable to find transition for \(index) \(direction)")
        return (index, direction)
    }
    return result
}

/*
playingField[49][100] = .mark
let markIndex = nextIndexOnCube(from: (49, 100), in: .down)
playingField[markIndex.0.0][markIndex.0.1] = .mark
printPlayingField()
*/

var currentIntermediateIndex: (Int, Int)? = currentIndex

for navigationDatum in navigationData {
    var stepsLeftToGo = Int(navigationDatum.0)!
    let directionChangeString = navigationDatum.1
    while(stepsLeftToGo > 0) {
        let next = nextIndexOnCube(from: currentIndex, in: currentDirection)
        let nextStep = next.0
        let nextDirection = next.1
        let state = playingField[nextStep.0][nextStep.1]
        if state == .wall {
            break
        } else if state == .floor {
            stepsLeftToGo -= 1
            currentIndex = nextStep
            currentDirection = nextDirection
        } else {
            print("problem at \(currentIndex) next index \(nextStep.0), current direction \(currentDirection)")
            break
        }
    }
    if directionChangeString == "X" {
        break
    } else {
        currentDirection = currentDirection.rotate(directionChangeString)
    }
    //print(currentIndex)
    // print(currentDirection)
    // printPlayingField()
}

print((currentIndex.0+1) * 1000 + (currentIndex.1+1) * 4 + currentDirection.rawValue)

// 30314 is too low
// 43292 is too high
