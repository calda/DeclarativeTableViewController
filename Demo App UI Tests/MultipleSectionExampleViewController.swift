//
//  MultipleSectionExampleViewController.swift
//  Demo App UI Tests
//
//  Created by Cal Stephens on 3/14/19.
//  Copyright © 2019 Cal Stephens. All rights reserved.
//

import XCTest

class MultipleSectionExampleViewController: XCTestCase {
    
    var app: XCUIApplication!
    
    override func setUp() {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
        
        app.tabBars.buttons["Group"].tap()
    }

    func testCanReloadTableContent() {
        assert(groupMemberCount: 5)
        pullToRefresh()
        assert(groupMemberCount: 6)
        pullToRefresh()
        assert(groupMemberCount: 6)
    }
    
    
    // MARK: Helpers
    
    private func assert(groupMemberCount: Int, file: StaticString = #file, line: UInt = #line) {
        expectation(
            for: NSPredicate(format: "count == \(groupMemberCount + 1)"),
            evaluatedWith: app.tables.cells,
            handler: nil)
        
        waitForExpectations(timeout: 10, handler: { _ in
            XCTAssertEqual(self.app.tables.cells.count, groupMemberCount + 1, file: file, line: line)
        })
    }
    
    private func pullToRefresh() {
        // simulate a pull-to-refresh
        let startPosition = CGPoint(x: 200, y: 150)
        let endPosition = CGPoint(x: 200, y: 500)
        
        let start = app.tables.element
            .coordinate(withNormalizedOffset: CGVector(dx: 0, dy: 0))
            .withOffset(CGVector(dx: startPosition.x, dy: startPosition.y))
        
        let finish = app.tables.element
            .coordinate(withNormalizedOffset: CGVector(dx: 0, dy: 0))
            .withOffset(CGVector(dx: endPosition.x, dy: endPosition.y))
        
        start.press(forDuration: 0, thenDragTo: finish)
    }
    
}
