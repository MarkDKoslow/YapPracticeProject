//
//  DatabaseInitialization.swift
//  YapPracticeProject
//
//  Created by Mark Koslow on 4/5/16.
//  Copyright © 2016 Mark Koslow. All rights reserved.
//

import Foundation
import YapDatabase

enum SplashDatabaseExtension {
    
}

func initializeDatabaseAtPath(databasePath: String) -> YapDatabase {
    let database = YapDatabase(path: databasePath)
    
    // Register Extensions here
    
    return database
}