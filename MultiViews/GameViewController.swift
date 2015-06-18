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
    
    var y: CGFloat = 50
    
    func populateSelector(_words: [String]) {
        
        y = 80
        
        var listOfTags: [String] = []
        
        for word in _words
        {
            var wordButton = UIButton()
            var wordLabel = UILabel()
                
            wordLabel.text = word
            wordLabel.font = UIFont(name: "Thonburi", size: 20)
            wordLabel.textAlignment = .Left
            wordLabel.frame = CGRectMake(10, 0, 100, 25)
            
            wordButton.setTitleColor(UIColor.blueColor(), forState: .Normal)
            // 3rd is is width, 4th is height
            wordButton.frame = CGRectMake(10, y, 120, 30)
            wordButton.backgroundColor = UIColor(red: 0.7, green: 0.5, blue: 0.9, alpha: 1.0)
            
            //adjust y position for the next word
            y += 30
            
            wordButton.addTarget(self, action: "pressed:", forControlEvents: .TouchUpInside)
            
            scrollView.addSubview(wordButton)
            wordButton.addSubview(wordLabel)
            
            //Find tags and put them in the toolbar:
            var items = [AnyObject]()
        }
        wordBar.frame.origin.x = 0
    }
    
    
    
    let panRec = UIPanGestureRecognizer()
    let tapRec = UITapGestureRecognizer()
    
    //@IBOutlet weak var Toolbar: UIToolbar!
    var toolbar:UIToolbar!
    @IBOutlet weak var wordSelectionView: UIImageView!
    @IBOutlet weak var scrollView: UIScrollView!
    
    var wordBar: UIImageView = UIImageView(image: UIImage(named: "purpleRectangle"));
    
    @IBAction func allButtonPressed(sender: AnyObject) {
        let subViews: Array = scrollView.subviews
        for subview in subViews
        {
            subview.removeFromSuperview()
        }
        populateSelector(allTiles)
    }
    
    @IBAction func showCategories(sender: AnyObject) {
        var holder:[String: [String]] = getStudentWords()
        var categoryName = sender.title
        let subViews: Array = scrollView.subviews
        for subview in subViews
        {
            subview.removeFromSuperview()
        }
        populateSelector(getArrayToDisplay(categoryName, dict: holder))
    }
    
    
    func getArrayToDisplay(category: String?!, dict: [String:[String]]) -> [String] {
        var toReturn = [String]()
        for (key, value) in dict {
            if key == category {
                toReturn = value
            }
        }
        return toReturn
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
    
    var allTiles = [String]()
    //_categoriesIDs has an array of the student's contextpacksIDs they're assigned
    var _categoriesIDs = [String]()
    //_looseTilesIDs has an array of the student's individually assigned words
    var _looseTilesIDs = [String]()
    //_category has a dictionary with all of the <contextIDs, contextTitle> in the word river system
    var _category = [String: String]()
    //_tiles has a dictionary with all of the contextIDs and a nested dictionary <wordIDs, <name:wordName, type:wordType> in the word river system
    var _tiles = [String: [String]]()
    //_categories has a dictionary with all of the <wordIDs, array of contextIDs their related to> in the word river system
    var _categories = [String: [String]]()
    var _categoryDictionary = [String: [String]]()
    var categoryNames = [String]()
    
    func getStudentInfo() {
        //_categoriesIDs has an array of the student's contextpacksIDs they're assigned
        _categoriesIDs = WordList(urlStudents: "https://teacherwordriver.herokuapp.com/api/students").contextIDs
        //_looseTilesIDs has an array of the student's individually assigned words
        _looseTilesIDs = WordList(urlStudents: "https://teacherwordriver.herokuapp.com/api/students").looseTilesIDs
        //_category has a dictionary with all of the <contextIDs, contextTitle> in the word river system
        _category = WordList(urlCategories: "https://teacherwordriver.herokuapp.com/api/categories").category
        //_tiles has a dictionary with all of the contextIDs and a nested dictionary <wordIDs, <name:wordName, type:wordType> in the word river system
        _tiles = WordList(urlTiles: "https://teacherwordriver.herokuapp.com/api/tile").tiles
        //_categories has a dictionary with all of the <wordIDs, array of contextIDs their related to> in the word river system
        _categories = WordList(urlTiles: "https://teacherwordriver.herokuapp.com/api/tile").categories
    }
    
    func getStudentWords() -> [String: [String]] {
        var categoryDictionary = [String: [String]]()
        var valueHolder = String()
        
        //Loop through array of known assigned categories
        let counter = _categoriesIDs.count
        for i in 0...counter-1 {
            //catID is the current category ID
            let catID = _categoriesIDs[i]
            //valueHolder is the name of the current category
            let valueHolder:String? = _category[catID]
            var arrHolder:[String] = parseDictionaryForArray(_tiles, catDict: _categories, id: catID)
            categoryDictionary[valueHolder!] = arrHolder
        }
        parseDictionaryForLooseTiles(_tiles, looseTiles: _looseTilesIDs)
        return categoryDictionary
    }
    
    func getCategoryNames(dict: [String: [String]]) -> [String]{
        var toReturn = [String]()
        for (key, value) in dict {
            toReturn.append(key)
        }
        return toReturn
    }
    
    func parseDictionaryForLooseTiles(tiles: [String: [String]], looseTiles: [String]) {
        let thecount = tiles.count
        for (key, value) in tiles {
            let holder = value
            let tileName:String = holder[0]
            let tilecount = looseTiles.count
            for index in 0...tilecount-1 {
                let looseID = looseTiles[index]
                if key == looseID {
                    addWordToAllTiles(tileName)
                }
            }
        }
    }
    
    func parseDictionaryForArray(dictionary: [String: [String]], catDict: [String: [String]], id: String!) -> [String]{
        var toReturn = [String]()
        for (key, value) in dictionary {
            let tileName:String = value[0]
            for (key2, value2) in catDict {
                if key == key2 {
                    let arrSize = value2.count
                    var counter = 0
                    for index in 0...arrSize-1 {
                        var catIDHold = value2[counter]
                        counter++
                        if catIDHold == id {
                            toReturn.append(tileName)
                            addWordToAllTiles(tileName)
                        }
                    }
                }
            }
        }
        return toReturn
    }
    
    func addWordToAllTiles(toCheck: String) {
        if contains(allTiles, toCheck) == false {
            allTiles.append(toCheck)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Generate helpful objects of related student information
        getStudentInfo()
        
        //Dictionary of categories and associated arrays
        _categoryDictionary = getStudentWords()
        
        
        /////////* Section for Toolbar */////////

        //Array of category names assigned to student
        categoryNames = getCategoryNames(_categoryDictionary)
        
        /*Array of buttons to add to toolbar
        Currently includes "All" and each category the student is assigned */
        var items = [AnyObject]()
        items = [UIBarButtonItem(title: "All", style: UIBarButtonItemStyle.Plain, target: self, action: "allButtonPressed:")]
        for index in 0...categoryNames.count-1 {
            items.append(UIBarButtonItem(title: categoryNames[index], style: UIBarButtonItemStyle.Plain, target: self, action: "showCategories:"))
        }
        
        //Making a toolbar programatically
        toolbar = UIToolbar()
        //Add buttons to toolbar
        toolbar.items = items
        //Add toolbat to view
        self.view.addSubview(toolbar)
        
        /////////* Section for Scroll View */////////
        
        /* Populate the scroll bar with all of the words related to the student
        (Their assigned category words and inidviudally assigned words) */
        populateSelector(allTiles)
        
        scrollView.addSubview(wordSelectionView)
        
        //Parameters for content in scroll frame
        scrollView.contentSize = CGSize(width: wordBar.frame.size.width , height: CGFloat(count(allTiles) * 30))
        
        //scrollView.frame = CGRectMake(xOrigin,yOrigin,width,height);
        //1024-by-768
        let scrollViewFrame = CGRectMake(0, 64, 200, 768)
        //let scrollViewFrame = scrollView.frame
        let scaleWidth = scrollViewFrame.size.width / scrollView.contentSize.width
        let scaleHeight = scrollViewFrame.size.height / scrollView.contentSize.height
        let minScale = min(scaleWidth, scaleHeight);
        scrollView.minimumZoomScale = minScale;
        
        scrollView.maximumZoomScale = 1.0
        scrollView.zoomScale = minScale;
        
        tapRec.addTarget(self, action: "tappedView")
        panRec.addTarget(self, action: "draggedView")
        
        
        let skView = self.view as! SKView
        scene = GameScene(size: skView.bounds.size)
        scene.backgroundColor = UIColor.darkGrayColor()
        
        skView.addGestureRecognizer(tapRec)
        skView.presentScene(scene)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        //Set toolbar bounds "size"
        toolbar.frame = CGRectMake(0, 20, view.bounds.width, 44)
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
