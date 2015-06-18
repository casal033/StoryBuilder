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
    var width: CGFloat {var i: CGFloat = 0.0
        for tile in tiles {
            i += tile.sprite.size.width
        }
        return i}

    
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
    }
    
    func addTile(newTile: Tile) {
        tiles.append(newTile)
    }
    
    //was getPhrase in Tile
    //var current: Tile = self
    //var length = sprite.size.width
    //while(!current.isLastTile()) {
    //phrase.addTile(current.nextTile!)
    //length += current.nextTile!.sprite.size.width
    //current = current.nextTile!
    //}
    //return (phrase, length)
    
    func first() -> Tile {
        return self.tiles[0]
    }
    
    func last() -> Tile {
        return self.tiles[tiles.count-1]
    }
    
    //func getCorners() -> [CGPoint] {
        // if we want to get named corners, might want to use a different return style
    //    let upperLeft = CGPoint(x: self.xPos, y: self.yPos)
    //    let lowerLeft = CGPoint(x: self.xPos, y: self.yPos + width)
    //    let upperRight = CGPoint(x: self.xPos + width, y: self.yPos)
    //    let lowerRight = CGPoint(x: self.xPos + width, y: self.yPos + first().sprite.size.height)
    //    let corners: [CGPoint] = [upperLeft, lowerLeft, upperRight, lowerRight]
    //    println("the phrase corners are: \(corners)")
    //    return corners
    //}

}