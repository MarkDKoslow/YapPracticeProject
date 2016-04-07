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
    let isbn: String
    
    init(title: String, author: String, isbn: String) {
        self.title = title
        self.author = author
        self.isbn = isbn
    }
    
    required init?(coder aDecoder: NSCoder) {
        if let title = aDecoder.decodeObjectForKey("title") as? String,
            author = aDecoder.decodeObjectForKey("author") as? String,
            isbn = aDecoder.decodeObjectForKey("isbn") as? String {
            self.title = title
            self.author = author
            self.isbn = isbn
        } else {
            self.title = ""
            self.author = ""
            self.isbn = ""
        }
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(title, forKey: "title")
        aCoder.encodeObject(author, forKey: "author")
        aCoder.encodeObject(isbn, forKey: "isbn")
    }
}