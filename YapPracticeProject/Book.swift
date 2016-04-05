//
//  Book.swift
//  YapPracticeProject
//
//  Created by Mark Koslow on 4/5/16.
//  Copyright © 2016 Mark Koslow. All rights reserved.
//

import Foundation

class Book: NSObject, NSCoding {
    let title: String
    let author: String
    
    init(title: String, author: String) {
        self.title = title
        self.author = author
    }
    
    required init?(coder aDecoder: NSCoder) {
        if let title = aDecoder.decodeObjectForKey("title") as? String,
            author = aDecoder.decodeObjectForKey("author") as? String {
            self.title = title
            self.author = author
        } else {
            self.title = ""
            self.author = ""
        }
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(title, forKey: "title")
        aCoder.encodeObject(author, forKey: "author")
    }
}