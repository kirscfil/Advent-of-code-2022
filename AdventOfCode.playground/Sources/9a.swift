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
var tailX = 0
var tailY = 0

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
        if (max(abs(headX-tailX),abs(headY-tailY)) > 1) {
            tailX += (headX - tailX).signum()
            tailY += (headY - tailY).signum()
            if !visited.contains(where: { ($0.0 == tailX && $0.1 == tailY) }) {
                visited.append((tailX, tailY))
            }
        }
        // print("Head \(headX),\(headY), Tail \(tailX),\(tailY)")
    }
}

print(visited.count)
