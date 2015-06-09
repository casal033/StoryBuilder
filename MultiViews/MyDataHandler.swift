//
//  MyDataHandler.swift
//  SightWordFlashCards
//
//  Created by Kristin Lamberty on 7/23/14.
//  Copyright (c) 2014 Kristin Lamberty. All rights reserved.
//

import SpriteKit


class MyDataHandler {
    
    ///Users/lamberty/Dropbox/EmergentReaders/TryingSwift/FlashCardTrial
    //http://stackoverflow.com/questions/24097826/read-and-write-data-from-text-file
    
    class func writeWordsToFile(){
        let dirs : [String]? = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.AllDomainsMask, true) as? [String]
        println(dirs)
        
        if let directories:[String] = dirs {
            let dir = directories[0]; //documents directory
            let path = dir.stringByAppendingPathComponent("file.txt");
            let text = "some text again"
            
            //writing
            text.writeToFile(path, atomically: false, encoding: NSUTF8StringEncoding, error: nil);
            
            //reading
            let text2 = String(contentsOfFile:path, encoding: NSUTF8StringEncoding, error: nil)
        }
    }
}