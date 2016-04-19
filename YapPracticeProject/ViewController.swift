//
//  ViewController.swift
//  YapPracticeProject
//
//  Created by Mark Koslow on 4/5/16.
//  Copyright © 2016 Mark Koslow. All rights reserved.
//

import UIKit
import YapDatabase

class ViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    let connection = Database.newConnection()
    var mappings: YapDatabaseViewMappings?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // Read Books json
        //
        let myFileURL = NSBundle.mainBundle().URLForResource("Books", withExtension: "json")!
        guard let fileData = NSData(contentsOfURL: myFileURL) else {
            fatalError("File could not be found")
        }
        
        // Parse Books json into dictionary
        //
        var bookList = [Book]()
        do {
            let json = try NSJSONSerialization.JSONObjectWithData(fileData, options: .AllowFragments)
            print("\(json)")
            
            if let books = json["books"] as? [[String: String]] {
                for book in books {
                    guard let bookTitle = book["title"], author = book["author"], isbn = book["isbn"] else {
                        fatalError("Book could not be parsed correctly")
                    }
                    let bookObject = Book(title: bookTitle, author: author, isbn: isbn)
                    bookList.append(bookObject)
                }
            }
        } catch {
            print("lolz fail")
        }
        
        // Store Books in YAP
        //
        connection.readWriteWithBlock({ transaction in
            for book in bookList {
                transaction.setObject(book, forKey: book.isbn, inCollection: "Books")
            }
        })
//        connection.readWithBlock { transaction in
//            huckFinn = transaction.objectForKey("0486280616", inCollection: "Books") as? Book
//        }
        
        // TO DO: Need to create Mappings
        //
        connection.readWithBlock { transaction in
            let grouping = YapDatabaseViewMappingGroupFilter {
                return { (group, transaction) -> Bool in
                    return true
                }
            }
            
            let sorting = YapDatabaseViewMappingGroupSort {
                return { (group1, group2, transaction) -> NSComparisonResult in
                    return group1.caseInsensitiveCompare(group2)
                }
            }
            
            mappings = YapDatabaseViewMappings(groupFilterBlock: grouping, sortBlock: sorting, view: CustomDatabaseExtension.BookList.name)
        }
        
        // Initialize mappings
        //
//        connection.beginLongLivedReadTransaction()
        connection.readWithBlock { self.mappings?.updateWithTransaction($0) }
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(yapDatabaseModified:), name: YapDatabaseModifiedNotification, object: connection.database)
        
        
        // Retreive objects from view
        var count = 0
        connection.readWithBlock { transaction in
            
            let myExt = transaction.ext(CustomDatabaseExtension.BookList.name)
            count = myExt.numberOfItemsInAllGroups()
        }
        print(count)
        
        // TO DO: Propogate view with mappings
        //
        
    }
    
    func yapDatabaseModified(notification: NSNotification) {
        var notifications = connection.beginLongLivedReadTransaction()
        
        var sectionChanges = []
        var rowChanges = []
        
        connection.ext(CustomDatabaseExtension.BookList.name).getSectionChanges(&sectionChanges, rowChanges: &rowChanges, forNotifications: notifications, withMappings: self.mappings)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension ViewController: UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
}

extension ViewController: UITableViewDelegate {
    
}