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

class Monkey {
    var items: [Int]
    var operation: (Int) -> (Int)
    var test: (Int) -> (Int)
    var inspections: Int
    
    init(items: [Int], operation: @escaping (Int)->(Int), test: @escaping (Int)->(Int)) {
        self.items = items
        self.operation = operation
        self.test = test
        self.inspections = 0
    }
}

let monkeys = [
    Monkey(items: [54, 98, 50, 94, 69, 62, 53, 85], operation: { $0*13 }, test: { $0%3==0 ? 2 : 1 }),
    Monkey(items: [71, 55, 82], operation: { $0+2 }, test: { $0%13==0 ? 7 : 2 }),
    Monkey(items: [77, 73, 86, 72, 87], operation: { $0+8 }, test: { $0%19==0 ? 4 : 7 }),
    Monkey(items: [97, 91], operation: { $0+1 }, test: { $0%17==0 ? 6 : 5 }),
    Monkey(items: [78, 97, 51, 85, 66, 63, 62], operation: { $0*17 }, test: { $0%5==0 ? 6 : 3 }),
    Monkey(items: [88], operation: { $0+3 }, test: { $0%7==0 ? 1 : 0 }),
    Monkey(items: [87, 57, 63, 86, 87, 53], operation: { $0*$0 }, test: { $0%11==0 ? 5 : 0 }),
    Monkey(items: [73, 59, 82, 65], operation: { $0+6 }, test: { $0%2==0 ? 4 : 3 })
]

let divisor = 3*13*19*17*5*7*11*2

for _ in 0..<10000 {
    
    for monkey in monkeys {
        
        for item in monkey.items {
            
            monkey.inspections += 1
            var worry = monkey.operation(item)
            worry %= divisor
            let nextMonkey = monkey.test(worry)
            monkeys[nextMonkey].items.append(worry)
            
        }
        
        monkey.items = []
        
    }
    
}

print(monkeys.sorted(by: { $0.inspections > $1.inspections }).map {
    $0.inspections
})
