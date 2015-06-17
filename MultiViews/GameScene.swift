//
//  GameScene.swift
//  MultiViews
//
//  Created by Administrator on 7/15/14.
//  Copyright (c) 2014 Administrator. All rights reserved.
//

import Foundation
import SpriteKit
import AVFoundation

   let DEFAULT_WORD_LIST:[[String]] = [
        ["can","verb"],
        ["funny","adjective"],
        ["I", "pronoun"],
        ["to", "article"],
        ["look", "verb"],
        ["a", "article"],
        ["three", "adjective", "number"],
        ["find", "verb"],
        ["school", "noun"],
        ["go", "verb"],
        ["help", "verb"],
        ["away", "adjective"],
        ["dog", "noun", "animals"],
        ["bird", "noun", "animals"],
        ["cat", "noun", "animals"],
        ["come", "verb"],
        ["run","verb"],
        ["two", "adjective", "number"],
        ["blue", "adjective", "color"],
        ["red", "adjective", "color"],
        ["yellow", "adjective", "color"],
        ["ten", "adjective", "number"],
        ["fifty", "adjective", "number"],
        ["fourteen", "adjective", "number"],
        ["brother", "noun", "family"],
        ["mother", "noun", "family"],
        ["sister", "noun", "family"],
        ["horse", "noun", "animals"]
    ]


class GameScene: SKScene {
    
    //let FRICTION: CGFloat = 10
    
    //let STICKINESS: CGFloat = 25
    var STICKY_POINT: CGPoint = CGPoint(x: 0, y: 0)
    let DEFAULT_STICKY_POINT: CGPoint = CGPoint(x: 0, y: 0)
    
    var current_x_offset: CGFloat = 0
    var current_y_offset: CGFloat = 0
    
    let RIGHT_BOUNDS: CGFloat = 700
    let LEFT_BOUNDS: CGFloat = 50
    
    var _words:[[String]] = WordList(arr: DEFAULT_WORD_LIST).wordsWithCategories
    //var _words:[String] = WordList(url: "http://facultypages.morris.umn.edu/~lamberty/research/sightWords.json").words
    //var _words:[String] = []
    var _currentLabel:SKLabelNode = SKLabelNode()
    
    var mySpeechSynthesizer:AVSpeechSynthesizer = AVSpeechSynthesizer()
    
    var tileX = CGFloat(200)
    var tileY = CGFloat(200)
    var extraWordCount = 0
    let nilTile: Tile = Tile()
    
    let tileLayer = SKNode()
    let gameLayer = SKNode()
    let wordBankLayer = SKNode()
    let sentenceLayer = SKNode()
    
    var selection: Tile = Tile(word: "nil", partOfSpeech: "", x: 0, y: 0)
    
    var tilesArray: [Tile] = []
    var selectedNode: SKSpriteNode?
    var currentPhrase: Phrase?
    
    required init(coder: NSCoder) {
        fatalError("NSCoding not supported")
    }
    
    override init(size: CGSize) {
        super.init(size: size)
        addChild(gameLayer)
        gameLayer.addChild(tileLayer)
        gameLayer.addChild(wordBankLayer)
        
        nilTile.nextTile = nilTile
        nilTile.prevTile = nilTile
    }
    
    override func didMoveToView(view: SKView) {
        /* Setup your scene here */
        mySpeechSynthesizer.stopSpeakingAtBoundary(AVSpeechBoundary.Word)
    }
    
    func addTile(newWord: [String]) {
        // where to put the tile in the scene
        tileX = CGFloat(arc4random_uniform(600) + 100)
        tileY = CGFloat(arc4random_uniform(500) + 100)
        
        var tile:Tile
        // if there are multiple strings in the array, the second one will be the part of speech
        if newWord.count > 1 {
            tile = Tile(word: newWord[0], partOfSpeech: newWord[1], x: tileX, y: tileY)
        } else {
            tile = Tile(word: newWord[0], partOfSpeech: "", x: tileX, y: tileY)
        }
        
        while (count(findTileOverlap(tile)) > 0) {
            if (tile.xPos + 50 > RIGHT_BOUNDS) {
                tile.xPos = 100
            }
            else {
                tile.xPos += 50
            }
        }
        
        tilesArray.insert(tile, atIndex: 0)
        println(tilesArray)

        tile.sprite.position = CGPoint(x: tile.xPos, y: tile.yPos)
        tileLayer.addChild(tile.sprite)
        
        speakWord(tile.word)
    }
    
    func resetTiles() {
        tileLayer.removeAllChildren()
        tilesArray = []
        extraWordCount = 0
        //_words = WordList(url: "http://facultypages.morris.umn.edu/~lamberty/research/sightWords.json").words
        _words = WordList(arr: DEFAULT_WORD_LIST).wordsWithCategories
    }
    
    func addTileFromWordList() {
        if (tilesArray.count - extraWordCount < _words.count) {
            //addTile(_words[tilesArray.count - extraWordCount])
            let newPosition = Int(arc4random_uniform(UInt32(tilesArray.count)))
            addTile(_words[newPosition])
            _words.removeAtIndex(newPosition)
        }
    }
    
    func addExtraTile(newWord: String) {
        addTile([newWord])
        extraWordCount++
    }
    
    
    func findTileTouched(location: CGPoint) -> (Tile) {
        for tile in tilesArray {
            if tile.locationIsInBounds(location) {
                return (tile)
            }
        }
        return nilTile
    }
    
    func findTileOverlap(tile: Tile) -> ([Tile]) {
        var overlappingTiles: [Tile] = []
        
        let halfWidth = tile.sprite.size.width/2
        let halfHeight = tile.sprite.size.height/2
        
        let left = tile.xPos - halfWidth
        let right = tile.xPos + halfWidth
        let top = tile.yPos - halfHeight
        let bottom = tile.yPos + halfHeight
        
        for otherTile in tilesArray {
            if tile != otherTile {
                let corners = otherTile.getCorners()
                for corner in corners {
                    if !contains(overlappingTiles, otherTile) && tile.locationIsInBounds(corner) {
                        overlappingTiles.append(otherTile)
                    }
                }
            }
        }
        return overlappingTiles
    }
    
    func selectNodeForTouch(location: CGPoint) {
        let tile: Tile = findTileTouched(location)
        let touchedNode: SKSpriteNode = tile.sprite
        if (tile != nilTile) {
            println("Touched Node: \(tile.word) Next Node: \(tile.nextTile!.word), Prev Node: \(tile.prevTile!.word)")
        }
        selection.sprite.removeAllActions()
        selection.sprite.runAction(SKAction.rotateToAngle(0.0, duration: 0.1))
        selection = tile
        
        selection.sprite.removeFromParent()
        tileLayer.addChild(selection.sprite)
        for word in selection.getPhrase().words {
            word.sprite.removeFromParent()
            tileLayer.addChild(word.sprite)
        }
        
        if count(tilesArray) > 0 {
            for i in (0...(count(tilesArray) - 1)) {
                if (tilesArray[i] == selection) {
                    tilesArray.insert(tilesArray[i], atIndex: 0)
                    tilesArray.removeAtIndex(i + 1)
                    break
                }
            }
        }
    }
    
    func speakSentence(speakFromHere: Tile) {
        var sentence = speakFromHere.word
        var nextTile = speakFromHere.nextTile!
        while nextTile != nilTile {
           sentence += " " + nextTile.word
           nextTile = nextTile.nextTile!
        }
        speakWord(sentence)
    }
    
    //func speakSentence(startTile: Tile){
    //    var sentence = startTile.getPhrase().words
    //    for tile in sentence{
    //        speakTile(tile)
    //    }
   // }
    
    func speakTile(tile: Tile) {
        speakWord(tile.word)
        rotateTile(tile)
    }
    
    func selectTile(location: CGPoint) {
        var tile: Tile = findTileTouched(location)
        println("\tSELECTING \(tile.word)")
        //speakTile(tile)
        speakSentence(tile)
        rotateTile(tile)
    }
    
    func selectNextTile(tile: Tile, sentence: String) {
        
    }
    
    func rotateTile(tile: Tile) {
        if (tile.moveable) {
            println("Rotating!")
            let sequence: SKAction = SKAction.sequence([SKAction.rotateByAngle(degToRad(Float(-60.0)), duration: 0.3), SKAction.rotateByAngle(degToRad(0.0), duration: 0.2), SKAction.rotateToAngle(0.0, duration: 0.3)])
            tile.sprite.runAction(SKAction.repeatAction(sequence,count: 1))
        }
    }
    
    func degToRad(degree: Float) -> (CGFloat) {
        return CGFloat(Float(degree) / Float(180.0 * M_PI));
    }
    
    func speakWord(str: String) {
        if (str != "nil") {
            println("Speaking!")
            var myString = str
            if (myString == "I") {
                myString = "i"
            }
            let myUtterance = AVSpeechUtterance(string: myString)
            myUtterance.voice = AVSpeechSynthesisVoice(language: "en-US")
            myUtterance.rate = (AVSpeechUtteranceMinimumSpeechRate + AVSpeechUtteranceDefaultSpeechRate) / 8
            mySpeechSynthesizer .speakUtterance(myUtterance);
        }
    }
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        let touch: UITouch = touches.first as! UITouch
        let positionInScene: CGPoint = touch.locationInNode(self)
        selectNodeForTouch(positionInScene)
        current_x_offset = selection.xPos - positionInScene.x
        current_y_offset = selection.yPos - positionInScene.y
        
        currentPhrase = Phrase(words: selection.getPhrase().words, x: selection.xPos, y: selection.yPos)
        
        //if (findTileTouched(positionInScene).prevTile != nilTile) {
        STICKY_POINT = CGPoint(x: selection.xPos, y: selection.yPos)
        //}
        println("Hello!")
        selectTile(touch.locationInNode(tileLayer))
    }
    
    override func touchesMoved(touches: Set<NSObject>, withEvent event: UIEvent) {
        let touch = touches.first as! UITouch
        let location = touch.locationInNode(tileLayer)
        let positionInScene: CGPoint = touch.locationInNode(self)
        let moveToPosition: CGPoint = CGPoint(x: positionInScene.x + current_x_offset, y: positionInScene.y + current_y_offset)
        if selection.word != "nil" {
            selection.moveTile(moveToPosition)
            if selection.prevTile != nilTile {
               selection.prevTile!.nextTile = nilTile
                selection.prevTile = nilTile
            }
        }
    }
    
    override func touchesEnded(touches: Set<NSObject>, withEvent event: UIEvent) {
        let touch = touches.first as! UITouch
        let tile = findTileTouched(touch.locationInNode(tileLayer))
        //if tile.xPos == tile.prevPos.x && tile.yPos == tile.prevPos.y {
            println("Hello!")
            selectTile(touch.locationInNode(tileLayer))
            println(tile.distanceToPoint(STICKY_POINT))
            let moveToPoint = CGPoint(x: tile.xPos + tile.momentum.x, y: tile.yPos + tile.momentum.y)
            tile.resetPrevPos()
        //}
        STICKY_POINT = DEFAULT_STICKY_POINT
        let overlappingTiles = findTileOverlap(tile)
        println("Overlaps: \(count(overlappingTiles))")
        for othertile in overlappingTiles {
            if count(tile.getPhrase().words) == 0 {
                if (tile.xPos < (othertile.xPos)) {
                    tile.nextTile = othertile
                    othertile.prevTile = tile
                    othertile.moveTileAnimated(CGPoint(x: tile.xPos + (tile.sprite.size.width/2) + (othertile.sprite.size.width/2), y: tile.yPos))
                } else {
                    tile.prevTile = othertile
                    othertile.nextTile = tile
                    tile.moveTileAnimated(CGPoint(x: othertile.xPos + (othertile.sprite.size.width/2) + (tile.sprite.size.width/2), y: othertile.yPos))
                }
            } else {
                othertile.moveTileAnimated(CGPoint(x: othertile.xPos, y: othertile.yPos + tile.sprite.size.height))
            }
        }
    }
   
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
    }
}
