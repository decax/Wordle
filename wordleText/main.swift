//
//  main.swift
//  wordleText
//
//  Created by Dominic Hudon on 2022-03-01.
//

import Foundation

enum LetterState {
    case Good
    case GoodWrongPosition
    case Wrong
}

var words: [Substring]
let dictionaryFile = "/usr/share/dict/words"

// pick a word from the system dictionary
do {
    words = try String(contentsOfFile: dictionaryFile).split(separator: "\n").filter { $0.count == 5 }
} catch {
    print("could not find the dictionary file at \(dictionaryFile)")
    exit(1)
}

let word = String(words.randomElement()!)
var numberOfGuesses = 5

print("Guess the \(word.count) letters word")

while numberOfGuesses > 0 {
    
    print("\(numberOfGuesses) guesses left: ", terminator: "")
    
    let guess = readLine()
    if let guess = guess {
        
        if guess.count != word.count {
            print("Enter a \(word.count) letters word")
            continue
        }
        
        if !guess.allSatisfy( { $0.isLetter && $0.isLowercase } ) {
            print("Only use lowercase letters")
            continue
        }
        
        if words.first(where: { String($0) == guess } ) == nil {
            print("\(guess) is not a word")
            continue
        }

        let letterStates = GetLetterStates(guess: guess)

        // Print out the results
        //   - Uppercased letter is a good letter at the right position
        //   - Lowercased letter is a good letter at the wrong position
        //   - Underscore is a wrong letter
        for (letter, letterState) in zip(guess, letterStates) {
            switch letterState {

            case .Good:              print("\(letter.uppercased())", terminator: "")
            case .GoodWrongPosition: print("\(letter)", terminator: "")
            case .Wrong:             print("_", terminator: "")
            }
        }
        print()
        
        if letterStates.allSatisfy( { $0 == .Good } ) {
            print("Congratulations")
            break
        }
        
        numberOfGuesses -= 1
    }
    
    if numberOfGuesses == 0 {
        print("The word was \(word)")
    }
}

func GetLetterStates(guess: String) -> [LetterState] {
    var letterStates = [LetterState](repeating: .Wrong, count: word.count)
    var theWord = word.toCharacters()

    // first check for good letters
    for (i, (a, b)) in zip(guess, word).enumerated() {
        if a == b {
            letterStates[i] = .Good
            theWord[i] = " "
        }
    }
    
    // then check for good letter wrong position
    for (i, letter) in guess.enumerated() {
        
        // if the letter was already good, skip
        if letterStates[i] == .Good {
            continue
        }
        
        // otherwise, check if we have a GoodWrongPosition
        if let index = theWord.firstIndex(of: letter) {
            letterStates[i] = .GoodWrongPosition
            theWord[index] = " "
        }
    }

    return letterStates
}

extension String{
    
    func toCharacters() -> [Character] {
        var output: [Character] = []

        for c in self {
            output.append(c)
        }
        
        return output
    }
}
