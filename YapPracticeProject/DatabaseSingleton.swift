//
//  DatabaseSingleton.swift
//  YapPracticeProject
//
//  Created by Mark Koslow on 4/5/16.
//  Copyright © 2016 Mark Koslow. All rights reserved.
//

import Foundation
import YapDatabase

class Database {
    private static var sharedInstance: Database?
    
    // Set Database Instance (helper method, just calls init)
    class func setSharedDatabase(database: YapDatabase) {
        self.sharedInstance = Database(database: database)
    }
    
    // Clear Database Instance
    class func clearSharedInstance() {
        sharedInstance = nil
    }
    
    // Get Database Instance
    static var sharedDatabase: Database {
        if let sharedInstance = sharedInstance {
            return sharedInstance
        } else {
            fatalError("Shared database accessed without being initialized")
        }
    }
    
    static func newConnection() -> YapDatabaseConnection {
        return sharedDatabase.database.newConnection()
    }
    
    static func registerExtension(view: YapDatabaseExtension, withName name: String) {
        sharedDatabase.database.registerExtension(view, withName: name)
    }
    
    private let database: YapDatabase
    
    // Initialize Database
    private init(database: YapDatabase) {
        self.database = database
    }
}