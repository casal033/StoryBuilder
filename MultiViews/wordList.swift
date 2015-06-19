//
//  WordList.swift
//  FlashCardTrial
//
//  Created by Kristin Lamberty on 7/10/14.
//  Copyright (c) 2014 Kristin Lamberty. All rights reserved.
//

import SpriteKit

public class WordList {
    //Holds all of the categories associated with given student
    var contextIDs: [String]!
    //Holds all of the individually assigned words
    var looseTilesIDs: [String]!
    //Holds all of the category IDs and category name
    var category = [String: String]()
    //Holds all of the word ID's in the system and an array containing the name at [0] and type at [1]
    var tiles = [String: [String]]()
    //Holds all of the word ID's in the system and an array of associated category IDs
    var categories = [String: [String]]()
    //Holds all of the words in the word river database
    var words: [String]!
    //Holds associative array from local array
    var wordsWithCategories: [[String]]!


    //////////* Helper functions for initializers *//////////
    
    //Takes in JSON (swifty) object "json" and parses it for the string "toGet" returns results as an array
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

    //Takes in JSON (swifty) object "json" and parses it for "key" and "value" returns results as a
    //dictionary with string:key string:value
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

    //Takes in JSON (swifty) object "json" and parses it for "id" and a "array" returns results as a
    //dictionary with string:idReturn array:arrReturn
    func getStringArrayDictionaryFromJSON(json: JSON, id: String, array: String) -> [String: [String]]{
        var toReturn = [String: [String]]()
        var thecount = json.count
        for index in 0...thecount-1 {
            var idReturn = json[index][id].stringValue
            var arrReturn = json[index][array].arrayValue.map { $0.string!}
            toReturn[idReturn] = arrReturn
        }
        return toReturn
    }

    //Takes in JSON (swifty) object "json" and parses it for "id", "firstItem", and "secondItem" returns results as a
    //dictionary with string:idReturn array: [itemReturn1, itemReturn2]
    func getNestedDictionaryFromJSON(json: JSON, id: String, firstItem: String, secondItem: String) -> [String: [String]]{
        var toReturn = [String: [String]]()
        var thecount = json.count
        for index in 0...thecount-1 {
            var result = [String]()
            var idReturn = json[index][id].stringValue
            var itemReturn1 = json[index][firstItem].stringValue
            var itemReturn2 = json[index][secondItem].stringValue
            toHelp.append(itemReturn1)
            toHelp.append(itemReturn2)
            toReturn[idReturn] = result
        }
        return toReturn
    }

    //Takes in JSON (swifty) object "json" and parses it for "id", and a "arrToGet" returns results as a string array
    func getArrayFromJSONWithStudentID(json: JSON, id: String, arrToGet: String) -> [String]{
        var toReturn = [String]()
        var thecount = json.count;
        for index in 0...thecount-1 {
            let StudentID = jsonStudent[index]["_id"].string
            if StudentID == id {
                toReturn = jsonStudent[index][arrToGet].arrayValue.map { $0.string!}
            }
        }
        return toReturn
    }
    
    //initializer for getting student information
    /* This will need to be modified for desired student's id once we have a login */
    init(urlStudents: String){
        let nsurl = NSURL(string: urlStudents)
        var error: NSError?
        
        let studentData: NSData = NSData(contentsOfURL: nsurl!)!
        
        if let studentDictionary: AnyObject = NSJSONSerialization.JSONObjectWithData(studentData,
            options: NSJSONReadingOptions(), error: &error){
                let jsonStudent = JSON(studentDictionary)
                contextIDs = getArrayFromJSONWithStudentID(jsonStudent, id: "5511ab56117e23f0412fd08f", arrToGet: "contextTags")
                looseTilesIDs = getArrayFromJSONWithStudentID(jsonStudent, id: "5511ab56117e23f0412fd08f", arrToGet: "tileBucket")
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
    
    
    init(filename: String) {
        if let dictionary = Dictionary<String, AnyObject>.loadJSONFromBundle(filename) {
            if let wordsArray: AnyObject = dictionary["words"] {
                words = wordsArray as! [String]
            }
        }
    }
}