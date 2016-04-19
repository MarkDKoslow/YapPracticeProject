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
                return String(book.title.characters.first)
            }
            
            let sorting = YapDatabaseViewSorting.withObjectBlock { (_, _, _, _, object1, _, _, object2) -> NSComparisonResult in
                guard let book1 = object1 as? Book, let book2 = object2 as? Book else { return .OrderedSame }
                return book1.title.compare(book2.title)
            }
                
            return YapDatabaseView(grouping: grouping, sorting: sorting, versionTag: "0")
        
//        default:
//            fatalError("Unknown group for events database view: \(group)")
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
        return registerExtension(customDatabaseExtension.ext, withName: customDatabaseExtension.name)
    }
}
