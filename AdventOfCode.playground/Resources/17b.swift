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

enum Direction: Int {
    case right = 1
    case left = -1
}

var directions: [Direction] = input.map({ String($0) == ">" ? .right : .left })
directions.removeLast()
print(directions.count)

struct Coordinates {
    let x: Int
    let y: Int
}

enum Shape: Int {
    case horizontal = 0
    case cross = 1
    case reversel = 2
    case vertical = 3
    case square = 4
    
    var coordinates: [Coordinates] {
        switch self {
        case .horizontal:
            return [Coordinates(x: 0, y: 0),
                    Coordinates(x: 1, y: 0),
                    Coordinates(x: 2, y: 0),
                    Coordinates(x: 3, y: 0)]
        case .cross:
            return [Coordinates(x: 1, y: 0),
                    Coordinates(x: 0, y: 1),
                    Coordinates(x: 1, y: 1),
                    Coordinates(x: 2, y: 1),
                    Coordinates(x: 1, y: 2)]
        case .reversel:
            return [Coordinates(x: 2, y: 0),
                    Coordinates(x: 2, y: 1),
                    Coordinates(x: 0, y: 2),
                    Coordinates(x: 1, y: 2),
                    Coordinates(x: 2, y: 2)]
        case .vertical:
            return [Coordinates(x: 0, y: 0),
                    Coordinates(x: 0, y: 1),
                    Coordinates(x: 0, y: 2),
                    Coordinates(x: 0, y: 3)]
        case .square:
            return [Coordinates(x: 0, y: 0),
                    Coordinates(x: 1, y: 0),
                    Coordinates(x: 0, y: 1),
                    Coordinates(x: 1, y: 1)]
        }
    }
    
    var startingRow: Int {
        // Offset is 7 from the highest point
        switch self {
        case .horizontal: return 3
        case .square: return 2
        case .cross, .reversel: return 1
        case .vertical: return 0
        }
    }
    
    static var types: Int {
        return 5
    }
}

enum State {
    case rock
    case air
}

let fieldWidth = 7

var playingField = [[State]](repeating: [State](repeating: .air, count: fieldWidth), count: 7)

func findHighestPoint() -> Int {
    for row in 0..<playingField.count {
        for element in playingField[row] {
            if element == .rock {
                return row
            }
        }
    }
    return playingField.count
}

func adjustPlayingField() {
    let highestPoint = findHighestPoint()
    // if highest point 7, don't do shit
    // if highest point 0, add 7 rows
    for _ in 0..<(7-highestPoint) {
        playingField.insert([State](repeating: .air, count: fieldWidth), at: 0)
    }
}

func printPlayingField() {
    for row in playingField {
        var rowString = ""
        for element in row {
            rowString += element == .air ? "." : "#"
        }
        print(rowString)
    }
    print("\n\n\n")
}

var currentShape = Shape(rawValue: 0)!

let iterations = 1_000_000_000_000
var step = 0

func findShape() -> [Int] {
    var minHeight = Int.max
    var shape = (0...6).map { i in
        let height = playingField.firstIndex(where: { $0[Int(i)] == .rock }) ?? -1
        minHeight = min(minHeight, height)
        return height
    }
    return shape.map({ $0-minHeight })
    
}

func shapeToString(_ shape: [Int], _ shapeIndex: Int, _ gasIndex: Int) -> String {
    var result = shape.reduce("", { $0+String($1)+"-" })
    result+="\(shapeIndex)-\(gasIndex)"
    return result
}

var shapeFrequencies: [String:[(Int, Int)]] = [:]
var foundRepetition = false
var heightOffset = 0
var i = 0

while(i < iterations) {
    /*
    if step % directions.count == 0 {
        for i in 6..<min(12,playingField.count) {
            if !playingField[i].contains(.air) {
                print("found floor after \(i) iterations")
                printPlayingField()
                exit(0)
                break
            }
        }
    }
     */
    if i % 10_000 == 0 {
        print("Did \(i) iterations")
    }
    if(!foundRepetition){
        let currentHeight = playingField.count - findHighestPoint()
        let topShape = findShape()
        let shapeString = shapeToString(topShape, i % Shape.types, step % directions.count)
        if shapeFrequencies[shapeString] == nil {
            shapeFrequencies[shapeString] = [(currentHeight, i)]
        } else {
            // Found repetition
            let lastHeight = shapeFrequencies[shapeString]!.last!.0
            let lastI = shapeFrequencies[shapeString]!.last!.1
            let heightDifference = currentHeight-lastHeight
            let iDifference = i-lastI
            print("highestPoint \(findHighestPoint())")
            print("idiff \(iDifference), heightDiff \(heightDifference)")
            // Do not look for repetitions anymore
            foundRepetition = true
            let remainingIterations = iterations - i
            heightOffset = (remainingIterations / iDifference) * heightDifference
            i = iterations - (remainingIterations % iDifference)
        }
    }
    let currentShape = Shape(rawValue: i % Shape.types)!
    var currentPositionX = 2
    var currentPositionY = currentShape.startingRow
    while (true) {
        // Try to go sideways or don't
        var canMoveInDirection = true
        let direction = directions[step % directions.count]
        // print("going \(direction)")
        for element in currentShape.coordinates {
            if currentPositionX+element.x+direction.rawValue >= fieldWidth ||
               currentPositionX+element.x+direction.rawValue < 0 ||
                playingField[currentPositionY+element.y][currentPositionX+direction.rawValue+element.x] == .rock {
                canMoveInDirection = false
                break
            }
        }
        if canMoveInDirection {
            currentPositionX += direction.rawValue
        }
        // Go down if possible or abort
        var canGoDown = true
        for element in currentShape.coordinates {
            if currentPositionY+1+element.y > playingField.count-1 ||
               playingField[currentPositionY+1+element.y][currentPositionX+element.x] == .rock {
                canGoDown = false
                break
            }
        }
        if !canGoDown {
            for element in currentShape.coordinates {
                playingField[currentPositionY+element.y][currentPositionX+element.x] = .rock
            }
            step += 1
            // Go to next shape
            break
        } else {
            // Move down and try again
            currentPositionY += 1
            step += 1
            continue
        }
    }
    adjustPlayingField()
    i += 1
    // printPlayingField()
}

/*
let highestFrequency = shapeFrequencies.sorted(by: { $0.value.count > $1.value.count }).first
var lastValue = 0
var lastI = 0
let frequencies = highestFrequency!.value.map({ i in
    let difference = i.0 - lastValue
    let idifference = i.1 - lastI
    lastValue = i.0
    lastI = i.1
    return (i, difference, idifference)
 })
print("\(highestFrequency!.key), \(frequencies)")
 */

print(playingField.count)
print(findHighestPoint())
print(playingField.count-findHighestPoint()+heightOffset)
