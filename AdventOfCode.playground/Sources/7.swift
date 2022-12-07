import UIKit

guard let fileURL = Bundle.main.url(forResource: "input", withExtension: "txt") else {
    print("can't locate file")
    exit(1)
}

guard let input = try? String(contentsOfFile: fileURL.path()) else {
    print("can't read file")
    exit(1)
}

class Directory: Equatable, Comparable {
    let name: String
    var size: Int = 0
    var files: [File] = []
    var directories: [Directory] = []
    var parent: Directory?
    let hash: String
    
    init(name: String, parent: Directory? = nil) {
        self.name = name
        self.parent = parent
        self.hash = name + (parent?.name ?? "-noparent")
    }
    
    static func == (lhs: Directory, rhs: Directory) -> Bool {
        return lhs.hash == rhs.hash && lhs.size == rhs.size
    }
    
    static func < (lhs: Directory, rhs: Directory) -> Bool {
        return lhs.size < rhs.size
    }
}

struct File {
    var name: String
    var size: Int
}

var root = Directory(name: "/")
var currentDirectory: Directory = root
let limit = 100000
var directoriesSmallerOrEqualThan100000: [Directory] = [root]
var allDirectories: [Directory] = [root]

for instruction in input.split(separator: "\n").map({ String($0) }) {
    print(instruction)
    if (instruction.hasPrefix("dir")) {
        //print("directory")
        let name = instruction.split(separator: " ")[1]
        let newDirectory = Directory(name: String(name), parent: currentDirectory)
        allDirectories.append(newDirectory)
        currentDirectory.directories.append(newDirectory)
        directoriesSmallerOrEqualThan100000.append(newDirectory)
    } else if (instruction.hasPrefix("$ cd ..")) {
        //print("going to parent")
        guard let parent = currentDirectory.parent else {
            print("Can't cd .. from root")
            exit(1)
        }
        currentDirectory = parent
    } else if (instruction.hasPrefix("$ cd /")) {
        //print("going to root")
        currentDirectory = root
    } else if (instruction.hasPrefix("$ cd")) {
        //print("changing folder")
        let directoryName = instruction.split(separator: " ")[2]
        //print("current folders, looking for \(directoryName)")
        //print(currentDirectory.directories)
        guard let newDir = currentDirectory.directories.first(where: { $0.name == directoryName }) else {
            print("Unable to cd to child dir \(directoryName)")
            exit(1)
        }
        currentDirectory = newDir
    } else if (instruction == "$ ls") {
        //print("ignoring")
        // Listing files, do nothing
        continue
    } else {
        //print("file")
        // This is file
        let command = instruction.split(separator: " ")
        guard command.count == 2 else {
            print("Command \(command) has invalid count")
            exit(1)
        }
        let size = NSString(string: String(command[0])).integerValue
        let name = String(command[1])
        currentDirectory.files.append(File(name: name, size: size))
        var inspectedDirectory: Directory? = currentDirectory
        while (inspectedDirectory != nil) {
            if (inspectedDirectory!.size <= limit && (inspectedDirectory!.size+size) > limit) {
                guard let index = directoriesSmallerOrEqualThan100000.firstIndex(where: { $0 == inspectedDirectory }) else {
                    print("Not found")
                    continue
                }
                directoriesSmallerOrEqualThan100000.remove(at: index)
            }
            inspectedDirectory!.size += size
            inspectedDirectory = inspectedDirectory!.parent
        }
    }
}
print(directoriesSmallerOrEqualThan100000.reduce(0, { $0+$1.size }))

let totalSizeAvailable = 70000000
let unusedSpaceNecessary = 30000000
let freeSpace = totalSizeAvailable - root.size
let needToDelete = unusedSpaceNecessary - freeSpace

print(allDirectories.sorted().first(where: { $0.size > needToDelete })?.size)
