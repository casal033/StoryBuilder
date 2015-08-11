//
//  GameViewController.swift
//  MultiViews
//
//  Created by Administrator on 7/15/14.
//  Copyright (c) 2014 Administrator. All rights reserved.
//

import UIKit
import SpriteKit
import Foundation

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
    let panRec = UIPanGestureRecognizer()
    let tapRec = UITapGestureRecognizer()
    
    var toolbar:UIToolbar!
    var toolbarAlpha:UIToolbar!
    var scrollView: UIScrollView!
    var wordSelectionView: UIImageView! = UIImageView(image: UIImage(named: "purpleRectangle"));
    //allWords contains all of the words related to the current student
    var allWords = [String]()
    //Max word length in allWords used to set Scrol Width
    var maxWordLength = Int()
    //Max word length in allWords used to set tile width
    var maxWordLengthWord = Int()
    //_wordPackIDs has an array of the student's contextpacksIDs they're assigned
    var studentWordPackIDs = [String]()
    //_looseWordsIDs has an array of the student's individually assigned words
    var studentWordIDs = [String]()
    //_looseWordsIDs has an array of the student's individually assigned words
    var studentWordPackWordIDs = [String]()
    //_wordPacks has a dictionary with all of the <contextIDs, contextTitle> in the word river system
    var studentWordPacks = [String: [String]]()
    var studentContextPacks = [String: [String]]()
    //_words has a dictionary with all of the contextIDs and a nested dictionary <wordIDs, <name:wordName, type:wordType> in the word river system
    var studentWords = [String: [String]]()
    var contextPackNames = [String]()
    var _alphaDictionary = [String: [String]]()
    let alpha = ["a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z"]

    override func viewDidLoad() {
        super.viewDidLoad()
        //Generate helpful objects of related student information
        getStudentInfo()
        
        //Dictionary of categories and associated arrays
        getStudentWords()
        
        setWidth(maxWordLength)
        setWordWidth(maxWordLengthWord)

        /////////* Section for Scroll View */////////
        
        /* Populate the scroll bar with all of the words related to the student (Their assigned category words and inidviudally assigned words) */
        populateSelector(sortArray(allWords))
        
        //Add word view to scroll
        scrollView.addSubview(wordSelectionView)
        
        let scrollViewFrame = scrollView.frame
        
        //Scale/Zoom information
        let scaleWidth = scrollViewFrame.size.width / scrollView.contentSize.width
        let scaleHeight = scrollViewFrame.size.height / scrollView.contentSize.height
        let minScale = min(scaleWidth, scaleHeight);
        scrollView.minimumZoomScale = minScale;
        
        scrollView.maximumZoomScale = 1.0
        scrollView.zoomScale = minScale;
        

        /////////* Section for Toolbar */////////
        
        //Array of category names assigned to student
        contextPackNames = getWordPackNames(studentContextPacks)
        var sorted:[String] = sortArray(contextPackNames)

        /*Array of buttons to add to toolbar
        Currently includes "All" and each category the student is assigned */
        var items = [AnyObject]()
        items.append(UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Refresh, target: self, action:"refreshWords:"))
        items.append (UIBarButtonItem(title: "All", style: UIBarButtonItemStyle.Plain, target: self, action: "allButtonPressed:"))
        for index in 0...sorted.count-1 {
            items.append(UIBarButtonItem(title: sorted[index], style: UIBarButtonItemStyle.Plain, target: self, action: "showCategories:"))
        }
        
        //Making a toolbar programatically
        toolbar = UIToolbar()
        //Add buttons to toolbar
        toolbar.items = items
        //Add toolbat to view
        view.addSubview(toolbar)

        
        /////////* Section for Toolbar 2 */////////
        
        /* Array of buttons to add to toolbar */
        var letters = [AnyObject]()
        var alphaSorted = sortArray(alpha)
        for position in 0...alphaSorted.count-1 {
            letters.append(UIBarButtonItem(title: alphaSorted[position], style: UIBarButtonItemStyle.Plain, target: self, action: "showAlphaWords:"))
        }
        
        //Making a toolbar programatically
        toolbarAlpha = UIToolbar()
        //Add buttons to toolbar
        toolbarAlpha.items = letters
        //Add toolbat to view
        view.addSubview(toolbarAlpha)
        
        
        //////////Testing buttons
        let button = UIButton.buttonWithType(UIButtonType.System) as! UIButton
        button.frame = CGRectMake(CGFloat(view.bounds.width - 115), 20, 110, 80)
        button.backgroundColor = UIColor.redColor()
        button.setTitle("Clear Tiles", forState: UIControlState.Normal)
        button.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
        button.titleLabel!.font = UIFont(name: "Thonburi", size: 18)
        button.addTarget(self, action: "ResetButtonPressed:", forControlEvents: UIControlEvents.TouchUpInside)
        
        self.view.addSubview(button)
        
        tapRec.addTarget(self, action: "tappedView")
        panRec.addTarget(self, action: "draggedView")
        
        
        let skView = self.view as! SKView
        scene = GameScene(size: skView.bounds.size)
        scene.backgroundColor = UIColor.darkGrayColor()
        
        skView.addGestureRecognizer(tapRec)
        skView.presentScene(scene)
    }
    
    var setScrollWidth = CGFloat()
    var setScrollWidthText = CGFloat()
    var setScrollWidthButton = CGFloat()
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        //Set scrollView bounds "size"
        //If scroll width is breaking use 150
        scrollView.frame = CGRectMake(0, 105, setScrollWidth, view.bounds.height-115)
        
        //Set toolbar bounds "size"
        toolbar.frame = CGRectMake(10, 20, CGFloat(view.bounds.width-130), 40)
        
        //Set toolbar bounds "size"
        toolbarAlpha.frame = CGRectMake(10, 60, CGFloat(view.bounds.width-130), 40)
    }
    
    //Brings scroll to start of words when each category is selected
    func toBegining(scrollView: UIScrollView) {
        scrollView.setContentOffset(CGPointMake(0, 0), animated: true)
    }
    
    //Get names of categories from a dictionary where [name: array] to make buttons for toolbar
    func getWordPackNames(dict: [String: [String]]) -> [String]{
        var toReturn = [String]()
        for (key, value) in dict {
            toReturn.append(key)
        }
        return toReturn
    }
    
    var y: CGFloat = 50
    
    func populateSelector(_words: [String]) {
        //Allows scroll to move when needed, and stay still when list of words is short
        self.scrollView = UIScrollView()
        self.scrollView.contentSize = CGSizeMake(wordSelectionView.frame.size.width, CGFloat(count(_words) * 30))
        view.addSubview(scrollView)
        
        //Brings scroll to start of words when each category is selected
        toBegining(scrollView)
       
        //Formatting words to be displayed in scroll
        y = 0
        for word in _words {
            var wordButton = UIButton()
            var wordLabel = UILabel()
                
            wordLabel.text = word
            wordLabel.font = UIFont(name: "Thonburi", size: 20)
            wordLabel.textAlignment = .Left
            wordLabel.frame = CGRectMake(10, 0, setScrollWidthText, 25)
            //If scroll width is breaking use 100
            wordButton.setTitleColor(UIColor.blueColor(), forState: .Normal)
            // 3rd is is width, 4th is height
            //If scroll width is breaking use 120
            wordButton.frame = CGRectMake(10, y, setScrollWidthButton, 30)
            wordButton.backgroundColor = UIColor(red: 0.7, green: 0.5, blue: 0.9, alpha: 1.0)
            
            //adjust y position for the next word
            y += 30
            
            wordButton.addTarget(self, action: "pressed:", forControlEvents: .TouchUpInside)
            
            scrollView.addSubview(wordButton)
            wordButton.addSubview(wordLabel)
        }
    }
    
    //Function adds words from populateSelector() into the game scene as a tile
    func pressed(sender: UIButton!) {
        let word = sender.subviews[0] as! UILabel
        scene.addTile([word.text!, getWordType(word.text!)])
    }
    
    //Function to grab word type so the word can be made into a tile
    func getWordType(word: String) -> String {
        var toReturn = String()
        for (key, value) in studentWords {
            let tileName:String = value[0]
            let tileType:String = value[1]
            if tileName == word {
                toReturn = tileType
            }
        }
        return toReturn
    }
    
    //Function filters to show all words assigned to the child
    func allButtonPressed(sender: AnyObject) {
        let subViews: Array = scrollView.subviews
        for subview in subViews
        {
            subview.removeFromSuperview()
        }
        populateSelector(sortArray(allWords))
    }
    
    //Function filters to show category-specific words assigned to the child
    func showCategories(sender: AnyObject) {
        var holder:[String: [String]] = studentContextPacks
        var categoryName = sender.title
        let subViews: Array = scrollView.subviews
        for subview in subViews
        {
            subview.removeFromSuperview()
        }
        populateSelector(sortArray(getArrayToDisplay(categoryName, dict: holder)))
    }
    
    //Function filters to show alpha-specific words assigned to the child
    func showAlphaWords(sender: AnyObject) {
        var holder:[String: [String]] = _alphaDictionary
        var letterName = sender.title
        let subViews: Array = scrollView.subviews
        for subview in subViews
        {
            subview.removeFromSuperview()
        }
        populateSelector(sortArray(getArrayToDisplay(letterName, dict: holder)))
    }
    
    
    //Function refreshes our current words whenever the button is pressed in scene
    //So a teacher can add a word, and a child can refresh and get it right away
    func refreshWords(sender: AnyObject){
        allWords = []
        maxWordLength = Int()
        maxWordLengthWord = Int()
        setScrollWidth = CGFloat()

        let subViews: Array = scrollView.subviews
        for subview in subViews
        {
            subview.removeFromSuperview()
        }
        println("setScrollWidth \(setScrollWidth)")
        viewDidLoad()
        viewDidLayoutSubviews()
        println("setScrollWidth \(setScrollWidth)")
    }

    //Sets the appropriate scroll width based on lengths of given words
    func setWidth(int:Int) {
        var hold = Int()
        if int > 18 {
            hold = 18
        } else {
            hold = int
        }
        for index in 0...hold {
            setScrollWidth += 12
        }
        //println(setScrollWidth)
    }

    //Sets the appropriate word width based on lengths of given words
    func setWordWidth(int:Int) {
        var hold = Int()
        //println("Count check tile: \(int > 18)")
        if int > 18 {
            hold = 18
        } else {
            hold = int
        }
        for index in 0...hold {
            setScrollWidthText += 10
            setScrollWidthButton += 11
        }
        //println(setScrollWidthButton)
    }
    
    //Parses dictionaries to get associated arrays with given names for alpha & categories currently
    func getArrayToDisplay(category: String?!, dict: [String:[String]]) -> [String] {
        var toReturn = [String]()
        for (key, value) in dict {
            if key == category {
                toReturn = value
            }
        }
        return toReturn
    }
    
    //Alpha sorting function for arrays
    func sortArray(toSort: [String]) -> [String]{
        return toSort.sorted { $0.localizedCaseInsensitiveCompare($1) == NSComparisonResult.OrderedAscending }
    }
    
    //Get all related information about student (words & categories their assigned)
    func getStudentInfo() {
        //_looseWordPackIDs has an array of the student's contextpacksIDs they're assigned
        studentWordPackIDs = WordList(urlStudents: "https://teacherwordriver.herokuapp.com/api/students").looseStudentWordPackIDs
        //_looseWordsIDs has an array of the student's individually assigned words
        studentWordIDs = WordList(urlStudents: "https://teacherwordriver.herokuapp.com/api/students").looseStudentWordIDs
        //_wordPack has a dictionary with all of the <contextIDs, contextTitle> in the word river system
        studentWordPacks = WordList(urlWordPacks: "https://teacherwordriver.herokuapp.com/api/wordPacks", wpIDs: studentWordPackIDs).wordPack
        studentWordPackWordIDs = WordList(urlWordPacks: "https://teacherwordriver.herokuapp.com/api/wordPacks", wpIDs: studentWordPackIDs).wordIDs
        //_words has a dictionary with all of the contextIDs and a nested dictionary <wordIDs, <name:wordName, type:wordType> in the word river system
        studentWords = WordList(urlWords: "https://teacherwordriver.herokuapp.com/api/words", wdIDs: studentWordPackWordIDs).words
        for index in 0...studentWordIDs.count-1{
            if(!(contains(studentWordPackWordIDs, studentWordIDs[index]))){
                studentWordPackWordIDs.append(studentWordIDs[index])
            }
        }
        createAlphaDictionary()
        for (id, arr) in studentWords {
            if(contains(studentWordPackWordIDs, id)){
                allWords.append(arr[0])
                var wordLength = count(arr[0])
                checkMaxWord(wordLength)
                addToAlphaDictionary(arr[0])
            }
        }
        studentContextPacks = WordList(urlContextPacks: "https://teacherwordriver.herokuapp.com/api/contextPacks", wpIDs: studentWordPackIDs).contextPack
        println("Got api info!")
    }
    
    
    //Helper to initialize the alphaDictionary with empty arrays
    func createAlphaDictionary(){
        for i in 0...alpha.count-1 {
            _alphaDictionary[alpha[i]] = []
        }
    }
    
    //Parse all word information from getStudentInfo into usable objects
    func getStudentWords() {
        //Loop through array of known assigned context packs
        var wpsInCPs = [String]()
        for (contextName, wordPackIDs) in studentContextPacks {
            var wordIDs = [String]()
            for index in 0...wordPackIDs.count-1 {
                for (wpID, wpWordIDs) in studentWordPacks {
                    if(wordPackIDs[index] == wpID){
                        if (!(contains(wpsInCPs, wpID))){
                            wpsInCPs.append(wpID)
                        }
                        var wpWords = wpWordIDs
                        for index2 in 1...wpWordIDs.count-1{
                            if (!(contains(wordIDs, wpWordIDs[index2]))) {
                                wordIDs.append(wpWordIDs[index2])
                            }
                        }
                    }
                }
            }
            studentContextPacks[contextName] = wordIDs
        }

        for (wpIDnonContext, wpWordIDnonContext) in studentWordPacks {
            var nonContextWordIDs = [String]()
            if(!(contains(wpsInCPs, wpIDnonContext))){
                var wpWordsNonContext = [String]()
                wpWordsNonContext = wpWordIDnonContext
                for index3 in 1...wpWordIDnonContext.count-1{
                    if (!(contains(nonContextWordIDs, wpWordIDnonContext[index3]))) {
                        nonContextWordIDs.append(wpWordIDnonContext[index3])
                    }
                }
                studentContextPacks[wpWordIDnonContext[0]] = nonContextWordIDs
            }
        }
        
        for (wordID, wordArr) in studentWords {
            for (contName, contWordIDs) in studentContextPacks {
                for i in 0...contWordIDs.count-1 {
                    if (wordID == contWordIDs[i]) {
                        var wordsHold = contWordIDs
                        wordsHold[i] = wordArr[0]
                        studentContextPacks[contName] = wordsHold
                    }
                }
            }
        }
    }

    //Helper for setting scroll width based on the maxword length
    func checkMaxWord(int: Int) {
        if int > maxWordLength {
            maxWordLength = int
            maxWordLengthWord = maxWordLength
        }
    }
    
    //Helper to organize all assigned words, with no doubles into alphabet filters
    func addToAlphaDictionary(word: String) {
        let currentWord = word.lowercaseString
        let index = advance(currentWord.startIndex, 0)
        var letterToGet = currentWord[index]
        var currentLetter = String()
        currentLetter = String(letterToGet)
        var holderArr = [String]()
        //key is the letter, value is the array of associated words
        for (key, value) in _alphaDictionary {
            if key == currentLetter {
                holderArr = value
                holderArr.append(word)
                holderArr = sortArray(holderArr)
                _alphaDictionary[key] = holderArr
            }
        }
    }
    
    
    var skView: SKView!
    var scene: GameScene!
    
    @IBOutlet var Word1: UITextField?
    
    //Resets all tiles in playing field
    func ResetButtonPressed(sender: AnyObject) {
        scene.resetTiles()
    }
    
    @IBAction func NextButtonPressed(sender: AnyObject) {
        scene.addTileFromWordList()
    }
    
    func tappedView() {
        
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
