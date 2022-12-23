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

let valveStrings = input.split(separator: "\n").map({ String($0) })

struct Valve {
    let name: String
    let flow: Int
    let tunnels: [String]
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

var map: Dictionary<String,Valve> = [:]

for valveString in valveStrings {
    // Valve AA has flow rate=0; tunnels lead to valves DD, II, BB
    var valves = valveString.groups(for: "[A-Z]{2}").map({ $0.first! })
    var currentValve = valves.removeFirst()
    let flow = Int(valveString.groups(for: "\\d+").first!.first!)!
    print("Valve \(currentValve) with flow \(flow) leads to \(valves)")
    let valve = Valve(name: currentValve, flow: flow, tunnels: valves)
    map[currentValve] = valve
}

func length(from startValve: String, to endValve: String) -> Int {
    var nodesToExplore: [(valve: String, distance: Int)] = [(valve: startValve, distance: 0)]
    var exploredNodes: [String] = []
    while(!nodesToExplore.isEmpty) {
        let node = nodesToExplore.removeFirst()
        if node.valve == endValve {
            return node.distance
        }
        for otherNode in map[node.valve]!.tunnels {
            if !exploredNodes.contains(otherNode) {
                exploredNodes.append(otherNode)
                nodesToExplore.append((valve: otherNode, distance: node.distance+1))
            }
        }
    }
    return -1
}


struct InterestingValve {
    let name: String
    let flow: Int
    let tunnels: [(String, Int)]
}

var reducedMap: Dictionary<String,InterestingValve> = [:]

let interestingValves = map.values.filter({ $0.flow != 0 || $0.name == "AA" })

for interestingValve in interestingValves {
    reducedMap[interestingValve.name] = InterestingValve(name: interestingValve.name,
                                                         flow: interestingValve.flow,
                                                         tunnels: interestingValves
            .filter({ $0.name != interestingValve.name })
            .map({ ($0.name, length(from: interestingValve.name, to: $0.name)) }))
}

print(reducedMap.values.reduce("", { $0+"\($1.name), \($1.flow), \($1.tunnels)\n" }))

struct Path {
    let timeRemaining: Int
    let openValves: [String]
    let currentValve: String
    let flowPerMinute: Int
    let flowAchieved: Int
}
/*
let sortedValves = map.values.filter({ $0.flow != 0 }).sorted(by: { $0.flow > $1.flow }).map({ $0.flow })
print(sortedValves)

var maximumFlows: [Int] = []
for i in 0..<30 {
    var partialFlow = 0
    var valveMultiplier = i
    var valveIndex = 0
    while valveMultiplier > 0 {
        partialFlow += sortedValves[valveIndex]*valveMultiplier
        valveMultiplier -= 2
        valveIndex = min(valveIndex+1, sortedValves.count-1)
    }
    // i 0 j 0 -> 0
    // i 1 j 1 -> 1*22
    // i 2 j 1 -> 2*22
    // i 3 j 2 -> 1*21 + 3*22
    // 0 22 2*22 3*22+1*21 4*22+2*21 5*22+3*21+1*20
    maximumFlows.append(partialFlow)
}
print(maximumFlows)


*/

// Correct DD BB JJ HH EE CC

let startPath = Path(timeRemaining: 30, openValves: [], currentValve: "AA", flowPerMinute: 0, flowAchieved: 0)

var pathsToTry = [startPath]
var maxFlowAchieved = 0

while(!pathsToTry.isEmpty) {
    /*
    pathsToTry.filter { path in
        let maxPossibleFlow = path.flowAchieved + maximumFlows[path.timeRemaining] + path.timeRemaining * path.flowPerMinute
        return maxPossibleFlow > maxFlowAchieved
    }
     */
    pathsToTry.sort(by: { ($0.flowAchieved+$0.timeRemaining*$0.flowPerMinute) > $1.flowAchieved+$1.timeRemaining*$1.flowPerMinute })
    let pathToTry = pathsToTry.removeFirst()
    let valve = reducedMap[pathToTry.currentValve]!
    // Don't explore nodes we already visited
    let possibleTunnels = valve.tunnels.filter({ tunnel in
        // Don't go there, it's a waste of time
        if tunnel.0 == "AA" { return false }
        // Should we add 1 below?
        if pathToTry.timeRemaining < (tunnel.1+1) { return false }
        if pathToTry.openValves.contains(tunnel.0) { return false }
        return true
    })
    // If there isn't anything to explore, abort
    if (possibleTunnels.isEmpty) {
        let flowAchieved = pathToTry.flowAchieved + pathToTry.flowPerMinute * pathToTry.timeRemaining
        if maxFlowAchieved < flowAchieved {
            maxFlowAchieved = flowAchieved
            print("Found solution: paths available \(pathsToTry.count+1), visited: \(pathToTry.openValves), flow achieved \(flowAchieved)")
        }
        continue
    }
    for nextValve in possibleTunnels {
        // Save next valve
        let valve = reducedMap[nextValve.0]!
        var newOpenValves = pathToTry.openValves
        // Open it
        newOpenValves.append(nextValve.0)
        // Go there
        pathsToTry.append(Path(timeRemaining: pathToTry.timeRemaining-(nextValve.1+1), // distance
                               openValves: newOpenValves,
                               currentValve: nextValve.0, // new valve
                               flowPerMinute: pathToTry.flowPerMinute + valve.flow,
                               flowAchieved: pathToTry.flowAchieved + pathToTry.flowPerMinute * (nextValve.1+1))) // flow used by time spent
    }
}
