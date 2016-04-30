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

    @IBOutlet weak var myTableView: UITableView!
    var connection: YapDatabaseConnection?
    var mappings: YapDatabaseViewMappings?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        myTableView.dataSource = self
        // Do any additional setup after loading the view, typically from a nib.
        
        let connection = Database.newConnection()
        self.connection = connection
        
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
        
//        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(yapDatabaseModified(_:)), name: YapDatabaseModifiedNotification, object: connection.database)
//        
        // Insert Books in database
        //
        connection.readWriteWithBlock({ transaction in
            for book in bookList {
                transaction.setObject(book, forKey: book.isbn, inCollection: "books")
            }
        })
        
        // Create view
        //
        let grouping = YapDatabaseViewGrouping.withObjectBlock { (_, _, _, object) -> String! in
            guard let book = object as? Book else { return nil }
            return String(book.title.lowercaseString.characters.first) // Grouping by book first character
        }
        
        let sorting = YapDatabaseViewSorting.withObjectBlock { (_, _, _, _, object1, _, _, object2) -> NSComparisonResult in
            guard let book1 = object1 as? Book, let book2 = object2 as? Book else { return .OrderedSame }
            return book1.title.compare(book2.title) // Sorting alphabetically
        }
        
        let view = YapDatabaseView(grouping: grouping, sorting: sorting, versionTag: "0")
        
        Database.registerExtension(view, withName: "bookList")
        
        // Make sure view has been created
        //
        connection.readWithBlock { transaction in
            let HuckFinn = transaction.objectForKey("0486280616", inCollection: "books")
            print("\(HuckFinn)")
        }
        
        // Initialize mappings
        //
        connection.beginLongLivedReadTransaction()
        self.initializeMappings()
        
        // Retreive objects from view
        var count = 0
        connection.readWithBlock { transaction in
            if let mappings = self.mappings {
                count = Int(mappings.numberOfItemsInAllGroups())
            }
            print(count)
        }
    }
    
    func initializeMappings() {
        self.mappings = YapDatabaseViewMappings(groupFilterBlock: { (group, transaction) -> Bool in
            return true
            }, sortBlock: { (group1, group2, transaction) -> NSComparisonResult in
                return group1.caseInsensitiveCompare(group2)
            }, view: "bookList")
    
        self.connection?.readWithBlock { transaction in
            self.mappings?.updateWithTransaction(transaction)
        }
    }
    
    func yapDatabaseModified(notification: NSNotification) {
        guard let connection = self.connection else { fatalError() }
        
        let notifications = connection.beginLongLivedReadTransaction()

        guard connection.ext("bookList").hasChangesForNotifications(notifications) else {
            connection.readWithBlock { self.mappings?.updateWithTransaction($0) }
            return
        }
        
        var rowChanges: NSArray?
        var sectionChanges: NSArray?
        
        connection.ext("bookList").getSectionChanges(&sectionChanges, rowChanges: &rowChanges, forNotifications: notifications, withMappings: self.mappings)
        
        print(rowChanges)
    }
}

extension ViewController: UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Int(mappings?.numberOfItemsInSection(UInt(section)) ?? 0)
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return Int(mappings?.numberOfSections() ?? 0)
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        guard let mappings = self.mappings, connection = self.connection else { fatalError() }

        var book: Book? = nil
        connection.readWithBlock { transaction in
            book = transaction.ext("bookList").objectAtIndexPath(indexPath, withMappings: mappings) as? Book
        }
        
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell")!
        cell.textLabel?.text = book?.title

        return cell
    }
}