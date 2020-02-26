//
//  Encoder.swift
//  Discreet-DML
//
//  Created by Neelesh on 2/25/20.
//  Copyright © 2020 DiscreetAI. All rights reserved.
//

import Foundation

public class BasicEncoder {
    var encoder: [String: Int]
    init(vocabList: [String]) {
        self.encoder = Dictionary(uniqueKeysWithValues: zip(vocabList, 1...vocabList.count))
    }
    
    private func encodeWord(word: String) -> Int {
        if let encoding = self.encoder[word] {
            return encoding
        } else {
            return 0
        }
    }
    
    public func encode(text: String) -> [Int] {
        let words = text.components(separatedBy: " ")
        return words.map(self.encodeWord)
    }
}
