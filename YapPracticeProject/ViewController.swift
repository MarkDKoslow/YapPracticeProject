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
        
        // Create new connection with the database 
        //
        let connection = Database.newConnection()
        self.connection = connection
        
        // Create Booklist
        //
        let bookList = [
            Book(title: "Don Quixote", author: "Miguel De Cervantes", isbn: "0060934344"),
            Book(title: "Pilgrim's Progress", author: "John Bunyan", isbn: "0486426750"),
            Book(title: "Robinson Crusoe", author: "Daniel Defoe", isbn: "150329238X"),
            Book(title: "Tom Jones", author: "Henry Fielding", isbn: "0199536996"),
            Book(title: "Gulliver's Travels", author: "Jonathan Swift", isbn: "0486292738"),
            Book(title: "Clarissa", author: "Samuel Richardson", isbn: "0140432159"),
            Book(title: "Emma", author: "Jane Austen", isbn: "1503261964"),
            Book(title: "Frankenstein", author: "Mary Shelley", isbn: "0486282112"),
            Book(title: "David Copperfield", author: "Charles Dickens", isbn: "0140439447"),
            Book(title: "Alice In Wonderland", author: "Lewis Carroll", isbn: "0553213458"),
            Book(title: "Anna Karenina", author: "Leo Tolstoy", isbn: "067978330X"),
            Book(title: "Daniel Deronda", author: "George Eliot", isbn: "0140434275"),
            Book(title: "Huckleberry Finn", author: "Mark Twain", isbn: "0486280616"),
            Book(title: "As I Lay Dying", author: "William Faulkner", isbn: "067973225")
        ]
   
        // Insert Books in database
        //
        connection.readWriteWithBlock({ transaction in
            for book in bookList {
                transaction.setObject(book, forKey: book.isbn, inCollection: "books")
            }
        })
        
        // Create YAP view and register extensions
        //
        let grouping = YapDatabaseViewGrouping.withObjectBlock { (_, _, _, object) -> String! in
            guard let book = object as? Book else { return nil }
            return String(book.title.uppercaseString.characters.first ?? "?") // Grouping by book first character
        }
        
        let sorting = YapDatabaseViewSorting.withObjectBlock { (_, _, _, _, object1, _, _, object2) -> NSComparisonResult in
            guard let book1 = object1 as? Book, let book2 = object2 as? Book else { return .OrderedSame }
            return book1.title.compare(book2.title) // Sorting alphabetically
        }
        
        let view = YapDatabaseView(grouping: grouping, sorting: sorting, versionTag: "0")
        
        Database.registerExtension(view, withName: "bookList")
        
        // Make sure view has been created. (Would normally write a test for this)
        //
        connection.readWithBlock { transaction in
            let HuckFinn = transaction.objectForKey("0486280616", inCollection: "books")
            print("\(HuckFinn)")
        }
        
        // Initialize mappings
        //
        connection.beginLongLivedReadTransaction()
        self.initializeMappings()
        
        // Make sure numberOfItems is correct. (Would normally write a test for this)
        //
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
}

extension ViewController: UITableViewDataSource {
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return Int(mappings?.numberOfSections() ?? 0)
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Int(mappings?.numberOfItemsInSection(UInt(section)) ?? 0)
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard let mappings = self.mappings else { fatalError("Mappings not initialized") }
        return mappings.groupForSection(UInt(section))
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        guard let mappings = self.mappings, connection = self.connection else { fatalError(("Mappings or connection not initialized")) }

        var book: Book? = nil
        connection.readWithBlock { transaction in
            book = transaction.ext("bookList").objectAtIndexPath(indexPath, withMappings: mappings) as? Book
        }
        
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell")!
        cell.textLabel?.text = book?.title

        return cell
    }
}