//
//  DiffResult.swift
//  DeclarativeTableViewController
//
//  Created by Cal Stephens on 3/13/19.
//  Copyright © 2019 Cal Stephens. All rights reserved.
//


// MARK: - DiffResult

public struct DiffResult {
    public var deletedIndicies: Set<Int>
    public var insertedIndicies: Set<Int>
    public var unchangedIndicies: Set<Int>
    
    public init(
        deletedIndicies: [Int] = [],
        insertedIndicies: [Int] = [],
        unchangedIndicies: [Int] = [])
    {
        self.deletedIndicies = Set(deletedIndicies)
        self.insertedIndicies = Set(insertedIndicies)
        self.unchangedIndicies = Set(unchangedIndicies)
    }
    
}


// MARK: - Array + diff(against:)

public extension Array where Element: Hashable {
    
    func diff(against other: [Element]) -> DiffResult {
        let originalSet = Set<Element>(self)
        let changedSet = Set<Element>(other)
        
        var diffResult = DiffResult()
        
        for (index, cell) in self.enumerated() {
            if !changedSet.contains(cell) {
                diffResult.deletedIndicies.insert(index)
            }
        }
        
        for (index, cell) in other.enumerated() {
            if !originalSet.contains(cell) {
                diffResult.insertedIndicies.insert(index)
            } else {
                diffResult.unchangedIndicies.insert(index)
            }
        }
        
        return diffResult
    }
    
}

