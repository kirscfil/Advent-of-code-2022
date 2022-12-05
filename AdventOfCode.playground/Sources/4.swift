import UIKit

guard let fileURL = Bundle.main.url(forResource: "input", withExtension: "txt") else {
    print("can't locate file")
    exit(1)
}

guard let input = try? String(contentsOfFile: fileURL.path()) else {
    print("can't read file")
    exit(1)
}

func parseElf(_ elf: String) -> (lower: Int, upper: Int) {
    let bounds = elf.split(separator: "-").map({ String($0) })
    return (lower: NSString(string: bounds[0]).integerValue, upper: NSString(string: bounds[1]).integerValue)
}

func overlap(elf: (Int, Int), otherElf: (Int, Int)) -> Bool {
    return (elf.1 >= otherElf.0 && elf.1 <= otherElf.1) ||
           (elf.0 <= otherElf.1 && elf.0 >= otherElf.1)
}

let pairs = input.split(separator: "\n").map({ String($0) })

print(pairs.reduce(0, { partialSum, pair in
    let elves = pair.split(separator: ",").map({ String($0) })
    let elfOne = parseElf(elves[0])
    let elfTwo = parseElf(elves[1])
    return partialSum + ((overlap(elf: elfOne, otherElf: elfTwo) || overlap(elf: elfTwo, otherElf: elfOne)) ? 1 : 0)
}))
