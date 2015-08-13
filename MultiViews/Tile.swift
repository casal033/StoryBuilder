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
    
    var baseColorName: String
    
    var current_x_offset: CGFloat = 0
    var current_y_offset: CGFloat = 0
    
    var prevPos: CGPoint
    var textureAtlas = SKTextureAtlas(named:"greenTile.atlas")
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
        self.baseColorName = "nil"
        
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
        self.prevPos = CGPoint(x: x, y: y)
        if (word == "nil") { self.moveable = false }
        else { self.moveable = true }
        
        let spriteSize = CGSize(width: max(CGFloat(20 * length), 50) + 10.0, height: 85.0)
        var tileImage = ""
        if partOfSpeech == "Noun" || partOfSpeech == "Pronoun" {
            tileImage = "blue1"
            baseColorName = "blue"
        }
        else if partOfSpeech == "Verb" {
            tileImage = "red1"
            baseColorName = "red"
        }
        else if partOfSpeech == "Article" || partOfSpeech == "Conjunction" || partOfSpeech == "Preposition" || partOfSpeech == "Adverb" {
            tileImage = "YellowTile"
            baseColorName = "yellow"
        }
        else if partOfSpeech == "Adjective"  {
            tileImage = "green1"
            baseColorName = "green"
        }
        else {
            let selectionNumber = Int(arc4random_uniform(UInt32(count(colors))))
            tileImage = colors[selectionNumber] + "Tile"
            baseColorName = colors[selectionNumber].lowercaseString
        }
        textureAtlas = SKTextureAtlas(named:"\(baseColorName)Tile.atlas")
        //sprite = SKSpriteNode(texture: , size: spriteSize)
        super.init(texture: SKTexture(imageNamed: tileImage), color: nil, size: spriteSize)
        let label = SKLabelNode()
        label.fontName = "Thonburi"
        label.text = word
        addChild(label)
        label.position = CGPoint(x: 0, y: -6)
        
        name = word
        userInteractionEnabled = true
        
        var body = SKPhysicsBody(rectangleOfSize: self.size)
        body.dynamic = true
        body.affectedByGravity = false
        body.categoryBitMask = BodyType.tile.rawValue
        body.collisionBitMask = 0
        body.contactTestBitMask = BodyType.trash.rawValue | BodyType.tile.rawValue
        
        self.physicsBody = body
        
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
        //otherTile.prevTile.highlightRevert()
        otherTile.prevTile = self.phrase.last()
        self.phrase.last().nextTile = otherTile
        moveTileAnimated(CGPoint(
            x: otherTile.position.x - (otherTile.size.width/2) + (size.width/2),
            y: otherTile.position.y))
        //otherTile.highlightRevert()
        
    }
    
    func makeNextOf(otherTile: Tile) {
        println("the last tile in the added phrase is: \(self.phrase.last())")
        detachFromPrev()
        if otherTile.nextTile != Tile.nilTile {
            otherTile.nextTile.prevTile = self.phrase.last()
        }
        self.phrase.last().nextTile = otherTile.nextTile
        //otherTile.nextTile.highlightRevert()
        otherTile.nextTile = self
        self.prevTile = otherTile
        moveTileAnimated(CGPoint(
            x: otherTile.position.x + (otherTile.size.width/2) + (size.width/2),
            y: otherTile.position.y))
        //otherTile.highlightRevert()
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
            let highlight = SKAction.setTexture(textureAtlas.textureNamed("\(baseColorName)2"))
            runAction(highlight, withKey: "highlight")
        }
    }
    
    func highlightRevert() {
        if (moveable) {
            let pause = SKAction.rotateByAngle(degToRad(0.0), duration: 0.3)
            let revert = SKAction.setTexture(textureAtlas.textureNamed("\(baseColorName)1"))
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
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        var gameScene = self.scene as! GameScene
        let touch: UITouch = touches.first as! UITouch
        let location = touch.locationInNode(scene)
        let touchedNode = nodeAtPoint(location)
        
        removeAllActions()
        for tile in getPhraseTiles() {
            tile.zPosition = 15
            tile.highlight()
        }
        println("The touch began at location \(location)")
        
        gameScene.speakSentence(self)
        current_x_offset = position.x - location.x
        current_y_offset = position.y - location.y
        
        gameScene.STICKY_POINT = CGPoint(x: location.x, y: position.y)
        
    }
    
    override func touchesMoved(touches: Set<NSObject>, withEvent event: UIEvent) {
        let touch = touches.first as! UITouch
        let positionInScene: CGPoint = touch.locationInNode(scene)
        let newPosition: CGPoint = CGPoint(x: positionInScene.x + current_x_offset, y: positionInScene.y + current_y_offset)
        if self != Tile.nilTile {
            moveTile(newPosition)
        }
    }
    
    override func touchesEnded(touches: Set<NSObject>, withEvent event: UIEvent) {
        var gameScene = self.scene as! GameScene
        let touch = touches.first as! UITouch
        //this next thing, we used to just do for tiels in the seemingly most impacted phrase...
        //it might be a bit of a hack to unhighlight all the tiles in the scene, but this does
        //seem to work without being super horrible. We shall see.
        gameScene.revertTileHighlighting()
        println("I found a tile and touch ended")
        if !didMove() {
            let moveToPoint = CGPoint(x: position.x + momentum.x, y: position.y + momentum.y)
            resetPrevPos()
        } else
            if prevTile != Tile.nilTile {
                detachFromPrev()
        }
        gameScene.STICKY_POINT = gameScene.DEFAULT_STICKY_POINT
        
        let tilesUnderLeftCorners = leftCornersInside(gameScene.tilesArray)
        //println("The selected tile overlaps \(count(tilesUnderLeftCorners)) tiles")
        for othertile in tilesUnderLeftCorners {
            println("adding \(getPhraseTiles()) after \(othertile)")
            makeNextOf(othertile)
            return
        }
        let tilesUnderRightCorners = rightCornersInside(gameScene.tilesArray)
        println("The selected tile overlaps \(count(tilesUnderRightCorners)) tiles")
        for othertile in tilesUnderRightCorners {
            println("ADDING \(getPhraseTiles()) BEFORE \(othertile)")
            makePrevOf(othertile)
            return
        }
    }

    override func touchesCancelled(touches: Set<NSObject>, withEvent event: UIEvent) {
        var gameScene = self.scene as! GameScene
        let touch = touches.first as! UITouch
        //this next thing, we used to just do for tiels in the seemingly most impacted phrase...
        //it might be a bit of a hack to unhighlight all the tiles in the scene, but this does
        //seem to work without being super horrible. We shall see.
        gameScene.revertTileHighlighting()
        println("I found a tile and touch was cancelled")
    }

}
func == (lhs: Tile, rhs: Tile) -> Bool {
    return (lhs.word == rhs.word) && (lhs.position == rhs.position)
}

func < (lhs: Tile, rhs: Tile) -> Bool {
    return lhs.word < rhs.word
}