import UIKit

guard let fileURL = Bundle.main.url(forResource: "input", withExtension: "txt") else {
    print("can't locate file")
    exit(1)
}

guard let input = try? String(contentsOfFile: fileURL.path()) else {
    print("can't read file")
    exit(1)
}

extension Array where Element: Equatable {
    var onlyUnique: Bool {
        var uniqueValues: [Element] = []
        for item in self {
            guard !uniqueValues.contains(item) else { return false }
            uniqueValues.append(item)
        }
        return true
    }
}

let startIndex = input.startIndex

for index in 13..<input.count {
    let values = Array(input[input.index(input.startIndex, offsetBy: index-13)...input.index(startIndex, offsetBy: index)])
    if(values.onlyUnique) {
        print(index)
        break
    }
}
