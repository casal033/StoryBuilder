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
    
    static func loadJSONFromWeb(urlstring: String) -> Dictionary<String, AnyObject>? {
        
        let url = NSURL(string: urlstring)
        //let config = NSURLSessionConfiguration.defaultSessionConfiguration()
        //let session = NSURLSession(configuration: config, delegate: nil, delegateQueue: NSOperationQueue())
        
        var error: NSError?
        //I think I am using the completionHandler incorrectly. I'd like to access the data from the download
        //let task = session.downloadTaskWithRequest(NSURLRequest(URL: url), {(url, response, error) in println("The response is: \(response)")
        //   })
        //task.resume()
        
        //Isn't this contentsOfURL thing supposed to go with the connection stuff rather than the session stuff?
        //How can I do this with a session? How can I create and use a completionHandler? This way seems clunky.
        let data: NSData = NSData(contentsOfURL: url!)!
        if let url = NSURL(string: "") {
            if let data = NSData(contentsOfURL: url) { // may return nil, too
                // do something with data
            }
        }
        
        let json = JSON(data: dataFromNetworking)
        
//        if data == nil {
//            println("Could not load data from file: \(url), error: \(error!)")
//            return nil
//        }
        println("The data is: \(data)")
        
        let dictionary: AnyObject! = NSJSONSerialization.JSONObjectWithData(data,
            options: NSJSONReadingOptions(), error: &error)
        if (dictionary == nil) {
            println("The file at '\(url)' is not valid JSON, error: \(error!)")
            return nil
        }
        
        return dictionary as? Dictionary<String, AnyObject>
        
    }
    
    
}