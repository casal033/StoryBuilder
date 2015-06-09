//
//  Phrase.swift
//  MultiViews
//
//  Created by Administrator on 8/30/14.
//  Copyright (c) 2014 Administrator. All rights reserved.
//

import Foundation
import SpriteKit

class Phrase: Printable {
    var words: [Tile]
    var xPos: CGFloat
    var yPos: CGFloat
    var length: Int
    var width: CGFloat
    
    var description: String {
        var str = ""
        for word in words {
            str += word.word + " "
        }
        return str
    }
    
    init(words: [Tile], x: CGFloat, y: CGFloat) {
        self.words = words
        self.length = count(words)
        self.xPos = x
        self.yPos = y
        var i: CGFloat = 0.0
        for word in words {
            i += word.sprite.size.width
        }
        self.width = i
    }
    
    func addWord(newWord: Tile) {
        words.append(newWord)
    }

}