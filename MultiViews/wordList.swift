//
//  WordList.swift
//  FlashCardTrial
//
//  Created by Kristin Lamberty on 7/10/14.
//  Copyright (c) 2014 Kristin Lamberty. All rights reserved.
//

import SpriteKit

public class WordList {
    //This is a comment we're testing
    var words: [String]!
    var contextIDs: [String]!
    var looseTilesIDs: [String]!
    var category = [String: String]()
    var tiles = [String: [String]]()
    var categories = [String: [String]]()
    var wordsWithCategories: [[String]]!
    
    init(filename: String) {
        if let dictionary = Dictionary<String, AnyObject>.loadJSONFromBundle(filename) {
            if let wordsArray: AnyObject = dictionary["words"] {
                words = wordsArray as! [String]
            }
        }
    }

    //Helper functions for initializers
    func getStringArrayFromJSON(json: JSON, toGet: String) -> [String]{
        var toReturn = [String]()
        var thecount = json.count
        for index in 0...thecount-1 {
            if let name = json[index][toGet].string {
                toReturn.append(name)
            }
        }
        return toReturn
    }

    
    func getStringStringDictionaryFromJSON(json: JSON, key: String, value: String) -> [String: String]{
        var toReturn = [String: String]()
        var thecount = json.count
        for index in 0...thecount-1 {
            if let wantKey = json[index][key].string {
                if let wantValue = json[index][value].string {
                    toReturn[wantKey] = wantValue
                }
            }
        }
        return toReturn
    }
    
    func getStringArrayDictionaryFromJSON(json: JSON, id: String, arrayname: String) -> [String: [String]]{
        var toReturn = [String: [String]]()
        var thecount = json.count
        for index in 0...thecount-1 {
            var tileID = json[index][id].stringValue
            var tileCategories = json[index][arrayname].arrayValue.map { $0.string!}
            toReturn[tileID] = tileCategories
        }
        return toReturn
    }

    
    func getNestedDictionaryFromJSON(json: JSON, id: String, firstItem: String, secondItem: String) -> [String: [String]]{
        var toReturn = [String: [String]]()
        var thecount = json.count
        for index in 0...thecount-1 {
            var toHelp = [String]()
            var tileID = json[index][id].stringValue
            var tileName = json[index][firstItem].stringValue
            var tileType = json[index][secondItem].stringValue
            toHelp.append(tileName)
            toHelp.append(tileType)
            toReturn[tileID] = toHelp
        }
        return toReturn
    }
    
    func getArrayFromStudent(jsonStudent: JSON, id: String, arrToGet: String) -> [String]{
        var toReturn = [String]()
        var stucount = jsonStudent.count;
        
        for index in 0...stucount-1 {
            let StudentID = jsonStudent[index]["_id"].string
            if StudentID == id {
                toReturn = jsonStudent[index][arrToGet].arrayValue.map { $0.string!}
            }
        }
        return toReturn
    }
    
    //initializer for getting student information
    init(urlStudents: String){
        let nsurl = NSURL(string: urlStudents)
        var error: NSError?
        
        let studentData: NSData = NSData(contentsOfURL: nsurl!)!
        
        if let studentDictionary: AnyObject = NSJSONSerialization.JSONObjectWithData(studentData,
            options: NSJSONReadingOptions(), error: &error){
                let jsonStudent = JSON(studentDictionary)
                contextIDs = getArrayFromStudent(jsonStudent, id: "5511ab56117e23f0412fd08f", arrToGet: "contextTags")
                looseTilesIDs = getArrayFromStudent(jsonStudent, id: "5511ab56117e23f0412fd08f", arrToGet: "tileBucket")
        } else {
            println("The file at '\(urlStudents)' is not valid JSON, error: \(error!)")
        }
    }
    
    //initializer for getting all of the category information
    init(urlCategories: String){
        let nsurl = NSURL(string: urlCategories)
        var error: NSError?
        
        let categoryData: NSData = NSData(contentsOfURL: nsurl!)!
        
        if let categoryDictionary: AnyObject = NSJSONSerialization.JSONObjectWithData(categoryData,
            options: NSJSONReadingOptions(), error: &error){
                let jsonCategory = JSON(categoryDictionary)
                category = getStringStringDictionaryFromJSON(jsonCategory, key: "_id", value: "name")
        } else {
            println("The file at '\(urlCategories)' is not valid JSON, error: \(error!)")
        }
    }
    
    //initializer for getting tile information
    init(urlTiles: String){
        let nsurl = NSURL(string: urlTiles)
        var error: NSError?
        
        let tileData: NSData = NSData(contentsOfURL: nsurl!)!
        
        if let tileDictionary: AnyObject = NSJSONSerialization.JSONObjectWithData(tileData,
            options: NSJSONReadingOptions(), error: &error){
                let jsonTile = JSON(tileDictionary)
                tiles = getNestedDictionaryFromJSON(jsonTile, id: "_id", firstItem: "name", secondItem: "wordType")
                categories = getStringArrayDictionaryFromJSON(jsonTile, id: "_id", arrayname: "contextTags")
        } else {
            println("The file at '\(urlTiles)' is not valid JSON, error: \(error!)")
        }
    }
    
    //Gets ALL of the words from word river database
    init(url: String){
        let nsurl = NSURL(string: url)
        var error: NSError?
        
        //the data seems to be not valid json
        let data: NSData = NSData(contentsOfURL: nsurl!)!
        //println("The data is: \(data)")
        
        //but, we can make JSON out of the stuff that is returned when we ask for JSONSerialization on that data
        if let dictionary: AnyObject = NSJSONSerialization.JSONObjectWithData(data,
            options: NSJSONReadingOptions(), error: &error){
                let somestuff:JSON = JSON(dictionary)
                let want:String = "name"
                words = getStringArrayFromJSON(somestuff, toGet: want)
        } else {
            println("The file at '\(url)' is not valid JSON, error: \(error!)")
        }
    }
    
    //Deals with the nested array Default Word List
    init(arr: [[String]]!) {
        wordsWithCategories = arr
    }
}