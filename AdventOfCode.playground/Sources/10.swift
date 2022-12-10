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

var x = 1
var cycleNumber = 0
var result = ""

func checkState() {
    let spriteMiddle = x
    let sprite = (spriteMiddle-1)...(spriteMiddle+1)
    result.append((sprite.contains(cycleNumber % 40 - 1)) ? "#" : ".")
    if (cycleNumber % 40 == 0) {
        result.append("\n")
    }
}

for row in rowData {
    
    let instruction = row.split(separator: " ").map({ String($0) })
    if instruction[0] == "noop" {
        cycleNumber += 1
        checkState()
    } else if instruction[0] == "addx" {
        cycleNumber += 1
        checkState()
        cycleNumber += 1
        checkState()
        x += NSString(string: instruction[1]).integerValue
    }
    
}

print(result)
