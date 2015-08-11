//
//  WordList.swift
//  FlashCardTrial
//
//  Created by Kristin Lamberty on 7/10/14.
//  Copyright (c) 2014 Kristin Lamberty. All rights reserved.
//

import SpriteKit

public class WordList {
    //Holds all of the classes/groups associated with given student
    var classListIDs: [String:[String]]!
    //Holds all of the wordPacks associated with given student
    var looseStudentWordPackIDs: [String]!
    //Holds all of the individually assigned words
    var looseStudentWordIDs: [String]!
    var wordIDs: [String]!
    //Holds all of the wordPack IDs and wordPack name
    var wordPack = [String: [String]]()
    var contextPack = [String: [String]]()
    //Holds all of the word ID's in the system and an array containing the name at [0] and type at [1]
//    var allWords = [String: [String]]()
    //Holds all of the word ID's in the system and an array containing the name at [0] and type at [1]
    var words = [String: [String]]()
    //Holds all of the word ID's in the system and an array of associated wordPack IDs
    var wordPacks = [String: [String]]()
    //Holds associative array from local array
    var wordsWithWordPacks: [[String]]!


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
    
    func getNameAndWordPackIDsFromJSON(json: JSON, wordPackIDs: [String]) -> [String: [String]]{
        var toReturn = [String: [String]]()
        for index in 0...json.count-1 {
            var arrHold = json[index]["wordPacks"].arrayValue.map { $0.string!}
            var idHold = [String]()
            for index2 in 0...arrHold.count-1 {
                if(contains(wordPackIDs, arrHold[index2])){
                    idHold.append(arrHold[index2])
                }
            }
            toReturn[json[index]["name"].string!] = idHold
        }
        return toReturn
    }
    
    //Takes in JSON (swifty) object "json" and parses it for "key" and "value" returns results as a
    //dictionary with string:key string:value
    func getStringStringDictionaryFromJSON(json: JSON, wordPackIDs: [String]) -> [String: [String]]{
        var toReturn = [String: [String]]()
        var thecount = json.count
        for index in 0...thecount-1 {
            for index2 in 0...wordPackIDs.count-1 {
                if(json[index]["_id"].string! == wordPackIDs[index2]){
                    var arrHold = json[index]["words"].arrayValue.map { $0.string!}
                    toReturn[json[index]["name"].string!] = arrHold
                    for index3 in 0...arrHold.count-1{
                        if(!(contains(wordIDs, arrHold[index3]))){
                            wordIDs.append(arrHold[index3])
                        }
                    }
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
    func getNestedDictionaryFromJSON(json: JSON, wordPackIDs: [String]) -> [String: [String]]{
        var toReturn = [String: [String]]()
        var idCheck = [String]()
        var thecount = json.count
        for index in 0...thecount-1 {
            var result = [String]()
            var idReturn = json[index]["_id"].stringValue
            var itemReturn1 = json[index]["name"].stringValue
            var itemReturn2 = json[index]["wordType"].stringValue
            if(!(contains(idCheck, idReturn))){
                result.append(itemReturn1)
                result.append(itemReturn2)
                toReturn[idReturn] = result
            }
        }
        return toReturn
    }

    //Takes in JSON (swifty) object "json" and parses it for "id", and a "arrToGet" returns results as a string array
    func getArrayFromJSONWithStudentID(json: JSON, id: String, arrToGet: String) -> [String]{
        var toReturn = [String]()
        var thecount = json.count;
        for index in 0...thecount-1 {
            let StudentID = json[index]["_id"].string
            if StudentID == id {
                toReturn = json[index][arrToGet].arrayValue.map { $0.string!}
            }
        }
        return toReturn
    }
    
    //Takes in JSON (swifty) object "json" and parses it for "id", and a "arrToGet" returns results as a string array
    func getClassListFromStudent(json: JSON, id: String) -> [String: [String]]{
        var classList = [String: [String]]()
        var thecount = json.count;
        for index in 0...thecount-1 {
            let StudentID = json[index]["_id"].string
            if StudentID == id {
                for index2 in 0...json[index]["classList"].count-1 {
                    classList[json[index]["classList"][index2]["_id"].string!] = getGroupListFromStudent(json[index]["classList"][index2]["groupList"].arrayValue.map { $0.string!})
                }
            }
        }
        return classList
    }
    
    func getGroupListFromStudent(json: [String]) -> [String] {
        var groupList = [String]()
        groupList = json
        return groupList
    }
    
    //initializer for getting teacher information
    /* This will need to be modified for desired teacher's id once we have a login */
    func getClassInfo (urlTeachers: String){
        let nsurl = NSURL(string: urlTeachers)
        var error: NSError?
        let teacherData: NSData = NSData(contentsOfURL: nsurl!)!
        if let teacherDictionary: AnyObject = NSJSONSerialization.JSONObjectWithData(teacherData,
            options: NSJSONReadingOptions(), error: &error){
                let jsonTeacher = JSON(teacherDictionary)
                for index in 0...jsonTeacher.count-1 {
                    if(jsonTeacher[index]["_id"] == "5511a83da168f8b5f3144f02"){
                        for index2 in 0...jsonTeacher[index]["classList"].count-1 {
                            for (str, arr) in classListIDs {
                                var classID: String
                                classID = jsonTeacher[index]["classList"][index2]["_id"].string!
                                for wpindex in 0...jsonTeacher[index]["classList"][index2]["wordPacks"].count-1 {
                                    if(!(contains(looseStudentWordPackIDs, jsonTeacher[index]["classList"][index2]["wordPacks"][wpindex].string!))){
                                        looseStudentWordPackIDs.append(jsonTeacher[index]["classList"][index2]["wordPacks"][wpindex].string!)
                                    }
                                }
                                for wdindex in 0...jsonTeacher[index]["classList"][index2]["words"].count-1 {
                                    if(!(contains(looseStudentWordIDs, jsonTeacher[index]["classList"][index2]["words"][wdindex].string!))){
                                        looseStudentWordIDs.append(jsonTeacher[index]["classList"][index2]["words"][wdindex].string!)
                                    }
                                }
                                if(compareIDs(str, otherID:classID)){
                                    for index3 in 0...jsonTeacher[index]["classList"][index2]["groupList"].count-1{
                                        var groupID: String
                                        groupID = jsonTeacher[index]["classList"][index2]["groupList"][index3]["_id"].string!
                                        for index4 in 0...arr.count-1 {
                                            if(compareIDs(arr[index4], otherID:groupID)){
                                                for wpindex2 in 0...jsonTeacher[index]["classList"][index2]["groupList"][index3]["wordPacks"].count-1 {
                                                    if(!(contains(looseStudentWordPackIDs, jsonTeacher[index]["classList"][index2]["groupList"][index3]["wordPacks"][wpindex2].string!))){
                                                        looseStudentWordPackIDs.append(jsonTeacher[index]["classList"][index2]["groupList"][index3]["wordPacks"][wpindex2].string!)
                                                    }
                                                }
                                                for wdindex2 in 0...jsonTeacher[index]["classList"][index2]["groupList"][index3]["words"].count-1 {
                                                    if(!(contains(looseStudentWordIDs, jsonTeacher[index]["classList"][index2]["groupList"][index3]["words"].string!))){
                                                        looseStudentWordIDs.append(jsonTeacher[index]["classList"][index2]["groupList"][index3]["words"].string!)
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
//                println("WordPacks: '\(looseStudentWordPackIDs)' ")
//                println("Words: '\(looseStudentWordIDs)' ")
        } else {
            println("The file at '\(urlTeachers)' is not valid JSON, error: \(error!)")
        }
    }
    
    func compareIDs(id: String, otherID: String) -> Bool{
        if(id == otherID){
            return true
        } else {
            return false
        }
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
                looseStudentWordPackIDs = getArrayFromJSONWithStudentID(jsonStudent, id: "5511ab56117e23f0412fd08f", arrToGet: "wordPacks")
                looseStudentWordIDs = getArrayFromJSONWithStudentID(jsonStudent, id: "5511ab56117e23f0412fd08f", arrToGet: "words")
                classListIDs = getClassListFromStudent(jsonStudent, id: "5511ab56117e23f0412fd08f")
//                getClassInfo("https://teacherwordriver.herokuapp.com/api/users/")
        } else {
            println("The file at '\(urlStudents)' is not valid JSON, error: \(error!)")
        }
    }

    
    //initializer for getting all of the wordPack information
    init(urlContextPacks: String, wpIDs: [String]){
        let nsurl = NSURL(string: urlContextPacks)
        var error: NSError?
        
        let contextPackData: NSData = NSData(contentsOfURL: nsurl!)!
        
        if let contextPackDictionary: AnyObject = NSJSONSerialization.JSONObjectWithData(contextPackData,
            options: NSJSONReadingOptions(), error: &error){
                let jsonContextPack = JSON(contextPackDictionary)
                contextPack = getNameAndWordPackIDsFromJSON(jsonContextPack, wordPackIDs: wpIDs)
        } else {
            println("The file at '\(urlContextPacks)' is not valid JSON, error: \(error!)")
        }
    }
    
    //initializer for getting all of the wordPack information
    init(urlWordPacks: String, wpIDs: [String]){
        wordIDs = [String]()
        let nsurl = NSURL(string: urlWordPacks)
        var error: NSError?
        
        let wordPackData: NSData = NSData(contentsOfURL: nsurl!)!
        
        if let wordPackDictionary: AnyObject = NSJSONSerialization.JSONObjectWithData(wordPackData,
            options: NSJSONReadingOptions(), error: &error){
                let jsonWordPack = JSON(wordPackDictionary)
                wordPack = getStringStringDictionaryFromJSON(jsonWordPack, wordPackIDs: wpIDs)
        } else {
            println("The file at '\(urlWordPacks)' is not valid JSON, error: \(error!)")
        }
    }
    
    //initializer for getting tile information
    init(urlWords: String, wdIDs: [String]){
        let nsurl = NSURL(string: urlWords)
        var error: NSError?
        
        let wordData: NSData = NSData(contentsOfURL: nsurl!)!
        
        if let wordDictionary: AnyObject = NSJSONSerialization.JSONObjectWithData(wordData,
            options: NSJSONReadingOptions(), error: &error){
                let jsonWord = JSON(wordDictionary)
                words = getNestedDictionaryFromJSON(jsonWord, wordPackIDs: wdIDs)
        } else {
            println("The file at '\(urlWords)' is not valid JSON, error: \(error!)")
        }
    }

    
    //Deals with the nested array Default Word List
    init(arr: [[String]]!) {
        wordsWithWordPacks = arr
    }
    
}