//
//  WordList.swift
//  FlashCardTrial
//
//  Created by Kristin Lamberty on 7/10/14.
//  Copyright (c) 2014 Kristin Lamberty. All rights reserved.
//

import SpriteKit

class WordList {
    
    var words: [String]!
    var wordsWithCategories: [[String]]!
    init(filename: String) {
        if let dictionary = Dictionary<String, AnyObject>.loadJSONFromBundle(filename) {
            if let wordsArray: AnyObject = dictionary["words"] {
                words = wordsArray as! [String]
            }
        }
    }
    
    init(url: String){
        let nsurl = NSURL(string: url)
        var error: NSError?
        
        //the data seems to be not valid json
        let data: NSData = NSData(contentsOfURL: nsurl!)!
        println("The data is: \(data)")
        
        //but, we can make JSON out of the stuff that is returned when we ask for JSONSerialization on that data
        if let dictionary: AnyObject = NSJSONSerialization.JSONObjectWithData(data,
            options: NSJSONReadingOptions(), error: &error){
                let somestuff = JSON(dictionary)
                println("Some stuff is: \(somestuff)")
                if let name = somestuff[0]["name"].string {
                    println("The safer way: \(name)")
                }
        } else {
            //and our 4th json file is not valid json, 
            //so this is a nice way to test that this error will be triggered in such a case
            println("The file at '\(url)' is not valid JSON, error: \(error!)")
        }
        
        //or, we can try it this way, which seems less safe, but i'm not sure
        let thestuff = JSON(data: NSData(contentsOfURL: nsurl!)!)
        println("The stuff is: \(thestuff)")
        
        if let name = thestuff[0]["name"].string {
            println("The less safe way: \(name)")
        }
        
        var someWords = [String]();
        var thecount = thestuff.count;
        for index in 0...thecount-1 {
            if let name = thestuff[index]["name"].string {
                someWords.append(name)
                println("The less safe way: \(name)")
            }
        }
        
        println("There are \(thecount) tiles available in this collection")
        
        words = someWords
    }
    
    init(arr: [[String]]!) {
        wordsWithCategories = arr
    }
    
}