import UIKit

guard let fileURL = Bundle.main.url(forResource: "input", withExtension: "txt") else {
    print("can't locate file")
    exit(1)
}

guard let input = try? String(contentsOfFile: fileURL.path()) else {
    print("can't read file")
    exit(1)
}

let rounds = input.split(separator: "\n")

func isWin(opponent: Character, you: Character) -> Bool {
    // This would be much nicer if I could work with characters as with Ints... tough.
    return you == "Y" && opponent == "A" ||
        you == "Z" && opponent == "B" ||
        you == "X" && opponent == "C"
}

func isDraw(opponent: Character, you: Character) -> Bool {
    return you == "X" && opponent == "A" ||
        you == "Y" && opponent == "B" ||
        you == "Z" && opponent == "C"
}

func draw(for opponent: Character) -> Character {
    return opponent == "A" ? "X" : opponent == "B" ? "Y" : "Z"
}

func win(for opponent: Character) -> Character {
    return opponent == "A" ? "Y" : opponent == "B" ? "Z" : "X"
}

func lose(for opponent: Character) -> Character {
    return opponent == "A" ? "Z" : opponent == "B" ? "X" : "Y"
}

func scoreRound(opponent: Character, you: Character) -> Int {
    let characterScore = (you == "X" ? 1 : you == "Y" ? 2 : 3)
    let winScore = isWin(opponent: opponent, you: you) ? 6 : 0
    let drawScore = isDraw(opponent: opponent, you: you) ? 3 : 0
    return characterScore + winScore + drawScore
}

let finalScore = rounds.reduce(0, {
    score, round in
    let chars = round.split(separator: " ")
    let opponent = chars[0].first!
    let you = chars[1].first! == "X" ? lose(for: opponent) : chars[1].first! == "Y" ? draw(for: opponent) : win(for: opponent)
    return score + scoreRound(opponent: opponent, you: you)
})

print(finalScore)
