//
//  ListExampleViewControllerTests.swift
//  Demo App UI Tests
//
//  Created by Cal Stephens on 3/13/19.
//  Copyright © 2019 Cal Stephens. All rights reserved.
//

import XCTest

class ListExampleViewControllerTests: XCTestCase {

    var app: XCUIApplication!
    
    override func setUp() {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
        
        app.tabBars.buttons["Music"].tap()
    }

    func testCanSwitchBetweenPlaylists() {
        assert(songCount: 12)
        
        app.buttons["Playlists"].tap()
        app.buttons["Indie"].tap()
        assert(songCount: 7)
        
        app.buttons["Playlists"].tap()
        app.buttons["Classic Rock"].tap()
        assert(songCount: 5)
        
        app.buttons["Playlists"].tap()
        app.buttons["All Songs"].tap()
        assert(songCount: 12)
        
        app.buttons["Playlists"].tap()
        app.buttons["Classic Rock"].tap()
        assert(songCount: 5)
        
        app.buttons["Playlists"].tap()
        app.buttons["All Songs"].tap()
        
        assert(songCount: 12)
    }
    
    func testCanSelectCellToStartPlayback() {
        // TODO: this would be a good addition
    }

    private func assert(songCount: Int, file: StaticString = #file, line: UInt = #line) {
        expectation(
            for: NSPredicate(format: "count == \(songCount)"),
            evaluatedWith: app.tables.cells,
            handler: nil)
        
        waitForExpectations(timeout: 10, handler: { _ in
            XCTAssertEqual(self.app.tables.cells.count, songCount, file: file, line: line)
        })
    }
    
}
