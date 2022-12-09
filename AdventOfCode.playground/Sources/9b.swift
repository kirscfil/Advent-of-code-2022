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

var headX = 0
var headY = 0
var tail = (0..<9).map({ _ in return (0,0) })

var visited = [(Int, Int)]()

visited.append((0, 0))

for row in rowData {
    
    let command = row.split(separator: " ").map({ String($0) })
    let direction = command[0]
    let repeats = NSString(string: command[1]).integerValue
    for _ in 0..<repeats {
        switch direction {
        case "U":
            headY += 1
        case "R":
            headX += 1
        case "D":
            headY -= 1
        case "L":
            headX -= 1
        default:
            print("Unknown direction \(direction)")
        }
        var previousKnot = (headX, headY)
        // print("Head \(headX),\(headY)")
        for i in 0..<tail.count {
            let knot = tail[i]
            if (max(abs(previousKnot.0-knot.0),abs(previousKnot.1-knot.1)) > 1) {
                tail[i] = (knot.0 + (previousKnot.0 - knot.0).signum(),
                           knot.1 + (previousKnot.1 - knot.1).signum())
            }
            previousKnot = tail[i]
            // print("Knot \(i+1): \(previousKnot.0),\(previousKnot.1)")
        }
        if !visited.contains(where: { ($0.0 == tail.last!.0 && $0.1 == tail.last!.1) }) {
            visited.append((tail.last!.0, tail.last!.1))
        }
    }
}

print(visited.count)
