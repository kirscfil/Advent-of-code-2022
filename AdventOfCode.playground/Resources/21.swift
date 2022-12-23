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

struct Monkey {
    var id: String
    var value: Int?
    var operation: ((Int, Int) -> (Int))?
    var operationSign: String?
    var leftMonkey: String?
    var rightContainsHuman: Bool?
    var leftValue: Int?
    var rightMonkey: String?
    var leftContainsHuman: Bool?
    var rightValue: Int?
    
    var containsHuman: Bool {
        return leftContainsHuman == true || rightContainsHuman == true
    }
}

extension String {
    func groups(for regexPattern: String) -> [[String]] {
        do {
            let text = self
            let regex = try NSRegularExpression(pattern: regexPattern)
            let matches = regex.matches(in: text,
                                        range: NSRange(text.startIndex..., in: text))
            return matches.map { match in
                return (0..<match.numberOfRanges).map {
                    let rangeBounds = match.range(at: $0)
                    guard let range = Range(rangeBounds, in: text) else {
                        return ""
                    }
                    return String(text[range])
                }
            }
        } catch let error {
            print("invalid regex: \(error.localizedDescription)")
            return []
        }
    }
}

func stringToOperation(_ string: String) -> ((Int, Int) -> (Int), String)? {
    let operations: [(String,((Int, Int) -> (Int)))] = [("+",{ $0+$1 }),
                                                      ("-",{ $0-$1 }),
                                                      ("*",{ $0*$1 }),
                                                      ("/",{ $0/$1 })]
    for operation in operations {
        if string.contains(operation.0) {
            return (operation.1, operation.0)
        }
    }
    print("Error parsing operation from \(string)")
    return nil
}
    
// Keys are monkeys which when updated update other monkey values
var dependences: [String: [String]] = [:]

// Keys are monkey ids
var monkeys: [String: Monkey] = [:]

for monkeyLine in input.components(separatedBy: "\n").map({ String($0) }) {
    // print(monkeyLine)
    let components = monkeyLine.components(separatedBy: ": ").map({ String($0) })
    if components.count < 2 {
        continue
    }
    let monkeyId = components[0]
    if let value = Int(components[1]) {
        // print(value)
        monkeys[monkeyId] = Monkey(id: monkeyId, value: value)
    } else {
        let monkeyIds = components[1].groups(for: "\\w+").map({ $0.first! })
        // print(monkeyIds)
        if dependences[monkeyIds[0]] != nil {
            dependences[monkeyIds[0]]!.append(monkeyId)
        } else {
            dependences[monkeyIds[0]] = [monkeyId]
        }
        if dependences[monkeyIds[1]] != nil {
            dependences[monkeyIds[1]]!.append(monkeyId)
        } else {
            dependences[monkeyIds[1]] = [monkeyId]
        }
        let parsedOperation = stringToOperation(components[1])!
        monkeys[monkeyId] = Monkey(id: monkeyId, operation: parsedOperation.0, operationSign: parsedOperation.1, leftMonkey: monkeyIds[0], rightMonkey: monkeyIds[1])
    }
}

print(monkeys)
print(dependences)


while(!dependences.isEmpty) {
    //print("Has \(dependences.count) dependencies")
    let lastDependenceCount = dependences.count
    for monkeyDependency in dependences {
        //print("Looking at monkey \(monkeyDependency)")
        if let value = monkeys[monkeyDependency.key]!.value {
            //print("Monkey \(monkeyDependency) has value \(value)")
            for dependantMonkeyId in monkeyDependency.value {
                //print("Updating monkey \(dependantMonkeyId)")
                var monkey = monkeys[dependantMonkeyId]!
                if monkey.leftMonkey == monkeyDependency.key {
                    //print("Updating left value to \(value)")
                    monkey.leftValue = value
                    if (monkeyDependency.key == "humn" || monkeys[monkeyDependency.key]!.containsHuman) {
                        monkey.leftContainsHuman = true
                    }
                }
                if monkey.rightMonkey == monkeyDependency.key {
                    //print("Updating right value to \(value)")
                    monkey.rightValue = value
                    if (monkeyDependency.key == "humn" || monkeys[monkeyDependency.key]!.containsHuman) {
                        monkey.rightContainsHuman = true
                    }
                }
                if let leftValue = monkey.leftValue,
                   let rightValue = monkey.rightValue {
                    let result = monkey.operation!(leftValue, rightValue)
                    //print("Updating operation result \(result)")
                    monkey.value = result
                }
                monkeys[dependantMonkeyId] = monkey
            }
            //print("Removing dependency on monkey \(monkeyDependency)")
            dependences.removeValue(forKey: monkeyDependency.key)
        }
    }
    if(dependences.count == lastDependenceCount) {
        break
    }
}

for monkey in monkeys {
    print("\(monkey.key), contains human \(monkey.value.containsHuman)")
}

var result = monkeys["root"]!.rightValue!
var nextMonkey = monkeys["root"]!.leftMonkey!

while(true) {
    if (nextMonkey == "humn") {
        print("success!")
        print(result)
        break
    }
    print("exploring monkey \(nextMonkey)")
    let monkey = monkeys[nextMonkey]!
    if monkey.leftContainsHuman == true && monkey.rightContainsHuman == true {
        print("Error: both branches contain human :( This program needs to be improved")
        break
    } else if monkey.leftContainsHuman == true, let rightValue = monkey.rightValue {
        if monkey.operationSign == "+" {
            result = result - rightValue
        } else if monkey.operationSign == "-" {
            result = result + rightValue
        } else if monkey.operationSign == "*" {
            result = result / rightValue
        } else if monkey.operationSign == "/" {
            result = result * rightValue
        } else {
            print("unknown operation \(monkey.operationSign ?? "nil")")
        }
        nextMonkey = monkey.leftMonkey!
    } else if monkey.rightContainsHuman == true, let leftValue = monkey.leftValue {
        if monkey.operationSign == "+" {
            result = result - leftValue
        } else if monkey.operationSign == "-" {
            result = leftValue - result
        } else if monkey.operationSign == "*" {
            result = result / leftValue
        } else if monkey.operationSign == "/" {
            result = leftValue / result
        } else {
            print("unknown operation \(monkey.operationSign ?? "nil")")
        }
        nextMonkey = monkey.rightMonkey!
    }
}




