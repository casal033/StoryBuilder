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

var Adverb = "Adverb"
var Noun = "Noun"
var Verb = "Verb"
var Preposition = "Preposition"
var Pronoun = "Pronoun"
var Adjective = "Adjective"
var Conjunction = "Conjunction"
var Article = "Article"

let DEFAULT_WORD_LIST:[[String]] = [
    ["catch", Verb],
    ["ball", Noun],
    ["fast", Adjective],
    ["Batman", Noun],
    ["Iron Man", Noun],
    ["fly", Verb],
    ["bear", Noun],
    ["cat", Noun],
    ["dog", Noun],
    ["giraffe", Noun],
    ["here", Adverb],
    ["for", Preposition],
    ["me", Pronoun],
    ["and", Conjunction],
    ["play", Verb],
    ["see", Verb],
    ["it", Pronoun],
    ["down", Adverb],
    ["the", Article],
    ["is", Verb],
    ["blue", Adjective],
    ["house", Noun],
    ["you", Pronoun],
    ["in", Preposition],
    ["go", Verb],
    ["yellow", Adjective],
    ["big", Adjective],
    ["I", Pronoun],
    ["said", Verb],
    ["come", Verb],
    ["up", Adverb],
    ["not", Adverb],
    ["away", Adverb],
    ["find", Verb],
    ["run", Verb],
    ["red", Adjective],
    ["jump", Verb],
    ["can", Verb],
    ["we", Pronoun],
    ["help", Verb],
    ["two", Adjective],
    ["funny", Adjective],
    ["look", Verb],
    ["where", Adverb],
    ["a", Article],
    ["one", Adjective],
    ["to", Preposition],
    ["make", Verb],
    ["little", Adjective],
    ["my", Adjective],
    ["three", Adjective]
]


class GameScene: SKScene {
    
    //let FRICTION: CGFloat = 10
    
    //let STICKINESS: CGFloat = 25
    var STICKY_POINT: CGPoint = CGPoint(x: 0, y: 0)
    let DEFAULT_STICKY_POINT: CGPoint = CGPoint(x: 0, y: 0)
    
    var current_x_offset: CGFloat = 0
    var current_y_offset: CGFloat = 0
    
    let RIGHT_BOUNDS: CGFloat = 700
    //let LEFT_BOUNDS: CGFloat = 200
    let LEFT_BOUNDS: CGFloat = 250
    
    var _words:[[String]] = WordList(arr: DEFAULT_WORD_LIST).wordsWithCategories
    //var _words:[String] = WordList(url: "http://facultypages.morris.umn.edu/~lamberty/research/sightWords.json").words
    //var _words:[String] = []
    var _currentLabel:SKLabelNode = SKLabelNode()
    
    var mySpeechSynthesizer:AVSpeechSynthesizer = AVSpeechSynthesizer()
    
    var tileX = CGFloat(200)
    var tileY = CGFloat(200)
    var extraWordCount = 0
    
    let tileLayer = SKNode()
    let gameLayer = SKNode()
    let wordBankLayer = SKNode()
    let sentenceLayer = SKNode()
    var wordIndex = Int()

    
    var selection: Tile = Tile.nilTile
    
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
        
        Tile.nilTile.nextTile = Tile.nilTile
        Tile.nilTile.prevTile = Tile.nilTile
    }
    
    override func didMoveToView(view: SKView) {
        /* Setup your scene here */
        mySpeechSynthesizer.stopSpeakingAtBoundary(AVSpeechBoundary.Word)
    }
    
    func addTile(newWord: [String]) {
        // where to put the tile in the scene
        //tileX = CGFloat(arc4random_uniform(600) + 200)
        tileX = CGFloat(arc4random_uniform(600) + 250)
        tileY = CGFloat(arc4random_uniform(500) + 100)
        
        var tile:Tile
        // if there are multiple strings in the array, the second one will be the part of speech
        if newWord.count > 1 {
            tile = Tile(word: newWord[0], partOfSpeech: newWord[1], x: tileX, y: tileY)
        } else {
            tile = Tile(word: newWord[0], partOfSpeech: "", x: tileX, y: tileY)
        }
        
        var numberOfTilesUnderLeftCorners: Int = count(tile.leftCornersInside(tilesArray))
        var numberOfTries: Int = 0
        while (numberOfTilesUnderLeftCorners > 0) && (numberOfTries < 4) {
            if (tile.xPos + 50 > RIGHT_BOUNDS) {
//                tile.xPos = CGFloat(arc4random_uniform(300) + 200)
                tile.xPos = CGFloat(arc4random_uniform(300) + 250)
            }
            else {
                tile.xPos += 50
            }
            numberOfTilesUnderLeftCorners = count(tile.leftCornersInside(tilesArray))
            numberOfTries += 1
        }
        
        tilesArray.insert(tile, atIndex: 0)
        //println("the current tiles are: \(tilesArray)")

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
    
    //    func addTileFromWordList() {
    //        if (tilesArray.count - extraWordCount < _words.count) {
    //            //addTile(_words[tilesArray.count - extraWordCount])
    //            let newPosition = Int(arc4random_uniform(UInt32(tilesArray.count)))
    //            addTile(_words[newPosition])
    //            _words.removeAtIndex(newPosition)
    //        }
    //    }
    
    func addTileFromWordList() {
        if wordIndex == 0 {
            addTile(_words[wordIndex])
            wordIndex++
        } else if (wordIndex < 51) {
            addTile(_words[wordIndex])
            wordIndex++
        } else {
            wordIndex = 0
        }
        println(wordIndex)
    }
    
    func addExtraTile(newWord: String) {
        addTile([newWord])
        extraWordCount++
    }
    
    func speakSentence(speakFromHere: Tile) {
        let phrase: [Tile] = speakFromHere.getPhraseTiles()
        println("The phrase is: \(phrase)")
        
        var sentence = speakFromHere.word
        var nextTile = speakFromHere.nextTile
        while nextTile != Tile.nilTile {
            sentence += " " + nextTile.word
            nextTile = nextTile.nextTile
        }
        speakWord(sentence)
    }
    
    func speakTile(tile: Tile) {
        speakWord(tile.word)
        rotateTile(tile)
    }
    
    func selectTile(location: CGPoint) {
        var tile: Tile = findTileTouched(location)
        println("\tSELECTING \(tile.word)")
        speakSentence(tile)
        rotateTile(tile)
    }

    func findTileTouched(touchLocation: CGPoint) -> (Tile) {
        for tile in tilesArray {
            if tile.containsPoint(touchLocation) {
                return (tile)
            }
        }
        return Tile.nilTile
    }
    
    func selectNodeForTouch(location: CGPoint) {
        let tile: Tile = findTileTouched(location)
        let touchedNode: SKSpriteNode = tile.sprite
        if (tile != Tile.nilTile) {
            println("\nprevTile is: [\(tile.prevTile.word)]=>[[\(tile.word)]]=> nextTile is [\(tile.nextTile.word)]")
        }
        selection.sprite.removeAllActions()
        selection.sprite.runAction(SKAction.rotateToAngle(0.0, duration: 0.1))
        selection = tile
        
        selection.sprite.removeFromParent()
        tileLayer.addChild(selection.sprite)
        for tile in selection.getPhraseTiles() {
            tile.sprite.removeFromParent()
            tileLayer.addChild(tile.sprite)
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
            //println("Speaking!")
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
        //println("selection previous after touch: \(selection.prevTile)")
        //selection.detachFromPrev()
        //println("selection previous after detach: \(selection.prevTile)")
        current_x_offset = selection.xPos - positionInScene.x
        current_y_offset = selection.yPos - positionInScene.y
        
        currentPhrase = Phrase(root: selection, x: selection.xPos, y: selection.yPos)
        
        STICKY_POINT = CGPoint(x: selection.xPos, y: selection.yPos)

        println("Hello!")
        selectTile(touch.locationInNode(tileLayer))
    }
    
    override func touchesMoved(touches: Set<NSObject>, withEvent event: UIEvent) {
        let touch = touches.first as! UITouch
        let location = touch.locationInNode(tileLayer)
        let positionInScene: CGPoint = touch.locationInNode(self)
        let moveToPosition: CGPoint = CGPoint(x: positionInScene.x + current_x_offset, y: positionInScene.y + current_y_offset)
        if selection != Tile.nilTile {
            //println("selection previous before detach: \(selection.prevTile)")
            //selection.detachFromPrev()
            //println("selection previous after detach: \(selection.prevTile)")
            selection.moveTile(moveToPosition)
        }
    }
    
    override func touchesEnded(touches: Set<NSObject>, withEvent event: UIEvent) {
        let touch = touches.first as! UITouch
        let tile = findTileTouched(touch.locationInNode(tileLayer))
        if !tile.didMove() {
            println("Hello!")
            selectTile(touch.locationInNode(tileLayer))
            println("\tthe sticky point is this far from tile: \(tile.distanceToPoint(STICKY_POINT))")
            let moveToPoint = CGPoint(x: tile.xPos + tile.momentum.x, y: tile.yPos + tile.momentum.y)
            tile.resetPrevPos()
        } else {
            if tile.prevTile != Tile.nilTile {
                tile.detachFromPrev()
            }
            STICKY_POINT = DEFAULT_STICKY_POINT
            let tilesUnderLeftCorners = tile.leftCornersInside(tilesArray)
            println("The selected tile overlaps \(count(tilesUnderLeftCorners)) tiles")
            for othertile in tilesUnderLeftCorners {
                println("adding \(tile.getPhraseTiles()) after \(othertile)")
                tile.makeNextOf(othertile)
                tile.moveTileAnimated(CGPoint(
                    x: othertile.xPos + (othertile.sprite.size.width/2) + (tile.sprite.size.width/2),
                    y: othertile.yPos))
                return
            }
            let tilesUnderRightCorners = tile.rightCornersInside(tilesArray)
            println("The selected tile overlaps \(count(tilesUnderRightCorners)) tiles")
            for othertile in tilesUnderRightCorners {
                println("ADDING \(tile.getPhraseTiles()) BEFORE \(othertile)")
                tile.makePrevOf(othertile)
                tile.moveTileAnimated(CGPoint(
                    x: othertile.xPos - (othertile.sprite.size.width/2) + (tile.sprite.size.width/2),
                    y: othertile.yPos))
                return
            }
        }
    }
   
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
    }
}
