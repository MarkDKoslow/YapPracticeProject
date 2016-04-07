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
        
        let myFileURL = NSBundle.mainBundle().URLForResource("Books", withExtension: "json")!
        
        do {
            let readFile = try String(contentsOfURL: myFileURL, encoding: NSUTF8StringEncoding)
            print("\(readFile)")
        } catch let error as NSError {
            print("There was an error \(error)")
        }
        
//        let connection = Database.newConnection()
//        
//        connection.readWriteWithBlock { transaction in
//            transaction.setObject(<#T##object: AnyObject?##AnyObject?#>, forKey: <#T##String#>, inCollection: <#T##String?#>)
//        }
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