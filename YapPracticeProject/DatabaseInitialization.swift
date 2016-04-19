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
    
    var sampleExt: YapDatabaseExtension {
        switch self {
        case .BookList:
            // This logic will be run on the entire database when the view is first created
            // Afterwards, it will be run each time an object in the database is modified

            // Grouping block determines which objects should be included in the view
            let grouping = YapDatabaseViewGrouping.withObjectBlock { (_, _, _, object) -> String! in
                guard let book = object as? Book else { return nil }
                return String(book.title.characters.first)
            }
            
            // Sorting block determines how objects should be ordered in the view
            let sorting = YapDatabaseViewSorting.withObjectBlock { (_, _, _, _, object1, _, _, object2) -> NSComparisonResult in
                guard let book1 = object1 as? Book, let book2 = object2 as? Book else { return .OrderedSame }
                return book1.title.compare(book2.title)
            }
            
            // This logic will only be run for updates to the books collection
            let options = YapDatabaseViewOptions()
            options.allowedCollections = YapWhitelistBlacklist(whitelist: ["books"] as Set<NSObject>)
            
            // Create the view
            return YapDatabaseView(grouping: grouping, sorting: sorting, versionTag: "0", options: options)
        }
    }
    
    var name: String {
        return String(self)
    }
}

func initializeDatabaseAtPath(databasePath: String) -> YapDatabase {
    let database = YapDatabase(path: databasePath)
    
    // Register Extensions here
    database.registerCustomExtension(.BookList)
    
    return database
}

extension YapDatabase {
    func registerCustomExtension(customDatabaseExtension: CustomDatabaseExtension) -> Bool {
        return registerExtension(customDatabaseExtension.sampleExt, withName: customDatabaseExtension.name)
    }
}
