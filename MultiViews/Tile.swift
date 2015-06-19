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
    
    var phrase: Phrase {
        return Phrase(root: self, x: xPos, y: yPos)
    }
    
    var sprite: SKSpriteNode
    var moveable: Bool
    
    let colors = ["Red","Green","Yellow","Blue"]
    let tags: [String] = []
    
    var nextTile: Tile?
    var prevTile: Tile?
    
    static let nilTile = Tile()
    
    private init(){
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
        sprite.hidden = true
        //phrase = Phrase(root: self, x: x, y: y)
        //phrase.addTile(self)
    }
    
    init(word: String, partOfSpeech: String, x: CGFloat, y: CGFloat) {//, tags: [String]) {
       // self.tags = tags
        self.word = word
        self.length = count(word)
        self.partOfSpeech = partOfSpeech
        self.xPos = x
        self.yPos = y
        self.nextTile = Tile.nilTile
        self.prevTile = Tile.nilTile
        self.prevPos = CGPoint(x: x, y: y)
        if (word == "nil") { self.moveable = false }
        else { self.moveable = true }
        
        let spriteSize = CGSize(width: max(CGFloat(20 * length), 50) + 10.0, height: 85.0)
        var tileImage = ""
        if partOfSpeech == "Noun" {
            tileImage = "RedTile"
        }
        else if partOfSpeech == "Verb" {
            tileImage = "GreenTile"
        }
        else if partOfSpeech == "Article" || partOfSpeech == "Pronoun" || partOfSpeech == "Conjunction" {
            tileImage = "YellowTile"
        }
        else if partOfSpeech == "Adjective" || partOfSpeech == "Preposition" || partOfSpeech == "Adverb" {
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
        //phrase = Phrase(root: self, x: x, y: y)
    }
    
    func isLastTile() -> Bool {
        return self.nextTile! == Tile.nilTile
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
        println("the tile corners are: \(corners)")
        return corners
    }
    
    func getPhraseTiles() -> [Tile] {
        var current: Tile = self
        var tiles: [Tile] = []
        while(current != Tile.nilTile) {
            tiles.append(current)
            current = current.nextTile!
        }
        return tiles
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
            
            var thisX = xPos + sprite.size.width/2
            if !(nextTile == Tile.nilTile) {
                let theNextTile = nextTile!
                thisX += theNextTile.sprite.size.width/2
                theNextTile.moveTile(CGPoint(x: thisX, y: newLocation.y))
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
            
            if !(nextTile == Tile.nilTile){
                let theNextTile = nextTile!
                theNextTile.moveTileAnimated(CGPoint(x: newLocation.x + sprite.size.width/2 + theNextTile.sprite.size.width/2, y: newLocation.y))
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