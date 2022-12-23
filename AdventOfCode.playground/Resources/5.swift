import UIKit

guard let fileURL = Bundle.main.url(forResource: "input", withExtension: "txt") else {
    print("can't locate file")
    exit(1)
}

guard let input = try? String(contentsOfFile: fileURL.path()) else {
    print("can't read file")
    exit(1)
}

let split = input.split(separator: "\n\n").map({ String($0) })

class Stack {
    private var boxes: [Character] = []
    
    var top: Character {
        return boxes.last ?? "/"
    }
    
    func removeBox() -> Character {
        let removed = top
        self.boxes.removeLast()
        return removed
    }
    
    func addBox(_ character: Character) {
        self.boxes.append(character)
    }
    
    func printBoxes() {
        print(boxes.reduce("", { $0+"\($1) " }))
    }
}

var rawStacks = split[0].split(separator: "\n").reversed().map({ String($0) })
rawStacks.removeFirst()

// Setup stacks

let stacks = (0..<(rawStacks[0].count/4)).map({ _ in return Stack()})

// Push initial configuration

rawStacks.forEach {
    stackRow in
    for index in (1..<Int((stackRow.count+1)/4)) {
        let characterIndex = stackRow.index(stackRow.startIndex, offsetBy: index*4+1)
        let character = stackRow[characterIndex]
        if character != " " {
            stacks[index-1].addBox(character)
        }
    }
}

// Follow instructions

let rawMoves = split[1].split(separator: "\n")

rawMoves.forEach {
    rawMove in
    
    // Debug print
    /*
    for (index, stack) in stacks.enumerated() {
        print("Stack \(index+1)")
        stack.printBoxes()
    }
     */
    
    let split = rawMove.split(separator: " ").map({ String($0) })
    
    let howMany = NSString(string: split[1]).integerValue
    let indexFrom = NSString(string: split[3]).integerValue - 1
    let indexTo = NSString(string: split[5]).integerValue - 1
    var helperStack: [Character] = []
    for _ in 0..<howMany {
        helperStack.append(stacks[indexFrom].removeBox())
    }
    for index in 0..<howMany {
        stacks[indexTo].addBox(helperStack.reversed()[index])
    }
}

stacks.reduce("") { partialResult, stack in
    return partialResult + "\(stack.top)"
}
