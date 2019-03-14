//
//  DiffResultTests.swift
//  Unit Tests
//
//  Created by Cal Stephens on 3/13/19.
//  Copyright © 2019 Cal Stephens. All rights reserved.
//

@testable import DeclarativeTableViewController
import XCTest

class ArrayDiffResultTests: XCTestCase {
    
    func testArrayDiff_additions_noReordering() {
        let firstArray =  [2, 4, 6, 8]
        let secondArray = [1, 2, 3, 5, 6, 8, 9]
        
        XCTAssertEqual(
            firstArray.diff(against: secondArray),
            DiffResult(
                deletedIndicies: [1],
                insertedIndicies: [0, 2, 3, 6],
                unchangedIndicies: [0, 2, 3]))
    }
    
    func testArrayDiff_deletions_noReordering() {
        let firstArray = [0, 1, 2, 3, 4, 5, 6, 7]
        let secondArray = [0, 5, 6]
        
        XCTAssertEqual(
            firstArray.diff(against: secondArray),
            DiffResult(
                deletedIndicies: [1, 2, 3, 4, 7],
                insertedIndicies: [],
                unchangedIndicies: [0, 5, 6]))
    }
    
    func testArrayDiff_withReordering() {
        let firstArray =  [1, 3, 2, 5, 6]
        let secondArray = [0, 5, 3, 2, 1, 6]
        
        // This is designed for items becoming hidden or unhidden, and not necessarily moving around within the table
        // This still produces acceptable behavior in the table view, though.
        XCTAssertEqual(
            firstArray.diff(against: secondArray),
            DiffResult(
                deletedIndicies: [],
                insertedIndicies: [0],
                unchangedIndicies: [0, 1, 2, 3, 4]))
        
        // TODO: Potentially add beter reordering support.
        // If you wanted to actually see an animated delete/insert for items that move around in the table,
        // you'd probably need a DiffResult that looks like this:
        //
        //   DiffResult(
        //       deletedIndicies: [0, 2],
        //       insertedIndicies: [0, 1, 4],
        //       unchangedIndicies: [2, 3, 5]))
        //
    }
    
}
