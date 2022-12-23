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

let rowCount = rowData.count
let columnCount = rowData[0].count
let rows = 0..<rowCount
let columns = 0..<columnCount

class Tree {
    let height: Int
    var isVisible: Bool
    
    init(height: Int) {
        self.height = height
        self.isVisible = false
    }
}

var forest: [[Tree]] = []

for i in rows {
    forest.append([])
    for character in rowData[i] {
        let value = NSString(string: String(character)).integerValue
        forest[i].append(Tree(height: value))
    }
}

var visibleTreeCount = 0
var previousHeight = -1

func inspect(_ i: Int, _ j: Int) {
    // print("Inspecting \(i) \(j) value \(forest[i][j].height) previous \(previousHeight)")
    if (forest[i][j].height > previousHeight) {
        if !forest[i][j].isVisible {
            visibleTreeCount += 1
            forest[i][j].isVisible = true
        }
    }
    previousHeight = max(forest[i][j].height, previousHeight)
}

for i in rows {
    previousHeight = -1
    for j in columns {
        inspect(i, j)
    }
}

for i in rows {
    previousHeight = -1
    for j in columns.reversed() {
        inspect(i, j)
    }
}

for j in columns {
    previousHeight = -1
    for i in rows {
        inspect(i, j)
    }
}

for j in columns {
    previousHeight = -1
    for i in rows.reversed() {
        inspect(i, j)
    }
}

print(visibleTreeCount)
