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
    var visibility: Int
    
    init(height: Int) {
        self.height = height
        self.visibility = 1
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

var distanceVisible = 1

var highScore = 0

func inspect(_ i: Int, _ j: Int) {
    // print("Inspecting \(i) \(j) value \(forest[i][j].height) previous \(previousHeight)")
    
    // look up
    distanceVisible = 0
    for k in (0..<i).reversed() {
        distanceVisible += 1
        if (forest[i][j].height <= forest[k][j].height) {
            break
        }
    }
    //print("visibility up is \(distanceVisible)")
    forest[i][j].visibility *= distanceVisible
    
    // look down
    distanceVisible = 0
    for k in (i+1..<columnCount) {
        distanceVisible += 1
        if (forest[i][j].height <= forest[k][j].height) {
            break
        }
    }
    //print("visibility down is \(distanceVisible)")
    forest[i][j].visibility *= distanceVisible
    
    // look left
    distanceVisible = 0
    for l in (0..<j).reversed() {
        distanceVisible += 1
        if (forest[i][j].height <= forest[i][l].height) {
            break
        }
    }
    //print("visibility left is \(distanceVisible)")
    forest[i][j].visibility *= distanceVisible
    
    // look right
    distanceVisible = 0
    for l in (j+1..<rowCount) {
        distanceVisible += 1
        if (forest[i][j].height <= forest[i][l].height) {
            break
        }
    }
    //print("visibility right is \(distanceVisible)")
    forest[i][j].visibility *= distanceVisible
    highScore = max(highScore, forest[i][j].visibility)
}

for i in rows {
    for j in columns {
        inspect(i, j)
    }
}

print(highScore)

/*
for i in 0..<rowCount {
    var row = ""
    for j in 0..<columnCount {
        row += " \(forest[i][j].visibility) "
    }
    print(row)
}
*/
