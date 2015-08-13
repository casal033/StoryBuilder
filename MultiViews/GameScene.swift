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

enum BodyType: UInt32 {
    //each new case gets twice the value of the case before it
    case tile = 1
    case trash = 2
}

var Adverb = "Adverb"
var Noun = "Noun"
var Verb = "Verb"
var Preposition = "Preposition"
var Pronoun = "Pronoun"
var Adjective = "Adjective"
var Conjunction = "Conjunction"
var Article = "Article"

let DEFAULT_WORD_LIST:[[String]] = [
    ["children", Noun],
    ["can", Verb],
    ["learn", Verb],
    ["to", Preposition],
    ["tell", Verb],
    ["stories", Noun],
    ["my", Adjective],
    ["funny", Adjective],
    ["dog", Noun],
    ["catch", Verb],
    ["the", Article],
    ["ball", Noun],
    ["play", Verb],
    ["with", Preposition],
    ["cat", Noun],
    ["fast", Adjective],
    ["see", Verb],
    ["it", Pronoun],
    ["bear", Noun],
    ["giraffe", Noun],
    ["here", Adverb],
    ["is", Verb],
    ["Batman", Noun],
    ["fly", Verb],
    ["for", Preposition],
    ["me", Pronoun],
    ["and", Conjunction],
    ["the", Article],
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
    ["look", Verb],
    ["where", Adverb],
    ["a", Article],
    ["one", Adjective],
    ["make", Verb],
    ["little", Adjective],
    ["my", Adjective],
]


class GameScene: SKScene, SKPhysicsContactDelegate {
    
    //let FRICTION: CGFloat = 10
    
    //let STICKINESS: CGFloat = 25
    var STICKY_POINT: CGPoint = CGPoint(x: 0, y: 0)
    let DEFAULT_STICKY_POINT: CGPoint = CGPoint(x: 0, y: 0)
    
    var current_x_offset: CGFloat = 0
    var current_y_offset: CGFloat = 0
    
    let RIGHT_BOUNDS: CGFloat = 700
    //let LEFT_BOUNDS: CGFloat = 200
    let LEFT_BOUNDS: CGFloat = 250
    
    var _words:[[String]] = WordList(arr: DEFAULT_WORD_LIST).wordsWithWordPacks
    //var _words:[String] = WordList(url: "http://facultypages.morris.umn.edu/~lamberty/research/sightWords.json").words
    //var _words:[String] = []
    var _currentLabel:SKLabelNode = SKLabelNode()
    
    var mySpeechSynthesizer:AVSpeechSynthesizer = AVSpeechSynthesizer()
    
    var tileX = CGFloat(275)
    var tileY = CGFloat(500)
    var extraWordCount = 0
    
    let tileLayer = SKNode()
    let gameLayer = SKNode()
    let wordBankLayer = SKNode()
    let sentenceLayer = SKNode()
    var wordIndex = Int()
    //let textureAtlas = SKTextureAtlas(named:"redTile.atlas")

    
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
        let trash = SKSpriteNode(imageNamed: "blankTile")
        var body = SKPhysicsBody(rectangleOfSize: trash.size)
        body.dynamic = false
        body.categoryBitMask = BodyType.trash.rawValue
        body.collisionBitMask = 0
        body.contactTestBitMask = BodyType.tile.rawValue
        
        trash.position = CGPointMake(300, 50)
        trash.physicsBody = body
        trash.zPosition = 15
        //addChild(trash)
        trash.name = "trashcan"
        
        
        mySpeechSynthesizer.stopSpeakingAtBoundary(AVSpeechBoundary.Word)
        self.physicsWorld.contactDelegate = self
        view.showsPhysics = false
        
        
    }
    
    func addTile(newWord: [String]) {
        // where to put the tile in the scene
        
        var tile:Tile
        // if there are multiple strings in the array, the second one will be the part of speech
        if newWord.count > 1 {
            tile = Tile(word: newWord[0], partOfSpeech: newWord[1], x: tileX, y: tileY)
        } else {
            tile = Tile(word: newWord[0], partOfSpeech: "", x: tileX, y: tileY)
        }
        
        if (tilesArray.count == 0) {
            tileX = 275
            tileY = 500
        } else if (tilesArray.count >= 1 && tilesArray[0].xPos < 800) {
            println("The tile at 0 in the array is: \(tilesArray[0])")
            println("The tiles are: \(tilesArray)")
            tile.makeNextOf(tilesArray[0])
        }
        tilesArray.insert(tile, atIndex: 0)
        
        tile.position = CGPoint(x: tile.xPos, y: tile.yPos)
        tileLayer.addChild(tile)
        
        speakWord(tile.word)
    }
    
    func resetTiles() {
        tileLayer.removeAllChildren()
        tilesArray = []
        wordIndex = 0
        //_words = WordList(url: "http://facultypages.morris.umn.edu/~lamberty/research/sightWords.json").words
        _words = WordList(arr: DEFAULT_WORD_LIST).wordsWithWordPacks
    }
    
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
        tile.rotate()
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
    
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
    }
    
    func didBeginContact(contact: SKPhysicsContact) {
        //called automatically when contact begins
        
        let firstNode = contact.bodyA.node as! SKSpriteNode
        let secondNode = contact.bodyB.node as! SKSpriteNode
        
        println("touching!!!!")
        
        if (contact.bodyA.categoryBitMask == BodyType.tile.rawValue) &&
            (contact.bodyB.categoryBitMask == BodyType.tile.rawValue) {
                if (firstNode.zPosition == 0 && secondNode.zPosition == 15){
                    let tile = firstNode as! Tile
                    tile.highlight()
                }
                if (secondNode.zPosition == 0 && firstNode.zPosition == 15){
                    let tile = secondNode as! Tile
                    tile.highlight()
                }
        }
        //if you are throwing away some tiles by releasing them over the trash can
        //if (contact.bodyA.categoryBitMask == BodyType.trash.rawValue) &&
        //    (contact.bodyB.categoryBitMask == BodyType.tile.rawValue) {
        //        let tile = secondNode as! Tile
        //        if tile.touchesEnded(<#touches: Set<NSObject>#>, withEvent: <#UIEvent#>)
                
        //}
        
        //this value holds onto whatever two things just contacted each other
    }
    
    func didEndContact(contact: SKPhysicsContact) {
        let firstNode = contact.bodyA.node as! SKSpriteNode
        let secondNode = contact.bodyB.node as! SKSpriteNode
        
        //println("done touching!!!!")
        
        if (contact.bodyA.categoryBitMask == BodyType.tile.rawValue) &&
            (contact.bodyB.categoryBitMask == BodyType.tile.rawValue) {
                if (firstNode.zPosition == 0 && secondNode.zPosition == 15) {
                    let tile = firstNode as! Tile
                    tile.highlightRevert()
                }
                if (secondNode.zPosition == 0 && firstNode.zPosition == 15){
                    let tile = secondNode as! Tile
                    tile.highlightRevert()
                }
        }
        //called automatically when contact ends
    }
    
    func revertTileHighlighting() {
        for tile in tilesArray {
            tile.highlightRevert()
            tile.zPosition = 0
        }
    }
}
