//
//  Tile.swift
//  MultiViews
//
//  Created by Administrator on 7/16/14.
//  Copyright (c) 2014 Administrator. All rights reserved.
//

import Foundation
import SpriteKit

class Tile: Printable, Comparable {
    var word: String
    var partOfSpeech: String
    var firstLetter: String {
        return word[word.startIndex...word.startIndex]
    }
    var length: Int
    var description: String {
        return "\(word): [\(xPos),\(yPos)]"
    }
    var xPos: CGFloat
    var yPos: CGFloat
    
    var prevPos: CGPoint
    var momentum = CGPoint(x: 0, y: 0)
    
    var phrase: Phrase
    
    var sprite: SKSpriteNode
    var moveable: Bool
    
    let colors = ["Red","Green","Yellow","Blue"]
    let tags: [String] = []
    
    var nextTile: Tile?
    var prevTile: Tile?
    
    init(){
        //nilTile
        let x:CGFloat = 0
        let y:CGFloat = 0
        self.word = "nil"
        self.moveable = false
        self.prevPos = CGPoint(x: x, y: y)
        self.partOfSpeech = ""
        self.xPos = 0
        self.yPos = 0
        self.length = 0
        
        let spriteSize = CGSize(width: 0.0, height: 0.0)
        sprite = SKSpriteNode(texture: SKTexture(imageNamed: ""), size: spriteSize)
        sprite.name = word
        let label = SKLabelNode()
        label.text = word
        sprite.addChild(label)
        label.position = CGPoint(x: 0, y: -6)
        sprite.hidden = true
        phrase = Phrase(tiles: [], x: x, y: y)
        phrase.addTile(self)
    }
    
    init(word: String, partOfSpeech: String, x: CGFloat, y: CGFloat) {//, tags: [String]) {
       // self.tags = tags
        self.word = word
        self.length = count(word)
        self.partOfSpeech = partOfSpeech
        self.xPos = x
        self.yPos = y
        self.nextTile = Tile()
        self.prevTile = Tile()
        self.prevPos = CGPoint(x: x, y: y)
        if (word == "nil") { self.moveable = false }
        else { self.moveable = true }
        
        let spriteSize = CGSize(width: max(CGFloat(20 * length), 50) + 10.0, height: 85.0)
        var tileImage = ""
        if partOfSpeech == "noun" {
            tileImage = "RedTile"
        }
        else if partOfSpeech == "verb" {
            tileImage = "GreenTile"
        }
        else if partOfSpeech == "article" || partOfSpeech == "pronoun" {
            tileImage = "YellowTile"
        }
        else if partOfSpeech == "adjective" {
            tileImage = "BlueTile"
        }
        else {
            let selectionNumber = Int(arc4random_uniform(UInt32(count(colors))))
            tileImage = colors[selectionNumber] + "Tile"
        }
        sprite = SKSpriteNode(texture: SKTexture(imageNamed: tileImage), size: spriteSize)
        
        let label = SKLabelNode()
        label.fontName = "Thonburi"
        label.text = word
        sprite.addChild(label)
        label.position = CGPoint(x: 0, y: -6)
        
        sprite.name = word
        
        if (!moveable) {
            sprite.hidden = true
        }
        phrase = Phrase(tiles: [], x: x, y: y)
        phrase.addTile(self)
    }
    
    func isLastTile() -> Bool {
        return self.nextTile!.word == "nil"
    }
    
    func locationIsInBounds(location: CGPoint) -> Bool {
        let image = self.sprite
        return location.x > self.xPos - image.size.width/2
            && location.x < self.xPos + image.size.width/2
            && location.y > self.yPos - image.size.height/2
            && location.y < self.yPos + image.size.height/2
    }
    
    func getCorners() -> [CGPoint] {
        // if we want to get named corners, might want to use a different return style
        let halfWidth = self.sprite.size.width/2
        let halfHeight = self.sprite.size.height/2
        let upperLeft = CGPoint(x: self.xPos - halfWidth, y: self.yPos - halfHeight)
        let lowerLeft = CGPoint(x: self.xPos - halfWidth, y: self.yPos + halfHeight)
        let upperRight = CGPoint(x: self.xPos + halfWidth, y: self.yPos - halfHeight)
        let lowerRight = CGPoint(x: self.xPos + halfWidth, y: self.yPos + halfHeight)
        let corners: [CGPoint] = [upperLeft, lowerLeft, upperRight, lowerRight]
        return corners
    }
    
    func getPhrase() -> (tiles:[Tile], length: CGFloat) {
        var phrase: [Tile] = []
        var current: Tile = self
        var length = sprite.size.width
        while(!current.isLastTile()) {
            phrase.append(current.nextTile!)
            length += current.nextTile!.sprite.size.width
            current = current.nextTile!
        }
        return (phrase, length)
    }
    
    func resetPrevPos() {
        prevPos.x = xPos
        prevPos.y = yPos
    }
    
    func moveTile(newLocation: CGPoint) {
        if moveable {
            prevPos.x = xPos
            prevPos.y = yPos
            
            xPos = newLocation.x
            yPos = newLocation.y
            
            momentum.x = xPos - prevPos.x
            momentum.y = yPos - prevPos.y
        
            sprite.position = newLocation
            let phrase = getPhrase()
            var thisX = xPos + (sprite.size.width/2)
            if count(getPhrase().tiles) > 0 {
                let i = getPhrase().tiles.first!
                thisX += i.sprite.size.width/2
                i.moveTile(CGPoint(x: thisX, y: newLocation.y))
            }
        }
    }
    func moveTileBy(toAdd: CGPoint) {
        moveTile(CGPoint(x: xPos + toAdd.x, y: yPos + toAdd.y))
    }
    func moveTileAnimated(newLocation: CGPoint) {
        if moveable {
            xPos = newLocation.x
            yPos = newLocation.y
        
            let action = SKAction.moveTo(newLocation, duration: 0.3)
            sprite.runAction(action)
            
            if count(getPhrase().tiles) > 0 {
                //if there is more than one tile, when you move this one, move its neighbor. recursive.
                println("Phrase: \(getPhrase())")
                let i = getPhrase().tiles.first!
                i.moveTileAnimated(CGPoint(x: newLocation.x + sprite.size.width/2 + i.sprite.size.width/2, y: newLocation.y))
            }
        }
    }
    func distanceToPoint(point: CGPoint) -> CGFloat {
        return (abs(xPos - point.x) + abs(yPos - point.y))
    }
    
}
func == (lhs: Tile, rhs: Tile) -> Bool {
    return lhs.word == rhs.word
}

func < (lhs: Tile, rhs: Tile) -> Bool {
    return lhs.word < rhs.word
}