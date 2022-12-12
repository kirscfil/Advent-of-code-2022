import UIKit

guard let fileURL = Bundle.main.url(forResource: "input", withExtension: "txt") else {
    print("can't locate file")
    exit(1)
}

guard let input = try? String(contentsOfFile: fileURL.path()) else {
    print("can't read file")
    exit(1)
}

let rowData = input.split(separator: "\n").map({ String($0) })

extension Character {
    var value: Int {
        if self.isUppercase {
            return self.lowercased().first!.value + 26
        }
        switch self {
        case "a": return 1
        case "b": return 2
        case "c": return 3
        case "d": return 4
        case "e": return 5
        case "f": return 6
        case "g": return 7
        case "h": return 8
        case "i": return 9
        case "j": return 10
        case "k": return 11
        case "l": return 12
        case "m": return 13
        case "n": return 14
        case "o": return 15
        case "p": return 16
        case "q": return 17
        case "r": return 18
        case "s": return 19
        case "t": return 20
        case "u": return 21
        case "v": return 22
        case "w": return 23
        case "x": return 24
        case "y": return 25
        case "z": return 26
        default: return 0
        }
    }
}

var map: [[(Int, Bool)]] = []
var current: (x: Int, y: Int, path: [(x: Int, y: Int)])?

for (i, row) in rowData.enumerated() {
    map.append([])
    for (j, char) in row.enumerated() {
        if (char == "S") {
            map[i].append((1, false))
        } else if (char == "E") {
            current = (x: i, y: j, path: [(x: i, y: j)])
            map[i].append((26, false))
        } else {
            map[i].append((char.value, false))
        }
    }
}

var toVisit = [current!]
var visited: [(x: Int, y: Int, path: [(x: Int, y: Int)])]  = []

func lookAt(current: (x: Int, y: Int, path: [(x: Int, y: Int)]), x: Int, y: Int) {
    let currentElevation = map[current.x][current.y].0
    let next = map[x][y].0
    // Possibly just 1 or 0?
    if (currentElevation - next <= 1) {
        var newPath = current.path
        newPath.append((x: current.x, y: current.y))
        toVisit.append((x: x, y: y, path: newPath))
        //print("pushing \(x), \(y)")
    }
}

var iter = 0

func printInspected() {
    if (iter < 10) {
        iter += 1
        return
    } else {
        iter = 0
    }
    for row in map {
        var rowString = ""
        for col in row {
            rowString += " \(col.1 ? "◼︎" : ".")"
        }
        print(rowString)
    }
    print("\n\n\n\n")
}

func visitNext() -> Bool {
    let inspected = toVisit.removeFirst()
    //print("inspecting \(inspected)")
    if (map[inspected.x][inspected.y].1) {
        return false
    } else {
        map[inspected.x][inspected.y].1 = true
        printInspected()
    }
    if (map[inspected.x][inspected.y].0 == 1) {
        print(inspected.path.count-1)
        return true
    } else {
        if (inspected.x > 0) {
            //print("can go left")
            lookAt(current: inspected, x: inspected.x-1, y: inspected.y)
        }
        if (inspected.y > 0) {
            //print("can go up")
            lookAt(current: inspected, x: inspected.x, y: inspected.y-1)
        }
        if (inspected.x+1 < map.count) {
            //print("can go right")
            lookAt(current: inspected, x: inspected.x+1, y: inspected.y)
        }
        if (inspected.y+1 < map[0].count) {
            //print("can go down")
            lookAt(current: inspected, x: inspected.x, y: inspected.y+1)
        }
        return false
    }
}

while (!visitNext()) {
    
}
