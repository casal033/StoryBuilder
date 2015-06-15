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
    var contexIDs: [String]!
    var looseTilesIDs: [String]!
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
        println("The stduent data is: \(studentData)")
        
        if let studentDictionary: AnyObject = NSJSONSerialization.JSONObjectWithData(studentData,
            options: NSJSONReadingOptions(), error: &error){
                let jsonStudent = JSON(studentDictionary)
                //println("Some student stuff is: \(jsonStudent)")
                var stucount = jsonStudent.count;
                println("There are \(stucount) students available in this collection")
                let StudentID = jsonStudent[0]["_id"].string
                for index in 0...stucount-1 {
                    if StudentID == "5511ab56117e23f0412fd08f" {
                        let categoriesID = jsonStudent[index]["contexTags"].array
                        println("The categoryID array: \(categoriesID)")
                        let looseTilesID = jsonStudent[index]["tileBucket"].array
                        println("The tileBucket array: \(looseTilesID)")
                    }
                }
                contexIDs = categoriesID
                //looseTilesIDs = looseTilesID
        } else {
            //and our 4th json file is not valid json,
            //so this is a nice way to test that this error will be triggered in such a case
            println("The file at '\(urlStudents)' is not valid JSON, error: \(error!)")
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
                        //println("The less safe way: \(name)")
                    }
                }
                //println("There are \(thecount) tiles available in this collection")
                words = someWords
                
        } else {
            //and our 4th json file is not valid json, 
            //so this is a nice way to test that this error will be triggered in such a case
            //println("The file at '\(url)' is not valid JSON, error: \(error!)")
        }
    }
    
    init(arr: [[String]]!) {
        wordsWithCategories = arr
    }
    
}