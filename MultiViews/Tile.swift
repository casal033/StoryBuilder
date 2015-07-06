//
//  Tile.swift
//  MultiViews
//
//  Created by Administrator on 7/16/14.
//  Copyright (c) 2014 Administrator. All rights reserved.
//

import Foundation
import SpriteKit

class Tile: SKSpriteNode, Printable, Comparable {
    var word: String
    var partOfSpeech: String
    var firstLetter: String {
        return word[word.startIndex...word.startIndex]
    }
    var length: Int
    override var description: String {
        return "\(word): [\(xPos),\(yPos)]"
    }
    var xPos: CGFloat
    var yPos: CGFloat
    
    var prevPos: CGPoint
    var textureAtlas = SKTextureAtlas(named:"yellowTile.atlas")
    var momentum = CGPoint(x: 0, y: 0)
    
    var phrase: Phrase {
        return Phrase(root: self, x: xPos, y: yPos)
    }
    
    //var sprite: SKSpriteNode
    var moveable: Bool
    
    let colors = ["Red","Green","Yellow","Blue"]
    let tags: [String] = []
    
    lazy var nextTile: Tile = Tile.nilTile
    lazy var prevTile: Tile = Tile.nilTile
    
    static let nilTile = Tile()
    
    required init(coder aDecoder: NSCoder) {
        fatalError("NSCoding not supported")
    }
    
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
        //sprite = SKSpriteNode(texture: SKTexture(imageNamed: ""), size: spriteSize)
        super.init(texture: nil, color: nil, size: spriteSize)
        hidden = true

        
    }
    
    init(word: String, partOfSpeech: String, x: CGFloat, y: CGFloat) {//, tags: [String]) {
       // self.tags = tags
        self.word = word
        self.length = count(word)
        self.partOfSpeech = partOfSpeech
        self.xPos = x
        self.yPos = y
        //self.nextTile = Tile.nilTile
        //self.prevTile = Tile.nilTile
        self.prevPos = CGPoint(x: x, y: y)
        if (word == "nil") { self.moveable = false }
        else { self.moveable = true }
        
        let spriteSize = CGSize(width: max(CGFloat(20 * length), 50) + 10.0, height: 85.0)
        var tileImage = ""
        if partOfSpeech == "Noun" || partOfSpeech == "Pronoun" {
            tileImage = "blue1"
            textureAtlas = SKTextureAtlas(named:"blueTile.atlas")
        }
        else if partOfSpeech == "Verb" {
            tileImage = "red1"
            textureAtlas = SKTextureAtlas(named:"redTile.atlas")
        }
        else if partOfSpeech == "Article" || partOfSpeech == "Conjunction" || partOfSpeech == "Preposition" || partOfSpeech == "Adverb" {
            tileImage = "yellow1"
            textureAtlas = SKTextureAtlas(named:"yellowTile.atlas")
        }
        else if partOfSpeech == "Adjective"  {
            tileImage = "green1"
            textureAtlas = SKTextureAtlas(named:"greenTile.atlas")
        }
        else {
            let selectionNumber = Int(arc4random_uniform(UInt32(count(colors))))
            tileImage = colors[selectionNumber] + "Tile"
        }
        //sprite = SKSpriteNode(texture: , size: spriteSize)
        super.init(texture: SKTexture(imageNamed: tileImage), color: nil, size: spriteSize)
        let label = SKLabelNode()
        label.fontName = "Thonburi"
        label.text = word
        addChild(label)
        label.position = CGPoint(x: 0, y: -6)
        
        name = word
        
        if (!moveable) {
            hidden = true
        }
        //phrase = Phrase(root: self, x: x, y: y)
    }
    
    func isLastTile() -> Bool {
        return self.nextTile == Tile.nilTile
    }
    
    override func containsPoint(location: CGPoint) -> Bool {
        return location.x > self.xPos - size.width/2
            && location.x < self.xPos + size.width/2
            && location.y > self.yPos - size.height/2
            && location.y < self.yPos + size.height/2
    }
    
    func getLeftCorners() -> [CGPoint] {
        // if we want to get named corners, might want to use a different return style
        let halfWidth = self.size.width/2
        let halfHeight = self.size.height/2
        let upperLeft = CGPoint(x: self.xPos - halfWidth, y: self.yPos - halfHeight)
        let lowerLeft = CGPoint(x: self.xPos - halfWidth, y: self.yPos + halfHeight)
        let corners: [CGPoint] = [upperLeft, lowerLeft]
        //println("the left tile corners are: \(corners)")
        return corners
    }
    
    func leftCornersInside(tilesArray: [Tile]) -> ([Tile]) {
        var overlappingTiles: [Tile] = []
        let corners = getLeftCorners()
        for tile in tilesArray {
            if self != tile {
                for corner in corners {
                    if !contains(overlappingTiles, tile) && tile.containsPoint(corner) {
                        overlappingTiles.append(tile)
                        //could probably return just one tile and could return it as soon as you find it
                    }
                }
            }
        }
        return overlappingTiles
    }
    
    func rightCornersInside(tilesArray: [Tile]) -> ([Tile]) {
        var overlappingTiles: [Tile] = []
        let corners = getRightCorners()
        for tile in tilesArray {
            if self != tile {
                for corner in corners {
                    if !contains(overlappingTiles, tile) && tile.containsPoint(corner) {
                        overlappingTiles.append(tile)
                        //could probably return just one tile and could return it as soon as you find it
                    }
                }
            }
        }
        return overlappingTiles
    }
    
    func getRightCorners() -> [CGPoint] {
        // if we want to get named corners, might want to use a different return style
        let halfWidth = self.size.width/2
        let halfHeight = self.size.height/2
        let upperRight = CGPoint(x: self.xPos + halfWidth, y: self.yPos - halfHeight)
        let lowerRight = CGPoint(x: self.xPos + halfWidth, y: self.yPos + halfHeight)
        let corners: [CGPoint] = [upperRight, lowerRight]
        println("the right tile corners are: \(corners)")
        return corners
    }
    
    func getPhraseTiles() -> [Tile] {
        var current: Tile = self
        var tiles: [Tile] = []
        while(current != Tile.nilTile) {
            tiles.append(current)
            current = current.nextTile
        }
        return tiles
    }
    
    func resetPrevPos() {
        prevPos.x = xPos
        prevPos.y = yPos
    }
    
    func didMove() -> Bool {
        return !(xPos == prevPos.x && yPos == prevPos.y)
    }
    
    func detachFromPrev() {
        //if the tile I am moving used to be "next" for something, update that previous tile to point at nilTile
        prevTile.nextTile = Tile.nilTile
        //and set the tile I'm moving to have nilTile as its previous tile (since it used to have something)
        prevTile = Tile.nilTile
    }
    
    func makePrevOf(otherTile: Tile) {
        println("LAST TILE IN ADDED PHRASE: \(self.phrase.last())")
        detachFromPrev()
        if otherTile.prevTile != Tile.nilTile {
            otherTile.prevTile.nextTile = self
        }
        self.prevTile = otherTile.prevTile
        otherTile.prevTile = self.phrase.last()
        self.phrase.last().nextTile = otherTile
        
    }
    
    func makeNextOf(otherTile: Tile) {
        println("the last tile in the added phrase is: \(self.phrase.last())")
        detachFromPrev()
        if otherTile.nextTile != Tile.nilTile {
            otherTile.nextTile.prevTile = self.phrase.last()
        }
        self.phrase.last().nextTile = otherTile.nextTile
        otherTile.nextTile = self
        self.prevTile = otherTile
    }
    
    func rotate() {
        if (moveable) {
            println("Rotating!")
            let sequence: SKAction = SKAction.sequence([SKAction.rotateByAngle(degToRad(Float(-60.0)), duration: 0.3), SKAction.rotateByAngle(degToRad(0.0), duration: 0.2), SKAction.rotateToAngle(0.0, duration: 0.3)])
            runAction(SKAction.repeatAction(sequence,count: 1))
        }
    }
    
    func highlight() {
        if (moveable) {
            println("Highlighting!")
            let pause = SKAction.rotateByAngle(degToRad(0.0), duration: 0.3)
            let highlight = SKAction.setTexture(textureAtlas.textureNamed(textureAtlas.textureNames[0] as! String))
            let sequence: SKAction = SKAction.sequence([highlight, pause])
            runAction(sequence, withKey: "highlight")
        }
    }
    
    func highlightRevert() {
        if (moveable) {
            println("UNHighlighting!")
            let pause = SKAction.rotateByAngle(degToRad(0.0), duration: 0.1)
            let revert = SKAction.setTexture(textureAtlas.textureNamed(textureAtlas.textureNames[1] as! String))
            let sequence: SKAction = SKAction.sequence([pause, revert])
            runAction(sequence, withKey: "unhighlight")
        }
    }
    
    func wiggle() {
        if (moveable) {
            println("Wiggling!")
            let wiggleRight = SKAction.rotateByAngle(degToRad(Float(-15.0)), duration: 0.1)
            let pause = SKAction.rotateByAngle(degToRad(0.0), duration: 0.05)
            let backToCenter = SKAction.rotateToAngle(0.0, duration: 0.05)
            let wiggleLeft = SKAction.rotateByAngle(degToRad(Float(15.0)), duration: 0.1)
            let sequence: SKAction = SKAction.sequence([wiggleLeft, pause, backToCenter, pause, wiggleRight, pause, backToCenter])
            runAction(sequence, withKey: "wiggle")
        }
    }
    
    func degToRad(degree: Float) -> (CGFloat) {
        return CGFloat(Float(degree) / Float(180.0 * M_PI));
    }
    
    func moveTile(newLocation: CGPoint) {
        if moveable {
            prevPos.x = xPos
            prevPos.y = yPos
            
            xPos = newLocation.x
            yPos = newLocation.y
            
            momentum.x = xPos - prevPos.x
            momentum.y = yPos - prevPos.y
        
            position = newLocation
            
            var thisX = xPos + size.width/2
            if !(nextTile == Tile.nilTile) {
                let theNextTile = nextTile
                thisX += theNextTile.size.width/2
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
            runAction(action)
            
            if !(nextTile == Tile.nilTile){
                let theNextTile = nextTile
                theNextTile.moveTileAnimated(CGPoint(x: newLocation.x + size.width/2 + theNextTile.size.width/2, y: newLocation.y))
            }
        }
    }
    
    func distanceToPoint(point: CGPoint) -> CGFloat {
        return (abs(xPos - point.x) + abs(yPos - point.y))
    }
    
}
func == (lhs: Tile, rhs: Tile) -> Bool {
    return (lhs.word == rhs.word) && (lhs.position == rhs.position)
}

func < (lhs: Tile, rhs: Tile) -> Bool {
    return lhs.word < rhs.word
}