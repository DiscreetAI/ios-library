///
///  Encoder.swift
///  Discreet-DML
///
///  Created by Neelesh on 2/25/20.
///  Copyright © 2020 DiscreetAI. All rights reserved.
///

import Foundation


/**
 Extension to retrieve all the words (without punctuation) in a string.
 */
extension StringProtocol {
    var words: [String] {
        return split{ !$0.isLetter }.map{String($0)}
    }
}

/**
 Class for providing a basic text encoder for the user.
 */
public class BasicEncoder {
    
    /// The encoder dictionary, which maps a vocab word to an integer.
    var encoder: [String: Int]
    
    /**
     Initialize the basic encoder by labeling each vocab word in the vocab list with an integer.
     
     - Parameters:
        - vocabList: The vocab list of words that the encoder can expect to encode.
     */
    init(vocabList: [String]) {
        self.encoder = Dictionary(uniqueKeysWithValues: zip(vocabList, 1...vocabList.count))
        print(vocabList.count)
    }
    
    /**
     Helper function to encode a word into an integer. If the word cannot be found in the encoder dictionary, encode the word as 0.
     
     - Parameters:
        - word: The word to be encoded.
     
     - Returns: The word as an integer encoding.
     */
    private func encodeWord(word: String) -> Int {
        if let encoding = self.encoder[word] {
            return encoding
        } else {
            return 0
        }
    }
    
    /**
     Encode a text by splitting it into words and encoding each word as an integer.
     
     - Parameters:
        - text: The text to be encoded.
     
     - Returns: A 1D array of integer encodings.
     */
    public func encode(text: String) -> [Int] {
        return text.words.map(self.encodeWord)
    }
}
