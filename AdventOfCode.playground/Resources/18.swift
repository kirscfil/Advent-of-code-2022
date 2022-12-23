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

var cubes: [(Int, Int, Int)] = []

func isOrtogonalNeighbour(_ first: (Int, Int, Int), _ other: (Int, Int, Int)) -> Bool {
    return (abs(first.0 - other.0) == 1 && (abs(first.1 - other.1)+abs(first.2 - other.2)) == 0) ||
            (abs(first.1 - other.1) == 1 && (abs(first.0 - other.0)+abs(first.2 - other.2)) == 0) ||
            (abs(first.2 - other.2) == 1 && (abs(first.0 - other.0)+abs(first.1 - other.1)) == 0)
}

var sides = 0

var minX = Int.max
var minY = Int.max
var minZ = Int.max
var maxX = Int.min
var maxY = Int.min
var maxZ = Int.min

for cubeRow in input.split(separator: "\n").map({ String($0) }) {
    let coords = cubeRow.split(separator: ",").map({ String($0) })
    let cube: (Int, Int, Int) = (Int(coords[0])!+1,Int(coords[1])!+1,Int(coords[2])!+1)
    var neighbours = 0
    for otherCube in cubes {
        if(isOrtogonalNeighbour(cube, otherCube)) {
            neighbours += 1
        }
        if neighbours == 6 { break }
    }
    cubes.append(cube)
    sides += 6 - (2 * neighbours)
    print(cube)
    minX = min(minX, cube.0)
    minY = min(minY, cube.1)
    minZ = min(minZ, cube.2)
    maxX = max(maxX, cube.0)
    maxY = max(maxY, cube.1)
    maxZ = max(maxZ, cube.2)
}

print("\(minX) - \(maxX)")
print("\(minY) - \(maxY)")
print("\(minZ) - \(maxZ)")

// Adjust space
minX -= 1
minY -= 1
minZ -= 1
maxX += 1
maxY += 1
maxZ += 1

var space: [[[Bool]]] = [[[Bool]]](repeating: [[Bool]](repeating: [Bool](repeating: false, count: maxZ-minZ+1), count: maxY-minY+1), count: maxX-minY+1)

for cube in cubes {
    print("adding cube \(cube)")
    space[cube.0-minX][cube.1-minY][cube.2-minZ] = true
}

var emptySpacesToSee: [(Int, Int, Int)] = [(minX,minY,minZ)]
var seenSpaces: [(Int, Int, Int)] = []
var exteriorSides = 0

func seenOrWillSeeSpace(_ space: (Int, Int, Int)) -> Bool {
    return seenSpaces.contains(where: { $0.0 == space.0 && $0.1 == space.1 && $0.2 == space.2 }) ||
          emptySpacesToSee.contains(where: { $0.0 == space.0 && $0.1 == space.1 && $0.2 == space.2 })
}

func isRock(_ coords: (Int, Int, Int)) -> Bool {
    space[coords.0-minX][coords.1-minY][coords.2-minZ]
}

func inspectNeighbour(_ neighbour: (Int, Int, Int)) {
    if (isRock(neighbour)) {
        print("Found neighbour \(neighbour)")
        exteriorSides += 1
    } else if !seenOrWillSeeSpace(neighbour) {
        emptySpacesToSee.append(neighbour)
    }
}

while(true) {
    if(emptySpacesToSee.isEmpty) {
        break
    }
    let inspectedSpace = emptySpacesToSee.removeFirst()
    print("Inspecting \(inspectedSpace)")
    // look up
    if (inspectedSpace.0 > minX) {
        let neighbour = (inspectedSpace.0-1, inspectedSpace.1, inspectedSpace.2)
        inspectNeighbour(neighbour)
    }
    // look down
    if (inspectedSpace.0 < maxX) {
        let neighbour = (inspectedSpace.0+1, inspectedSpace.1, inspectedSpace.2)
        inspectNeighbour(neighbour)
    }
    // look left
    if (inspectedSpace.1 > minY) {
        let neighbour = (inspectedSpace.0, inspectedSpace.1-1, inspectedSpace.2)
        inspectNeighbour(neighbour)
    }
    // look right
    if (inspectedSpace.1 < maxY) {
        let neighbour = (inspectedSpace.0, inspectedSpace.1+1, inspectedSpace.2)
        inspectNeighbour(neighbour)
    }
    // look forward
    if (inspectedSpace.2 > minZ) {
        let neighbour = (inspectedSpace.0, inspectedSpace.1, inspectedSpace.2-1)
        inspectNeighbour(neighbour)
    }
    // look back
    if (inspectedSpace.2 < maxZ) {
        let neighbour = (inspectedSpace.0, inspectedSpace.1, inspectedSpace.2+1)
        inspectNeighbour(neighbour)
    }
    seenSpaces.append(inspectedSpace)
}

print(exteriorSides)
