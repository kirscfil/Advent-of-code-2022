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
    let currentValve = valves.removeFirst()
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
    
    var value: Int {
        return flowAchieved+flowPerMinute*timeRemaining
    }
}

let myStartPath = Path(timeRemaining: 26, openValves: [], currentValve: "AA", flowPerMinute: 0, flowAchieved: 0)
let elephantStartPath = Path(timeRemaining: 26, openValves: [], currentValve: "AA", flowPerMinute: 0, flowAchieved: 0)

var pathsToTry: [(pathAhead: Path, pathBehind: Path)] = [(pathAhead: myStartPath, pathBehind: elephantStartPath)]
var maxFlowAchieved = 0
var iteration = 0

while(!pathsToTry.isEmpty) {
    pathsToTry.sort { $0.pathAhead.value + $0.pathBehind.value > $1.pathAhead.value + $1.pathBehind.value }
    let currentPaths = pathsToTry.removeFirst()
    
    let valve = reducedMap[currentPaths.pathBehind.currentValve]!
    let otherValve = reducedMap[currentPaths.pathAhead.currentValve]!
    // Don't explore nodes we already visited
    let possibleTunnels = valve.tunnels.filter({ tunnel in
        // Don't go there, it's a waste of time
        if tunnel.0 == "AA" { return false }
        // Should we add 1 below?
        if currentPaths.pathBehind.timeRemaining < (tunnel.1+1) { return false }
        if currentPaths.pathBehind.openValves.contains(tunnel.0) { return false }
        if currentPaths.pathAhead.openValves.contains(tunnel.0) { return false }
        // if tunnel.1 > otherValve.tunnels.first(where: { $0.0 == tunnel.0 })!.1 { return false }
        return true
    })
    // If there isn't anything to explore, abort
    if (possibleTunnels.isEmpty) {
        // We can just stay where we are and chill
        let flowAchieved = currentPaths.pathBehind.flowAchieved + currentPaths.pathBehind.flowPerMinute * currentPaths.pathBehind.timeRemaining
        if (currentPaths.pathAhead.timeRemaining == 0) {
            iteration += 1
            if (iteration % 10_000 == 0) {
                print("Seen \(iteration) solutions, branches waiting \(pathsToTry.count)")
            }
            // We abort
            let totalFlow = flowAchieved + currentPaths.pathAhead.flowAchieved
            if maxFlowAchieved < totalFlow {
                maxFlowAchieved = totalFlow
                print("Found new best solution: visited: \(currentPaths.pathAhead.openValves)+\(currentPaths.pathBehind.openValves), flow achieved: \(totalFlow)")
            }
            continue
        } else {
            // We need to pass it along
            pathsToTry.append((pathAhead: Path(timeRemaining: 0,
                                               openValves: currentPaths.pathBehind.openValves,
                                               currentValve: currentPaths.pathBehind.currentValve,
                                               flowPerMinute: currentPaths.pathBehind.flowPerMinute,
                                               flowAchieved: flowAchieved), pathBehind: currentPaths.pathAhead))
            continue
        }
    }
    for nextValve in possibleTunnels.sorted(by: { t1, t2 in
        let v1 = reducedMap[t1.0]!
        let v2 = reducedMap[t2.0]!
        return (v1.flow*(currentPaths.pathBehind.timeRemaining-t1.1)) > (v2.flow*(currentPaths.pathBehind.timeRemaining-t2.1))
    }) {
        // Save next valve
        let valve = reducedMap[nextValve.0]!
        var newOpenValves = currentPaths.pathBehind.openValves
        // Open it
        newOpenValves.append(nextValve.0)
        // Go there
        let newPath = Path(timeRemaining: currentPaths.pathBehind.timeRemaining-(nextValve.1+1), // distance
                           openValves: newOpenValves,
                           currentValve: nextValve.0, // new valve
                           flowPerMinute: currentPaths.pathBehind.flowPerMinute + valve.flow,
                           flowAchieved: currentPaths.pathBehind.flowAchieved + currentPaths.pathBehind.flowPerMinute * (nextValve.1+1)) // flow used by time spent
        if (newPath.timeRemaining > currentPaths.pathAhead.timeRemaining) {
            pathsToTry.append((pathAhead: currentPaths.pathAhead, pathBehind: newPath))
        } else {
            pathsToTry.append((pathAhead: newPath, pathBehind: currentPaths.pathAhead))
        }
    }
}
