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
    var root: Tile
    var xPos: CGFloat
    var yPos: CGFloat
    var count: Int {
        var tile = root
        var int: Int = 0
        while (tile != Tile.nilTile) {
            int += 1
            tile = tile.nextTile
        }
        return int
    }
    var width: CGFloat {
        var w: CGFloat = 0.0
        var tile = root
        while (tile != Tile.nilTile) {
            w += tile.sprite.size.width
            tile = tile.nextTile
        }
        return w
    }

    var description: String {
        var str = ""
        var tile = root
        while (tile != Tile.nilTile) {
            str += tile.word + " "
            tile = tile.nextTile
        }
        return str
    }
    
    init(root: Tile, x: CGFloat, y: CGFloat) {
        self.root = root
        self.xPos = x
        self.yPos = y
    }
    
    func first() -> Tile {
        return root
    }
    
    func last() -> Tile {
        var tile = root
        while (tile.nextTile != Tile.nilTile) {
            tile = tile.nextTile
        }
        return tile
    }
}