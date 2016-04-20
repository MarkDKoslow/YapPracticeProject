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
        myTableView.delegate = self
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
        
        // Store Books in YAP
        //
        connection.readWriteWithBlock({ transaction in
            for book in bookList {
                transaction.setObject(book, forKey: book.isbn, inCollection: "Books")
            }
        })
        
        // TO DO: Need to create Mappings
        //
        connection.readWithBlock { transaction in
            self.mappings = YapDatabaseViewMappings(groupFilterBlock: { (group, transaction) -> Bool in
                return true
            }, sortBlock: { (group1, group2, transaction) -> NSComparisonResult in
                return group1.caseInsensitiveCompare(group2)
            }, view: CustomDatabaseExtension.BookList.name)
        }
        
        // Initialize mappings
        //
        connection.beginLongLivedReadTransaction()
        connection.readWithBlock { self.mappings?.updateWithTransaction($0) }
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(yapDatabaseModified(_:)), name: YapDatabaseModifiedNotification, object: connection.database)
        
        
        // Retreive objects from view
        var count = 0
        connection.readWithBlock { transaction in
            if let mappings = self.mappings {
                count = Int(mappings.numberOfItemsInAllGroups())
            }
            print(count)
        }
    }
    
    func yapDatabaseModified(notification: NSNotification) {
        guard let connection = self.connection else { fatalError() }
        connection.beginLongLivedReadTransaction()
//
//        var sectionChanges = []
//        var rowChanges = []
        
        connection.readWithBlock { self.mappings?.updateWithTransaction($0) }
//
//        
//        connection.ext(CustomDatabaseExtension.BookList.name).getSectionChanges(&sectionChanges, rowChanges: &rowChanges, forNotifications: notifications, withMappings: self.mappings)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension ViewController: UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let mappings = mappings {
            return Int(mappings.numberOfItemsInSection(UInt(section)))
        }
        return 1
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if let mappings = mappings {
            return Int(mappings.numberOfSections())
        }
        return 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        guard let mappings = self.mappings, connection = self.connection else { fatalError() }
        
        let groupName = mappings.groupForSection(UInt(indexPath.section))
        
        var book: Book? = nil
        connection.readWithBlock { transaction in
            book = transaction.ext(CustomDatabaseExtension.BookList.name).objectAtIndexPath(indexPath, withMappings: mappings) as? Book
        }
        
        var cell = tableView.dequeueReusableCellWithIdentifier("Cell") as UITableViewCell?
        if cell == nil {
            cell = UITableViewCell(style: .Default, reuseIdentifier: "Cell")
        }
        
        if let cell = cell {
            cell.textLabel?.text = book?.title
        }
        return cell!
    }
}

extension ViewController: UITableViewDelegate {
    
}