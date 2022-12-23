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

let sensorsData = input.split(separator: "\n").map({ String($0) })

var data: [(sensorX: Int, sensorY: Int, beaconX: Int, beaconY: Int, range: Int)] = []
/*
var minXCoord = Int.max
var maxXCoord = Int.min
 */
var minYCoord = Int.max
var maxYCoord = Int.min

let targetRow = 2000000

for sensorData in sensorsData {
    let regex = try! NSRegularExpression(pattern: "-?\\d+")
    let range = NSRange(location: 0, length: sensorData.count)
    let matches = regex.matches(in: sensorData, range: range).map {
        String(sensorData[Range($0.range, in: sensorData)!])
    }
    let sensorX = Int(matches[0])!
    let sensorY = Int(matches[1])!
    let beaconX = Int(matches[2])!
    let beaconY = Int(matches[3])!
    let distance = abs(beaconX - sensorX) + abs(beaconY - sensorY)
    let distanceInTargetRow = distance - abs(targetRow - sensorY)
    // if distanceInTargetRow > 0 {
        minYCoord = min(minYCoord, sensorX-distanceInTargetRow)
        maxYCoord = max(maxYCoord, sensorX+distanceInTargetRow)
        data.append((sensorX: sensorX, sensorY: sensorY, beaconX: beaconX, beaconY: beaconY, range: distance))
    // }
}

/*

enum State {
    case canBeBeacon
    case canNotBeBeacon
    case beacon
}

print(minYCoord)
print(maxYCoord)

func tYC(_ yCoordinate: Int) -> Int { yCoordinate - minYCoord }

var rowData = [State](repeating: .canBeBeacon, count: tYC(maxYCoord))

print(rowData.count)

for sensor in data {
    print("for sensor \(sensor)")
    if sensor.beaconY == targetRow {
        print("has beacon on \(sensor.beaconX)")
        rowData[tYC(sensor.beaconX)] = .beacon
    }
    print("has range from \(sensor.sensorX-sensor.range) to \(sensor.sensorX+sensor.range-1)")
    for index in sensor.sensorX-sensor.range..<sensor.sensorX+sensor.range {
        if rowData[tYC(index)] == .canBeBeacon {
            rowData[tYC(index)] = .canNotBeBeacon
        }
    }
}

print(rowData.filter({ $0 != .canBeBeacon }).count)
 
 */

/*
for x in 0...maxX {
    for y in 0...maxY {
        var available = true
        for sensor in data {
            if sensor.beaconX == x && sensor.beaconY == y {
                available = false
                break
            }
            if abs(sensor.sensorX - x)+abs(sensor.sensorY - y) <= sensor.range {
                available = false
                break
            }
        }
        if (available) {
            print("Found tuning frequency is \(x*4000000+y)")
        }
    }
}
 */

func combinedIntervals(intervals: [CountableClosedRange<Int>]) -> [CountableClosedRange<Int>] {
    
    var combined = [CountableClosedRange<Int>]()
    var accumulator = (0...0) // empty range
    
    for interval in intervals.sorted(by: { $0.lowerBound  < $1.lowerBound  } ) {
        
        if accumulator == (0...0) {
            accumulator = interval
        }
        
        if accumulator.upperBound >= interval.upperBound {
            // interval is already inside accumulator
        }
            
        else if accumulator.upperBound >= interval.lowerBound  {
            // interval hangs off the back end of accumulator
            accumulator = (accumulator.lowerBound...interval.upperBound)
        }
            
        else if accumulator.upperBound <= interval.lowerBound  {
            // interval does not overlap
            combined.append(accumulator)
            accumulator = interval
        }
    }
    
    if accumulator != (0...0) {
        combined.append(accumulator)
    }
    
    return combined
}

let maxX = 4_000_000
let maxY = 4_000_000

let interestingRange = 0...maxX

for y in 0...maxY {
    if y%100_000 == 0 {
        print("looking at row \(y)")
    }
    // print("looking at row \(y)")
    var ranges: [CountableClosedRange<Int>] = []
    for sensor in data {
        // print("sensor \(sensor.sensorX), \(sensor.sensorY), range \(sensor.range)")
        let sensorRangeInRow = sensor.range - abs(y-sensor.sensorY)
        if sensorRangeInRow < 1 {
            continue
        }
        let lowerBound = sensor.sensorX-sensorRangeInRow
        let upperBound = sensor.sensorX+sensorRangeInRow
        // print("lower bound \(lowerBound), upper bound \(upperBound)")
        let range = lowerBound...upperBound
        if (range.overlaps(interestingRange)) {
            ranges.append(range)
        }
    }
    if (ranges.count == 0) { continue }
    let result = combinedIntervals(intervals: ranges)
    // print(result.map({ "\($0.lowerBound) - \($0.upperBound)" }))
    if (result.count == 0) { continue }
    if (result.first!.lowerBound > 0 || result.last!.upperBound < maxX) {
        print("y: \(y)")
        print(result.map({ String($0.lowerBound)+" - "+String($0.upperBound) }))
        break
    }
    if (result.count < 2) { continue }
    for i in 0..<(result.count-1) {
        if result[i].upperBound + 1 != result[i+1].lowerBound {
            print("y: \(y)")
            print(result.map({ String($0.lowerBound)+" - "+String($0.upperBound) }))
            print((result[i].upperBound+1)*maxX+y)
            break
        }
    }
}
