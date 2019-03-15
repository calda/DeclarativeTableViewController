//
//  DiffResult.swift
//  DeclarativeTableViewController
//
//  Created by Cal Stephens on 3/13/19.
//  Copyright © 2019 Cal Stephens. All rights reserved.
//

import Foundation


// MARK: - DiffResult

public struct DiffResult: Equatable {
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

extension Array where Element: Hashable {
    
    func diff(against other: [Element]) -> DiffResult {
        let originalSet = Set<Element>(self)
        let changedSet = Set<Element>(other)
        
        // It doesn't really make sense to have the same `UITableViewCell` displayed twice,
        // so I won't bother supporting diffing arrays with duplicate items at this time.
        precondition(originalSet.count == self.count, "diff(against:) does not support duplicate items at this time.")
        precondition(changedSet.count == other.count, "diff(against:) does not support duplicate items at this time.")
        
        var diffResult = DiffResult()
        
        // find the items that were deleted from the original array
        for (index, item) in self.enumerated() {
            if !changedSet.contains(item) {
                diffResult.deletedIndicies.insert(index)
            }
        }
        
        // find the items that were inserted into the new array
        for (index, item) in other.enumerated() {
            if !originalSet.contains(item) {
                diffResult.insertedIndicies.insert(index)
            }
        }
        
        // build the intermediate array without the deleted item
        var itemsNotDeletedFromOriginal = self
        for index in [Int](diffResult.deletedIndicies).sorted(by: >) {
            itemsNotDeletedFromOriginal.remove(at: index)
        }
        
        let setOfItemsRemainingFromOriginal = Set(itemsNotDeletedFromOriginal)
        for (index, item) in self.enumerated() {
            if setOfItemsRemainingFromOriginal.contains(item) {
                diffResult.unchangedIndicies.insert(index)
            }
        }
        
        return diffResult
    }
    
}


// MARK: Set<Int> + IndexPath

extension Collection where Element == Int {
    
    func indexPaths(in section: Int) -> [IndexPath] {
        return map { IndexPath(row: $0, section: section) }
    }
    
}
