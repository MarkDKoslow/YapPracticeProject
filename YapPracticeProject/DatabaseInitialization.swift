//
//  DatabaseInitialization.swift
//  YapPracticeProject
//
//  Created by Mark Koslow on 4/5/16.
//  Copyright © 2016 Mark Koslow. All rights reserved.
//

import Foundation
import YapDatabase

enum CustomDatabaseExtension {
    case BookList
    
    var ext: YapDatabaseExtension {
        switch self {
        case .BookList:
            let grouping = YapDatabaseViewGrouping.withObjectBlock { (_, _, _, object) -> String! in
                guard let book = object as? Book else { return nil }
                return book.firstCharacter
            }
        }
    }
    
    var name: String {
        return String(self)
    }
}

func initializeDatabaseAtPath(databasePath: String) -> YapDatabase {
    let database = YapDatabase(path: databasePath)
    
    // Register Extensions here
    database.registeredExtension("BookList")
    
    return database
}

extension YapDatabase {
    func registerCustomExtension(customDatabaseExtension: CustomDatabaseExtension) -> Bool {
        return registerExtension(customDatabaseExtension.ext, withName: customDatabaseExtension.name)
    }
}
