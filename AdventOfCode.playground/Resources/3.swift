import UIKit

guard let fileURL = Bundle.main.url(forResource: "input", withExtension: "txt") else {
    print("can't locate file")
    exit(1)
}

guard let input = try? String(contentsOfFile: fileURL.path()) else {
    print("can't read file")
    exit(1)
}

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

func splitRucksack(in rucksack: String) -> [String] {
    let half = rucksack.count / 2
    let halfIndex = rucksack.index(rucksack.startIndex, offsetBy: rucksack.count / 2)
    let firstCompartment = rucksack[..<halfIndex]
    let secondCompartment = rucksack[halfIndex...]
    return [String(firstCompartment), String(secondCompartment)]
}

func findDuplicate(in threeRucksacks: [String]) -> Character {
    for character in rucksacks[0] {
        for otherCharacter in rucksacks[1] {
            if character == otherCharacter {
                for yetAnotherCharacter in rucksacks[2] {
                    if character == yetAnotherCharacter {
                        return character
                    }
                }
            }
        }
    }
    return " "
}

var rucksacks = input.split(separator: "\n").map({ String($0) })

var totalPriority = 0

for _ in (0...(rucksacks.count/3-1)) {
    let firstRucksack = rucksacks[0]
    let secondRucksack = rucksacks[1]
    let thirdRucksack = String(rucksacks[2])
    let duplicate = findDuplicate(in: [firstRucksack, secondRucksack, thirdRucksack])
    rucksacks.removeFirst(3)
    totalPriority += duplicate.value
}

print(totalPriority)
