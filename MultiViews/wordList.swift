//
//  WordList.swift
//  FlashCardTrial
//
//  Created by Kristin Lamberty on 7/10/14.
//  Copyright (c) 2014 Kristin Lamberty. All rights reserved.
//

import SpriteKit

class WordList {
    //This is a comment we're testing
    var words: [String]!
    var contextIDs: Array<JSON>!
    var looseTilesIDs: Array<JSON>!
    var category: Dictionary<String, String>!
    var tiles: Dictionary<String, Dictionary<String, AnyObject>>!
    var categories: Dictionary<String, Array<JSON>>!
    var wordsWithCategories: [[String]]!
    
    init(filename: String) {
        if let dictionary = Dictionary<String, AnyObject>.loadJSONFromBundle(filename) {
            if let wordsArray: AnyObject = dictionary["words"] {
                words = wordsArray as! [String]
            }
        }
    }
    
    init(urlStudents: String){
        let nsurl = NSURL(string: urlStudents)
        var error: NSError?
        
        let studentData: NSData = NSData(contentsOfURL: nsurl!)!
        //println("The stduent data is: \(studentData)")
        
        if let studentDictionary: AnyObject = NSJSONSerialization.JSONObjectWithData(studentData,
            options: NSJSONReadingOptions(), error: &error){
                let jsonStudent = JSON(studentDictionary)
                //println("Some student stuff is: \(jsonStudent)")
                var stucount = jsonStudent.count;
                println("There are \(stucount) students available in this collection")
                
                for index in 0...stucount-1 {
                    let StudentID = jsonStudent[index]["_id"].string
                    if StudentID == "5511ab56117e23f0412fd08f" {
                        contextIDs = jsonStudent[index]["contextTags"].arrayValue
                        //println("The categoryID array: \(categoriesID)")
                        looseTilesIDs = jsonStudent[index]["tileBucket"].arrayValue
                        //println("The tileBucket array: \(looseTilesID)")
                    }
                }
          } else {
                println("The file at '\(urlStudents)' is not valid JSON, error: \(error!)")
        }
    }

    init(urlCategories: String){
        let nsurl = NSURL(string: urlCategories)
        var error: NSError?
        
        let categoryData: NSData = NSData(contentsOfURL: nsurl!)!
        
        if let categoryDictionary: AnyObject = NSJSONSerialization.JSONObjectWithData(categoryData,
            options: NSJSONReadingOptions(), error: &error){
                let jsonCategory = JSON(categoryDictionary)
                //println("Some category stuff is: \(jsonCategory)")
                var catcount = jsonCategory.count;
                println("There are \(catcount) categories available in this collection")

                var categoryHolder = Dictionary<String, String>();
                for index in 0...catcount-1 {
                    let categoryID = jsonCategory[index]["_id"].string
                    //println("The categoryID: \(categoryID)")
                    let categoryName = jsonCategory[index]["name"].string
                    //println("The categoryName: \(categoryName)")
                    categoryHolder[categoryID!] = categoryName
                }
                //println("The categoryHolder: \(categoryHolder)")
                category = categoryHolder
        } else {
            //and our 4th json file is not valid json,
            //so this is a nice way to test that this error will be triggered in such a case
            println("The file at '\(urlCategories)' is not valid JSON, error: \(error!)")
        }
    }
    
    init(urlTiles: String){
        let nsurl = NSURL(string: urlTiles)
        var error: NSError?
        
        let tileData: NSData = NSData(contentsOfURL: nsurl!)!
        
        if let tileDictionary: AnyObject = NSJSONSerialization.JSONObjectWithData(tileData,
            options: NSJSONReadingOptions(), error: &error){
                let jsonTile = JSON(tileDictionary)
                //println("Some tile stuff is: \(jsonTile)")
                var tilecount = jsonTile.count;
                println("There are \(tilecount) tiles available in this collection")
                
                var tileHolder = Dictionary<String, Dictionary<String, AnyObject>>();
                var detailsHolder = Dictionary<String, AnyObject>();
                var categoriesHolder = Dictionary<String, Array<JSON>>();
                for index in 0...tilecount-1 {
                    var tileID = jsonTile[index]["_id"].string
                    var tileName = jsonTile[index]["name"].string
                    var tileType = jsonTile[index]["wordType"].string
                    var tileCategories = jsonTile[index]["contextTags"].arrayValue
                    detailsHolder["name"] = tileName
                    detailsHolder["type"] = tileType
                    
                    tileHolder[tileID!] = detailsHolder
                    categoriesHolder[tileID!] = tileCategories
                }
                println("The tileHolder: \(tileHolder)")
                println("")
                println("The categoriesHolder: \(categoriesHolder)")
                tiles = tileHolder
                categories = categoriesHolder
        } else {
            //and our 4th json file is not valid json,
            //so this is a nice way to test that this error will be triggered in such a case
            println("The file at '\(urlTiles)' is not valid JSON, error: \(error!)")
        }
    }
    
    init(url: String){
        let nsurl = NSURL(string: url)
        var error: NSError?
        
        //the data seems to be not valid json
        let data: NSData = NSData(contentsOfURL: nsurl!)!
        //println("The data is: \(data)")
        
        //but, we can make JSON out of the stuff that is returned when we ask for JSONSerialization on that data
        if let dictionary: AnyObject = NSJSONSerialization.JSONObjectWithData(data,
            options: NSJSONReadingOptions(), error: &error){
                let somestuff = JSON(dictionary)
                //println("Some stuff is: \(somestuff)")
                var someWords = [String]();
                var thecount = somestuff.count;
                for index in 0...thecount-1 {
                    if let name = somestuff[index]["name"].string {
                        someWords.append(name)
                        //println("The WORDS: \(name)")
                    }
                }
                //println("There are \(thecount) tiles available in this collection")
                words = someWords
                
        } else {
            //and our 4th json file is not valid json, 
            //so this is a nice way to test that this error will be triggered in such a case
            println("The file at '\(url)' is not valid JSON, error: \(error!)")
        }
    }
    
    init(arr: [[String]]!) {
        wordsWithCategories = arr
    }
    
}