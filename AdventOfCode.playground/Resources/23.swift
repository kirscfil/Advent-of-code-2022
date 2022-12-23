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

enum Direction {
    case North
    case South
    case West
    case East
}

class Elf {
    var positionX: Int
    var positionY: Int
    var proposedMovementX: Int?
    var proposedMovementY: Int?
    var directionsToConsider = [Direction.North, Direction.South, Direction.West, Direction.East]
    
    init(x: Int, y: Int) {
        self.positionX = x
        self.positionY = y
    }
    
    func proposeMovement() {
        proposedMovementX = nil
        proposedMovementY = nil
        //print("Planning movement for elf at \(positionX) \(positionY)")
        if  !isElf(x: positionX - 1, y: positionY - 1) &&
            !isElf(x: positionX, y: positionY - 1) &&
            !isElf(x: positionX + 1, y: positionY - 1) &&
            !isElf(x: positionX - 1, y: positionY + 1) &&
            !isElf(x: positionX, y: positionY + 1) &&
            !isElf(x: positionX + 1, y: positionY + 1) &&
            !isElf(x: positionX - 1, y: positionY) &&
            !isElf(x: positionX + 1, y: positionY) {
            // No elves around, chill
            return
        }
        for direction in directionsToConsider {
            // North
            if (direction == .North &&
                !isElf(x: positionX - 1, y: positionY - 1) &&
                !isElf(x: positionX - 1, y: positionY) &&
                !isElf(x: positionX - 1, y: positionY + 1)) {
                // print("Found direction North for elf at \(positionX) \(positionY)")
                proposedMovementX = positionX - 1
                proposedMovementY = positionY
                break
            } else {
                // print("Discarded direction North for elf at \(positionX) \(positionY)")
            }
            // South
            if (direction == .South &&
                !isElf(x: positionX + 1, y: positionY - 1) &&
                !isElf(x: positionX + 1, y: positionY) &&
                !isElf(x: positionX + 1, y: positionY + 1)) {
                // print("Found direction South for elf at \(positionX) \(positionY)")
                proposedMovementX = positionX + 1
                proposedMovementY = positionY
                break
            } else {
                //print("Discarded direction South for elf at \(positionX) \(positionY)")
            }
            // West
            if (direction == .West &&
                !isElf(x: positionX - 1, y: positionY - 1) &&
                !isElf(x: positionX, y: positionY - 1) &&
                !isElf(x: positionX + 1, y: positionY - 1)) {
                // print("Found direction West for elf at \(positionX) \(positionY)")
                proposedMovementX = positionX
                proposedMovementY = positionY - 1
                break
            } else {
                // print("Discarded direction West for elf at \(positionX) \(positionY)")
            }
            // East
            if (direction == .East &&
                !isElf(x: positionX - 1, y: positionY + 1) &&
                !isElf(x: positionX, y: positionY + 1) &&
                !isElf(x: positionX + 1, y: positionY + 1)) {
                // print("Found direction East for elf at \(positionX) \(positionY)")
                proposedMovementX = positionX
                proposedMovementY = positionY + 1
                break
            } else {
                //print("Discarded direction East for elf at \(positionX) \(positionY)")
            }
        }
        guard let x = proposedMovementX, let y = proposedMovementY else {
            return
        }
        if proposedMovements[x] == nil {
            proposedMovements[x] = [:]
        }
        if proposedMovements[x]![y] == nil {
            proposedMovements[x]![y] = []
        }
        proposedMovements[x]![y]!.append(self)
    }
    
    func moveIfProposedMovementIsAvailable() -> Bool {
        guard let x = proposedMovementX, let y = proposedMovementY else {
            return false
        }
        if proposedMovements[x]![y]!.count == 1 {
            moveElf(self, x: x, y: y)
            return true
        }
        return false
    }
    
    func changeDirections() {
        let firstDirection = directionsToConsider.removeFirst()
        directionsToConsider.append(firstDirection)
    }
    
}

var proposedMovements: [Int: [Int: [Elf]]] = [:]
var map: [Int: [Int: Elf]] = [:]
var elves: [Elf] = []

func isElf(x: Int, y: Int) -> Bool {
    if map[x] == nil {
        // print("There IS NOT an elf at \(x) \(y)")
        return false
    }
    if map[x]![y] == nil {
        // print("There IS NOT an elf at \(x) \(y)")
        return false
    }
    // print("There IS an elf at \(x) \(y)")
    return true
}

func setElf(_ elf: Elf, x: Int, y: Int) {
    elf.positionX = x
    elf.positionY = y
    if map[x] == nil {
        map[x] = [:]
    }
    map[x]![y] = elf
}

func moveElf(_ elf: Elf, x: Int, y: Int) {
    map[elf.positionX]?.removeValue(forKey: elf.positionY)
    setElf(elf, x: x, y: y)
}

for mapRow in input.split(separator: "\n").map({ String($0) }).enumerated() {
    for mapPosition in mapRow.element.enumerated() {
        if mapPosition.element == "#" {
            let elf = Elf(x: mapRow.offset, y: mapPosition.offset)
            elves.append(elf)
            setElf(elf, x: mapRow.offset, y: mapPosition.offset)
        }
    }
}

func findRanges() -> (ClosedRange<Int>, ClosedRange<Int>) {
    var minX = Int.max
    var maxX = Int.min
    var minY = Int.max
    var maxY = Int.min
    for elf in elves {
        minX = min(minX, elf.positionX)
        maxX = max(maxX, elf.positionX)
        minY = min(minY, elf.positionY)
        maxY = max(maxY, elf.positionY)
    }
    return (minX...maxX,minY...maxY)
}

func printMap() {
    let ranges = findRanges()
    for x in ranges.0 {
        var rowString = ""
        for y in ranges.1 {
            rowString += isElf(x: x, y: y) ? "#" : "."
        }
        print(rowString)
    }
    print("\n")
}

printMap()
var round = 1
while(true) {
    proposedMovements = [:]
    for elf in elves {
        elf.proposeMovement()
    }
    var hasNotMoved = true
    for elf in elves {
        if elf.moveIfProposedMovementIsAvailable() {
            hasNotMoved = false
        }
    }
    if (hasNotMoved) {
        break
    }
    for elf in elves {
        elf.changeDirections()
    }
    round += 1
}

print(round)

/*
var empty = 0
let ranges = findRanges()
for x in ranges.0 {
    for y in ranges.1 {
        if !isElf(x: x, y: y) {
            empty += 1
        }
    }
}

print(empty)
*/
