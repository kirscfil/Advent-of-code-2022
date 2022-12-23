import UIKit

guard let fileURL = Bundle.main.url(forResource: "input", withExtension: "txt") else {
    print("can't locate file")
    exit(1)
}

guard let input = try? String(contentsOfFile: fileURL.path()) else {
    print("can't read file")
    exit(1)
}

let elves = input.split(separator: "\n\n")

var topCalories: [Int] = []
let n = 3

elves.forEach {
    elf in
    let candies = elf.split(separator: "\n")
    var caloriesTotal = 0
    candies.forEach {
        candy in
        guard let calorie = Int(candy) else {
            print("candy calorie content isn't valid \(candy)")
            return
        }
        caloriesTotal += calorie
    }
    if(topCalories.count < n) {
        topCalories.append(caloriesTotal)
        topCalories.sort()
    } else if (topCalories.first! < caloriesTotal) {
        topCalories[0] = caloriesTotal
        topCalories.sort()
    }
}

print(topCalories.reduce(0, {
    partialSum, elf in
    return partialSum+elf
}))
