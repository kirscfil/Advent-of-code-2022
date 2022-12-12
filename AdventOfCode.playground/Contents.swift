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
