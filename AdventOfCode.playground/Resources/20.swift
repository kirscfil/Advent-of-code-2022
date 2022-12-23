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

struct Number {
    let value: Int
    var moved: Bool
    var originalIndex: Int
}

var index = 0

var numbers: [Number] = input.split(separator: "\n").map({
    numberStringComponent in
    let numberString = String(numberStringComponent)
    let numberValue = Int(numberString)! * 811589153
    let number = Number(value: numberValue, moved: false, originalIndex: index)
    index += 1
    return number
})

for _ in 0..<10 {
    index = 0

    while(index < numbers.count) {
        let indexToMove = numbers.firstIndex { number in
            number.originalIndex == index
        }!
        let numberToMove = numbers[indexToMove]
        // let targetIndex = ((indexToMove + numberToMove.value + (numberToMove.value < 0 ? -1 : 0))+1_000*numbers.count) % numbers.count
        numbers.remove(at: indexToMove)
        var targetIndex: Int
        targetIndex = (indexToMove + numberToMove.value + numbers.count * 100_000_000_000) % numbers.count
        // print("Inspecting \(numberToMove.value), moving from \(indexToMove) to \(targetIndex)")
        numbers.insert(numberToMove, at: targetIndex)
        // print(numbers.map({ $0.value }))
        index += 1
    }
}

let zeroIndex = numbers.firstIndex(where: { $0.value == 0 })!
print(numbers[(zeroIndex + 1000)%numbers.count].value+numbers[(zeroIndex + 2000)%numbers.count].value+numbers[(zeroIndex + 3000)%numbers.count].value)

