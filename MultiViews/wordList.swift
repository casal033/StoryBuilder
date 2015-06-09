//
//  WordList.swift
//  FlashCardTrial
//
//  Created by Kristin Lamberty on 7/10/14.
//  Copyright (c) 2014 Kristin Lamberty. All rights reserved.
//

import SpriteKit

class WordList {
    
    var words: [String]!
    var wordsWithCategories: [[String]]!
    init(filename: String) {
        if let dictionary = Dictionary<String, AnyObject>.loadJSONFromBundle(filename) {
            if let wordsArray: AnyObject = dictionary["words"] {
                words = wordsArray as! [String]
            }
        }
    }
    
    init(url: String){
        if let dictionary = Dictionary<String, AnyObject>.loadJSONFromWeb(url) {
            if let wordsArray: AnyObject = dictionary["words"] {
                words = wordsArray as! [String]
            }
        }
        
    }
    
    init(arr: [[String]]!) {
        wordsWithCategories = arr
    }
    
}