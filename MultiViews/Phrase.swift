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
    var tiles: [Tile]
    var xPos: CGFloat
    var yPos: CGFloat
    var length: Int
    var width: CGFloat
    
    var description: String {
        var str = ""
        for tile in tiles {
            str += tile.word + " "
        }
        return str
    }
    
    init(tiles: [Tile], x: CGFloat, y: CGFloat) {
        self.tiles = tiles
        self.length = count(tiles)
        self.xPos = x
        self.yPos = y
        var i: CGFloat = 0.0
        for tile in tiles {
            i += tile.sprite.size.width
        }
        self.width = i
    }
    
    func addTile(newTile: Tile) {
        tiles.append(newTile)
    }

}