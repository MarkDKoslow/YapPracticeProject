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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // Read Books json
        let myFileURL = NSBundle.mainBundle().URLForResource("Books", withExtension: "json")!
        guard let fileData = NSData(contentsOfURL: myFileURL) else {
            fatalError("File could not be found")
        }
        
        // Parse Books json into dictionary
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
        let connection = Database.newConnection()
        var huckFinn: Book?
        
        connection.asyncReadWriteWithBlock ({ transaction in
            for book in bookList {
                transaction.setObject(book, forKey: book.isbn, inCollection: "Books")
            }
        }, completionBlock: {
            connection.readWithBlock { transaction in
                huckFinn = transaction.objectForKey("0486280616", inCollection: "Books") as? Book
            }
        })
        
        print("\(huckFinn)")
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