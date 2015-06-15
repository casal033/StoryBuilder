//
//  GameViewController.swift
//  MultiViews
//
//  Created by Administrator on 7/15/14.
//  Copyright (c) 2014 Administrator. All rights reserved.
//

import UIKit
import SpriteKit

extension SKNode {
    class func unarchiveFromFile(file : NSString) -> SKNode? {
        
        let path = NSBundle.mainBundle().pathForResource(file as String, ofType: "sks")
        
        var sceneData = NSData(contentsOfFile: path!, options: .DataReadingMappedIfSafe, error: nil)
        var archiver = NSKeyedUnarchiver(forReadingWithData: sceneData!)
        
        archiver.setClass(self.classForKeyedUnarchiver(), forClassName: "SKScene")
        let scene = archiver.decodeObjectForKey(NSKeyedArchiveRootObjectKey) as! GameScene
        archiver.finishDecoding()
        return scene
    }
}



class GameViewController: UIViewController {
    
    var x: CGFloat = 50
    
    func populateSelectorByLetter(letter: String) {
        
        x = 50
        
        for word in _words
        {
            //if word[0][word[0].startIndex...word[0].startIndex] == letter {
            if String(word[advance(word.startIndex, 1)] as Character) == letter {
                var wordButton = UIButton()
                var wordLabel = UILabel()
            
                wordLabel.text = word
                wordLabel.font = UIFont(name: "MarkerFelt-Thin", size: 30)
                //wordLabel.textColor = UIColor.blueColor()
                wordLabel.textAlignment = .Center
                wordLabel.frame = CGRectMake(0, 0, 100, 200)
                
                wordButton.setTitleColor(UIColor.blueColor(), forState: .Normal)
                wordButton.frame = CGRectMake(x - 50, -50, 300, 170)
                wordButton.backgroundColor = UIColor(red: 0.7, green: 0.5, blue: 0.9, alpha: 1.0)
            
                let add: CGFloat = CGFloat(count(wordLabel.text!))
                if add > 8 {
                    x += (100 + (add * 15))
                }
                else {
                    x += 150
                }
                
                wordButton.addTarget(self, action: "pressed:", forControlEvents: .TouchUpInside)
            
                //self.view.addSubview(wordButton)
                scrollView.addSubview(wordButton)
                wordButton.addSubview(wordLabel)
            }
        }
        wordBar.frame.origin.x = 0
    }
    
  /*  func populateSelectorByTag(tag: String) {
        
        x = 50
        
        for word in _words
        {
            if contains(word[1...count(word) - 1], tag) {
                var wordButton = UIButton()
                var wordLabel = UILabel()
                
                wordLabel.text = word[0]
                wordLabel.font = UIFont(name: "MarkerFelt-Thin", size: 30)
                wordLabel.textAlignment = .Center
                wordLabel.frame = CGRectMake(0, 0, 100, 200)
                
                wordButton.setTitleColor(UIColor.blueColor(), forState: .Normal)
                wordButton.frame = CGRectMake(x - 50, -50, 300, 170)
                wordButton.backgroundColor = UIColor(red: 0.7, green: 0.5, blue: 0.9, alpha: 1.0)
                
                let add: CGFloat = CGFloat(count(wordLabel.text!))
                if add > 8 {
                    x += (100 + (add * 15))
                }
                else {
                    x += 150
                }
                
                wordButton.addTarget(self, action: "pressed:", forControlEvents: .TouchUpInside)
                
                scrollView.addSubview(wordButton)
                wordButton.addSubview(wordLabel)
            }
        }
        wordBar.frame.origin.x = 0
    } */
    
    func populateSelector() {
        
        let fillTags = TagView.items?.count <= 1
        
        x = 50
        
        var listOfTags: [String] = []
        
        for word in _words
        {
            var wordButton = UIButton()
            var wordLabel = UILabel()
                
            wordLabel.text = word
            wordLabel.font = UIFont(name: "Thonburi", size: 30)
            wordLabel.textAlignment = .Center
            wordLabel.frame = CGRectMake(0, 0, 100, 200)
            
            wordButton.setTitleColor(UIColor.blueColor(), forState: .Normal)
            wordButton.frame = CGRectMake(x - 50, -50, 300, 170)
            wordButton.backgroundColor = UIColor(red: 0.7, green: 0.5, blue: 0.9, alpha: 1.0)
                
            let add: CGFloat = CGFloat(count(wordLabel.text!))
            
            if add > 8 {
                x += (100 + (add * 15))
            }
            else {
                x += 150
            }
            
            wordButton.addTarget(self, action: "pressed:", forControlEvents: .TouchUpInside)
            
            scrollView.addSubview(wordButton)
            wordButton.addSubview(wordLabel)
            
            //Find tags and put them in the toolbar:
            var items = [AnyObject]()
            //items.append(UIBarButtonItem(title: "all", style: .Plain, target: self, action: "allButtonPressed:"))
            
            if fillTags {
                
            
            items += TagView.items!
            
        /*    for tag in word[1...count(word) - 1] {
                if !contains(listOfTags, tag) {
                    listOfTags.append(tag)
                    
                    items.append(UIBarButtonItem(title: tag, style: .Plain, target: self, action: "showTag:"))
                    
                }
            }
            TagView.items = items*/
            }
        }
        wordBar.frame.origin.x = 0
    }
    
    
    
    let panRec = UIPanGestureRecognizer()
    let tapRec = UITapGestureRecognizer()
    
    @IBOutlet weak var TagView: UIToolbar!
    @IBOutlet weak var wordSelectionView: UIImageView!
    @IBOutlet weak var scrollView: UIScrollView!
    
    var wordBar: UIImageView = UIImageView(image: UIImage(named: "purpleRectangle"));
    
    @IBAction func allButtonPressed(sender: AnyObject) {
        let subViews: Array = scrollView.subviews
        for subview in subViews
        {
            subview.removeFromSuperview()
        }
        populateSelector()
    }
    
    var skView: SKView!
    var scene: GameScene!
    
    @IBOutlet var Word1: UITextField?
    
    @IBAction func AddExtraWord(sender: AnyObject) {
        if (Word1!.text != "" && count(Word1!.text.utf16) < 10) {
            scene.addExtraTile(Word1!.text)
            Word1!.text = ""
        }
    }
    
    
    @IBAction func ResetButtonPressed(sender: AnyObject) {
        scene.resetTiles()
    }
    
    @IBAction func NextButtonPressed(sender: AnyObject) {
        scene.addTileFromWordList()
    }
    
    func tappedView() {
        
    }
    
    //var _words:[[String]] = WordList(arr: DEFAULT_WORD_LIST).wordsWithCategories
    //var _words:[String] = WordList(url: "https://teacherwordriver.herokuapp.com/api/tile").words
    //var _words:[String] = WordList(url: "http://facultypages.morris.umn.edu/~lamberty/research/sightWords.json").words
    
    //URLS for accessing apis
    
    func getStudentWords(){
        
        let dataGrabber = WordList(url: "https://teacherwordriver.herokuapp.com/api/students");
        let _categoriesIDs:Array<JSON> = dataGrabber.getStudentContextIDs("https://teacherwordriver.herokuapp.com/api/students");
        var _looseTilesIDs:Array<JSON> = dataGrabber.getStudentLooseTilesIDs("https://teacherwordriver.herokuapp.com/api/students")
        
        var _categories:Dictionary<String, String> = WordList(urlCategories: "https://teacherwordriver.herokuapp.com/api/categories").category
        var _tiles:Dictionary<String, Array<String>> = WordList(urlTiles: "https://teacherwordriver.herokuapp.com/api/tile").tiles
    }
    
    var _words:[String] = WordList(url: "https://teacherwordriver.herokuapp.com/api/tile").words;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scrollView.addSubview(wordSelectionView)
        
        // 2
        scrollView.contentSize = CGSize(width: CGFloat(count(_words) * 150), height: wordBar.frame.size.height)
        //scrollView.contentSize.width = count(WordList) * 10
        
        let scrollViewFrame = scrollView.frame
        let scaleWidth = scrollViewFrame.size.width / scrollView.contentSize.width
        let scaleHeight = scrollViewFrame.size.height / scrollView.contentSize.height
        let minScale = min(scaleWidth, scaleHeight);
        scrollView.minimumZoomScale = minScale;
        
        // 5
        scrollView.maximumZoomScale = 1.0
        scrollView.zoomScale = minScale;
        
        tapRec.addTarget(self, action: "tappedView")
        panRec.addTarget(self, action: "draggedView")
        
        populateSelector()
        
        let skView = self.view as! SKView
        scene = GameScene(size: skView.bounds.size)
        scene.backgroundColor = UIColor.darkGrayColor()
        
        skView.addGestureRecognizer(tapRec)
        skView.presentScene(scene)
    }
    
    func pressed(sender: UIButton!) {
        let word = sender.subviews[0] as! UILabel
        scene.addTile([word.text!])
    }
    
    func showTag(sender: UIBarButtonItem!) {
        let subViews: Array = scrollView.subviews
        for subview in subViews
        {
            subview.removeFromSuperview()
        }
        let tag = sender.title
       // populateSelectorByTag(tag!)
    }

    override func shouldAutorotate() -> Bool {
        return true
    }

    override func supportedInterfaceOrientations() -> Int {
        if UIDevice.currentDevice().userInterfaceIdiom == .Phone {
            return Int(UIInterfaceOrientationMask.AllButUpsideDown.rawValue)
        } else {
            return Int(UIInterfaceOrientationMask.All.rawValue)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }
    
}
