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

extension String {
    var snafuToDecimal: Int? {
        var result = 0
        var currentOrder = 1
        for character in self.reversed() {
            switch(character) {
            case "=":
                result = result + -2 * currentOrder
                break
            case "-":
                result = result + -1 * currentOrder
                break
            case "0":
                break
            case "1":
                result = result + 1 * currentOrder
                break
            case "2":
                result = result + 2 * currentOrder
                break
            default:
                print("Snafu number has incorrect format \(self)")
                return nil
            }
            currentOrder = currentOrder * 5
        }
        return result
    }
}

extension Int {
    var snafu: String {
        var result = ""
        var currentOrder = 1
        var currentNumber = self
        while(currentNumber >= 1) {
            var currentDigit = (currentNumber+2*currentOrder) % (currentOrder*5)
            switch currentDigit {
            case 0:
                result = "=" + result
                break
            case 1:
                result = "-" + result
                break
            case 2:
                result = "0" + result
                break
            case 3:
                result = "1" + result
                break
            case 4:
                result = "2" + result
                break
            default:
                break
            }
            currentNumber -= currentDigit - 2
            currentNumber /= 5
        }
        return result
    }
}

var sum = 0

for snafuLine in input.split(separator: "\n").map({ String($0) }) {
    sum += snafuLine.snafuToDecimal!
    print("\(snafuLine), \(snafuLine.snafuToDecimal!), \(snafuLine.snafuToDecimal!.snafu)")
}

print(sum.snafu)
