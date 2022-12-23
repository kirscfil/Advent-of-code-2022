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

guard let blueprintStrings = try? String(contentsOfFile: filePath) else {
    print("can't read file")
    exit(1)
}

struct Blueprint {
    let oreRobotPriceInOre: Int
    let clayRobotPriceInOre: Int
    let obsidianRobotPrice: (ore: Int, clay: Int)
    let geodeRobotPrice: (ore: Int, obsidian: Int)
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

let blueprints = blueprintStrings.split(separator: "\n").map { blueprintStringSlice in
    let blueprintString = String(blueprintStringSlice)
    let matches = blueprintString.groups(for: "\\d+").map({ $0.first! })
    return Blueprint(oreRobotPriceInOre: Int(matches[1])!, clayRobotPriceInOre: Int(matches[2])!, obsidianRobotPrice: (ore: Int(matches[3])!, clay: Int(matches[4])!), geodeRobotPrice: (ore: Int(matches[5])!, obsidian: Int(matches[6])!))
}

struct State {
    let ores: Int
    let clays: Int
    let obsidians: Int
    let geodes: Int
    let oreRobots: Int
    let clayRobots: Int
    let obsidianRobots: Int
    let geodeRobots: Int
    let timeRemaining: Int
    
    init() {
        self.ores = 0
        self.clays = 0
        self.obsidians = 0
        self.geodes = 0
        self.oreRobots = 1
        self.clayRobots = 0
        self.obsidianRobots = 0
        self.geodeRobots = 0
        self.timeRemaining = 32
    }
    
    init(ores: Int, clays: Int, obsidians: Int, geodes: Int, oreRobots: Int, clayRobots: Int, obsidianRobots: Int, geodeRobots: Int, timeRemaining: Int) {
        self.ores = ores
        self.clays = clays
        self.obsidians = obsidians
        self.geodes = geodes
        self.oreRobots = oreRobots
        self.clayRobots = clayRobots
        self.obsidianRobots = obsidianRobots
        self.geodeRobots = geodeRobots
        self.timeRemaining = timeRemaining
    }
    
    func heuristicValue(_ blueprint: Blueprint) -> Int {
        return (self.geodes + (self.geodeRobots * self.timeRemaining)) * 10_000 + (self.obsidians + (self.obsidianRobots * self.timeRemaining)) * blueprint.geodeRobotPrice.obsidian + (self.clays + (self.clayRobots * self.timeRemaining)) * blueprint.geodeRobotPrice.ore
    }
    
    func makeNothing() -> State {
        return State(ores: self.ores+self.oreRobots, clays: self.clays+self.clayRobots, obsidians: self.obsidians+self.obsidianRobots, geodes: self.geodes+self.geodeRobots, oreRobots: self.oreRobots, clayRobots: self.clayRobots, obsidianRobots: self.obsidianRobots, geodeRobots: self.geodeRobots,
                     timeRemaining: self.timeRemaining-1)
    }
    
    func canMakeOreRobot(_ blueprint: Blueprint) -> Bool {
        return self.ores >= blueprint.oreRobotPriceInOre
    }
    
    func makeOreRobot(_ blueprint: Blueprint) -> State {
        return State(ores: self.ores+self.oreRobots-blueprint.oreRobotPriceInOre, clays: self.clays+self.clayRobots, obsidians: self.obsidians+self.obsidianRobots, geodes: self.geodes+self.geodeRobots, oreRobots: self.oreRobots+1, clayRobots: self.clayRobots, obsidianRobots: self.obsidianRobots, geodeRobots: self.geodeRobots,
                     timeRemaining: self.timeRemaining-1)
    }
    
    func canMakeClayRobot(_ blueprint: Blueprint) -> Bool {
        return self.ores >= blueprint.clayRobotPriceInOre
    }
    
    func makeClayRobot(_ blueprint: Blueprint) -> State {
        return State(ores: self.ores+self.oreRobots-blueprint.clayRobotPriceInOre, clays: self.clays+self.clayRobots, obsidians: self.obsidians+self.obsidianRobots, geodes: self.geodes+self.geodeRobots, oreRobots: self.oreRobots, clayRobots: self.clayRobots+1, obsidianRobots: self.obsidianRobots, geodeRobots: self.geodeRobots,
                     timeRemaining: self.timeRemaining-1)
    }
    
    func canMakeObsidianRobot(_ blueprint: Blueprint) -> Bool {
        return self.ores >= blueprint.obsidianRobotPrice.ore && self.clays >= blueprint.obsidianRobotPrice.clay
    }
    
    func makeObsidianRobot(_ blueprint: Blueprint) -> State {
        return State(ores: self.ores+self.oreRobots-blueprint.obsidianRobotPrice.ore,
                     clays: self.clays+self.clayRobots-blueprint.obsidianRobotPrice.clay,
                     obsidians: self.obsidians+self.obsidianRobots,
                     geodes: self.geodes+self.geodeRobots,
                     oreRobots: self.oreRobots,
                     clayRobots: self.clayRobots,
                     obsidianRobots: self.obsidianRobots+1,
                     geodeRobots: self.geodeRobots,
                     timeRemaining: self.timeRemaining-1)
    }
    
    func canMakeGeodeRobot(_ blueprint: Blueprint) -> Bool {
        return self.ores >= blueprint.geodeRobotPrice.ore && self.obsidians >= blueprint.geodeRobotPrice.obsidian
    }
    
    func makeGeodeRobot(_ blueprint: Blueprint) -> State {
        return State(ores: self.ores+self.oreRobots-blueprint.geodeRobotPrice.ore,
                     clays: self.clays+self.clayRobots,
                     obsidians: self.obsidians+self.obsidianRobots-blueprint.geodeRobotPrice.obsidian,
                     geodes: self.geodes+self.geodeRobots,
                     oreRobots: self.oreRobots,
                     clayRobots: self.clayRobots,
                     obsidianRobots: self.obsidianRobots,
                     geodeRobots: self.geodeRobots+1,
                     timeRemaining: self.timeRemaining-1)
    }
}

let maxIteration = 100_000_000_000

var blueprintIndex = 0
var result = 1
var startDate: Date

for blueprint in blueprints {
    startDate = Date()
    blueprintIndex += 1
    print("Blueprint \(blueprintIndex)")
    var maxGeodesInTime = [Int](repeating: -1, count: 33)
    var minTimeRemaining = 32
    var maximumGeodes = -1
    var statesToSee = [State()]
    var iteration = 0
    while(!statesToSee.isEmpty) {
        // check iteration
        iteration += 1
        if (iteration > maxIteration) {
            break
        }
        let timeRemaining = statesToSee.first!.timeRemaining
        if minTimeRemaining > timeRemaining {
            print("Exploring time \(timeRemaining), population \(statesToSee.count)")
            minTimeRemaining = timeRemaining
        }
        // prioritise
        statesToSee.sort(by: { $0.heuristicValue(blueprint) > $1.heuristicValue(blueprint) })
        let currentState = statesToSee.removeFirst()
        // prune
        if (maxGeodesInTime[currentState.timeRemaining] - currentState.geodes > 2) {
            continue
        }
        maxGeodesInTime[currentState.timeRemaining] = max(maxGeodesInTime[currentState.timeRemaining], currentState.geodes)
        
        // check end conditions
        if currentState.timeRemaining == 1 {
            let finalState = currentState.makeNothing()
            if (finalState.geodes > maximumGeodes) {
                print("Found new maximum \(finalState.geodes) geodes")
                maximumGeodes = finalState.geodes
            }
            continue
        }
        // check option
        if currentState.canMakeOreRobot(blueprint) {
            statesToSee.append(currentState.makeOreRobot(blueprint))
        } else {
            var nextState = currentState
            while (true) {
                nextState = nextState.makeNothing()
                maxGeodesInTime[nextState.timeRemaining] = max(maxGeodesInTime[nextState.timeRemaining], nextState.geodes)
                if (nextState.timeRemaining == 1) {
                    maximumGeodes = max(maximumGeodes, nextState.geodes)
                    break
                } else if (nextState.canMakeOreRobot(blueprint)) {
                    statesToSee.append(nextState.makeOreRobot(blueprint))
                    break
                }
            }
        }
        if currentState.canMakeClayRobot(blueprint) {
            statesToSee.append(currentState.makeClayRobot(blueprint))
        } else {
            var nextState = currentState
            while (true) {
                nextState = nextState.makeNothing()
                maxGeodesInTime[nextState.timeRemaining] = max(maxGeodesInTime[nextState.timeRemaining], nextState.geodes)
                if (nextState.timeRemaining == 1) {
                    maximumGeodes = max(maximumGeodes, nextState.geodes)
                    break
                } else if (nextState.canMakeClayRobot(blueprint)) {
                    statesToSee.append(nextState.makeClayRobot(blueprint))
                    break
                }
            }
        }
        if currentState.canMakeObsidianRobot(blueprint) {
            statesToSee.append(currentState.makeObsidianRobot(blueprint))
        } else {
            var nextState = currentState
            while (true) {
                nextState = nextState.makeNothing()
                maxGeodesInTime[nextState.timeRemaining] = max(maxGeodesInTime[nextState.timeRemaining], nextState.geodes)
                if (nextState.timeRemaining == 1) {
                    maximumGeodes = max(maximumGeodes, nextState.geodes)
                    break
                } else if (nextState.canMakeObsidianRobot(blueprint)) {
                    statesToSee.append(nextState.makeObsidianRobot(blueprint))
                    break
                }
            }
        }
        if currentState.canMakeGeodeRobot(blueprint) {
            statesToSee.append(currentState.makeGeodeRobot(blueprint))
        } else {
            var nextState = currentState
            while (true) {
                nextState = nextState.makeNothing()
                maxGeodesInTime[nextState.timeRemaining] = max(maxGeodesInTime[nextState.timeRemaining], nextState.geodes)
                if (nextState.timeRemaining == 1) {
                    maximumGeodes = max(maximumGeodes, nextState.geodes)
                    break
                } else if (nextState.canMakeGeodeRobot(blueprint)) {
                    statesToSee.append(nextState.makeGeodeRobot(blueprint))
                    break
                }
            }
        }
    }
    print(maximumGeodes)
    result *= maximumGeodes
    print(Date().timeIntervalSince(startDate))
}

print(result)
