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
        assert(songCount: 5)
        
        app.buttons["Playlists"].tap()
        app.buttons["Classic Rock"].tap()
        assert(songCount: 5)
        
        app.buttons["Playlists"].tap()
        app.buttons["All Songs"].tap()
        assert(songCount: 12)
        
        app.buttons["Playlists"].tap()
        app.buttons["Classic Rock"].tap()
        assert(songCount: 7)
    }

    private func assert(songCount: Int) {
        expectation(
            for: NSPredicate(format: "count == \(songCount * 2)"),
            evaluatedWith: app.tables.staticTexts,
            handler: nil)
        
        waitForExpectations(timeout: 10, handler: nil)
        XCTAssertEqual(app.tables.staticTexts.count, songCount * 2)
    }
    
}
