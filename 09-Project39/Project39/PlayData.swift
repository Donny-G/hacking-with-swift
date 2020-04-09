//
//  PlayData.swift
//  Project39
//
//  Created by clarknt on 2020-04-08.
//  Copyright © 2020 clarknt. All rights reserved.
//

import Foundation

class PlayData {
    var allWords = [String]()

    var wordCounts: NSCountedSet!

    init() {
        if let path = Bundle.main.path(forResource: "plays", ofType: "txt") {
            if let plays = try? String(contentsOfFile: path) {
                // split on anything that is not a-Z or 0-9
                allWords = plays.components(separatedBy: CharacterSet.alphanumerics.inverted)
                allWords = allWords.filter { $0 != "" }

                wordCounts = NSCountedSet(array: allWords)
                let sorted = wordCounts.allObjects.sorted { wordCounts.count(for: $0) > wordCounts.count(for: $1) }
                allWords = sorted as! [String]
            }
        }
    }
}
