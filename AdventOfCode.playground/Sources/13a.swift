import UIKit

guard let fileURL = Bundle.main.url(forResource: "input", withExtension: "txt") else {
    print("can't locate file")
    exit(1)
}

guard let input = try? String(contentsOfFile: fileURL.path()) else {
    print("can't read file")
    exit(1)
}

class Element {
    var number: Int?
    var array: [Element]?
    
    var isNumber: Bool {
        return number != nil
    }
    
    init(number: Int) {
        self.number = number
    }
    
    init(array: [Element]) {
        self.array = array
    }
    
    var description: String {
        return number?.description ?? (array!.isEmpty ? "[]" : array!.description)
    }
}

extension [Element] {
    
    var description: String {
        var result = self.reduce("", { $0+","+$1.description })+"]"
        result.removeFirst()
        return "["+result
    }
    
}

func processString(_ arrayString: String) -> [Element] {
    var processedString = arrayString
    processedString.removeFirst()
    processedString.removeLast()
    // processedString is now 1,2,[3,[4],5]
    var resultingArray: [Element] = []
    while !processedString.isEmpty {
        var newString = ""
        var openParents = 0
        for character in processedString {
            if (character == "," && openParents == 0) {
                processedString.removeFirst()
                break
            } else if (character == "[") {
                openParents += 1
            } else if (character == "]") {
                openParents -= 1
            }
            newString.append(character)
            processedString.removeFirst()
        }
        // processedString is now 2,[3,[4],5]
        // newString is now 1
        if newString.first == "[" {
            resultingArray.append(Element(array: processString(newString)))
        } else {
            resultingArray.append(Element(number: NSString(string: newString).integerValue))
        }
    }
    return resultingArray
}

enum ComparisonResult {
    case inOrderContinue
    case inOrderDefinite
    case notInOrder
}

func isNotInOrder(first: [Element], second: [Element]) -> ComparisonResult {
    for i in 0..<second.count {
        if i > first.count - 1 {
            // second is greater
            return .inOrderDefinite
        } else {
            let firstElement = first[i]
            let secondElement = second[i]
            print("inspecting \(firstElement.description) and \(secondElement.description)")
            
            if (firstElement.isNumber && secondElement.isNumber) {
                if (secondElement.number! == firstElement.number!) {
                    // Equal
                    print("equal")
                    continue
                }
                // Not equal
                print("not equal")
                return secondElement.number! < firstElement.number! ? .notInOrder : .inOrderDefinite
            } else {
                let firstTransformedElement = firstElement.isNumber ? [firstElement] : firstElement.array!
                let secondTransformedElement = secondElement.isNumber ? [secondElement] : secondElement.array!
                print("inspecting \(firstTransformedElement.description) and \(secondTransformedElement.description)")
                let partialResult = isNotInOrder(first: firstTransformedElement, second: secondTransformedElement)
                if (partialResult == .inOrderDefinite) {
                    return .inOrderDefinite
                } else if (partialResult == .notInOrder) {
                    return .notInOrder
                }
            }
        }
    }
    // Equal keeps evaluating
    return first.count > second.count ? .notInOrder : .inOrderContinue
}

let touples = input.split(separator: "\n\n").map({ String($0) })

var indices = 0

for (index, touple) in touples.enumerated() {
    let split = touple.split(separator: "\n").map({ String($0) })
    let first = processString(split[0])
    print(split[0])
    print(first.description)
    
    let second = processString(split[1])
    print(split[1])
    print(second.description)
    
    let result = isNotInOrder(first: first, second: second)
    if (result == .inOrderDefinite || result == .inOrderContinue) {
        indices += (index + 1)
    }
    print((result == .inOrderContinue || result == .inOrderDefinite) ? "In order" : "Not in order")
    
    print("\n")
}

print(indices)
