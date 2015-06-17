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
    //var category: Dictionary<String, String>!
    var category = [String: String]()
    //var tiles: Dictionary<String, Dictionary<String, String>>!
    var tiles = [String: [String: String]]()
    //var categories: Dictionary<String, [String]>!
    var categories = [String: [String]]()
    var wordsWithCategories: [[String]]!
    
    init(filename: String) {
        if let dictionary = Dictionary<String, AnyObject>.loadJSONFromBundle(filename) {
            if let wordsArray: AnyObject = dictionary["words"] {
                words = wordsArray as! [String]
            }
        }
    }

    
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

    
    func getNestedDictionaryFromJSON(json: JSON, id: String, firstItem: String, secondItem: String) -> [String: [String: String]]{
        var toReturn = [String: [String: String]]()
        var toHelp = [String: String]()
        var thecount = json.count
        for index in 0...thecount-1 {
            var tileID = json[index][id].stringValue
            var tileName = json[index][firstItem].string
            var tileType = json[index][secondItem].stringValue
                
            toHelp["name"] = tileName
            toHelp["type"] = tileType
            
            toReturn[tileID] = toHelp
        }
        return toReturn
    }
    
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
    
    init(urlTiles: String){
        let nsurl = NSURL(string: urlTiles)
        var error: NSError?
        
        let tileData: NSData = NSData(contentsOfURL: nsurl!)!
        
        if let tileDictionary: AnyObject = NSJSONSerialization.JSONObjectWithData(tileData,
            options: NSJSONReadingOptions(), error: &error){
                let jsonTile = JSON(tileDictionary)
                tiles = getNestedDictionaryFromJSON(jsonTile, id: "_id", firstItem: "name", secondItem: "type")
                categories = getStringArrayDictionaryFromJSON(jsonTile, id: "_id", arrayname: "contextTags")
        } else {
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
                let somestuff:JSON = JSON(dictionary)
                let want:String = "name"
                words = getStringArrayFromJSON(somestuff, toGet: want)
        } else {
            println("The file at '\(url)' is not valid JSON, error: \(error!)")
        }
    }
    
    init(arr: [[String]]!) {
        wordsWithCategories = arr
    }
    
    public func getStudentContextIDs(studentAPIurl: String) -> [String] {
        let nsurl = NSURL(string: studentAPIurl)
        var error: NSError?
        
        let studentData: NSData = NSData(contentsOfURL: nsurl!)!
        //println("The stduent data is: \(studentData)")
        
        if let studentDictionary: AnyObject = NSJSONSerialization.JSONObjectWithData(studentData,
            options: NSJSONReadingOptions(), error: &error){
                let jsonStudent = JSON(studentDictionary)
                //println("Some student stuff is: \(jsonStudent)")
                var stucount = jsonStudent.count;
                //println("There are \(stucount) students available in this collection")
                
                for index in 0...stucount-1 {
                    let StudentID = jsonStudent[index]["_id"].string
                    if StudentID == "5511ab56117e23f0412fd08f" {
                        contextIDs = jsonStudent[index]["contextTags"].arrayValue.map { $0.string!}
                        return contextIDs
                    }
                }
        } else {
            println("The file at '\(studentAPIurl)' is not valid JSON, error: \(error!)")
        }
        return contextIDs
    }
    
    func getStudentLooseTilesIDs(studentAPIurl: String) -> [String] {
        let nsurl = NSURL(string: studentAPIurl)
        var error: NSError?
        
        let studentData: NSData = NSData(contentsOfURL: nsurl!)!
        //println("The stduent data is: \(studentData)")
        
        if let studentDictionary: AnyObject = NSJSONSerialization.JSONObjectWithData(studentData,
            options: NSJSONReadingOptions(), error: &error){
                let jsonStudent = JSON(studentDictionary)
                //println("Some student stuff is: \(jsonStudent)")
                var stucount = jsonStudent.count;
                //println("There are \(stucount) students available in this collection")
                
                for index in 0...stucount-1 {
                    let StudentID = jsonStudent[index]["_id"].string
                    if StudentID == "5511ab56117e23f0412fd08f" {
                        looseTilesIDs = jsonStudent[index]["tileBucket"].arrayValue.map { $0.string!}
                        //println("The tileBucket array: \(looseTilesIDs)")
                        return looseTilesIDs
                    }
                }
        } else {
            println("The file at '\(studentAPIurl)' is not valid JSON, error: \(error!)")
        }
        return looseTilesIDs
    }
}