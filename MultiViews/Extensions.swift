//
//  Extensions.swift
//  FlashCardTrial
//
//  Created by Kristin Lamberty on 7/10/14.
//  Copyright (c) 2014 Kristin Lamberty. All rights reserved.
//

import Foundation

extension Dictionary {
    static func loadJSONFromBundle(filename: String) -> Dictionary<String, AnyObject>? {
        let path = NSBundle.mainBundle().pathForResource(filename, ofType: ".json")
        if (path == nil) {
            println("Could not find level file: \(filename)")
            return nil
        }
        
        var error: NSError?
        let data: NSData? = NSData(contentsOfFile: path!, options: NSDataReadingOptions(),
            error: &error)
//        if !data {
//            println("Could not load data from file: \(filename), error: \(error!)")
//            return nil
//        }
        
        let dictionary: AnyObject! = NSJSONSerialization.JSONObjectWithData(data!,
            options: NSJSONReadingOptions(), error: &error)
        if (dictionary == nil) {
            println("Level file '\(filename)' is not valid JSON: \(error!)")
            return nil
        }
        
        return dictionary as? Dictionary<String, AnyObject>
    }
    
}