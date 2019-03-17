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

    // TODO: these tests are wrong now
    
    func testCanReloadTableContent() {
        assert(groupMemberCount: 5, viewingAsAdmin: false)
        pullToRefresh()
        assert(groupMemberCount: 6, viewingAsAdmin: false)
        pullToRefresh()
        assert(groupMemberCount: 6, viewingAsAdmin: false)
    }
    
    func testCanChangeUserStatus() {
        assert(groupMemberCount: 5, viewingAsAdmin: false)
        
        app.buttons["Viewing as Member"].tap()
        app.buttons["Admin"].tap()
        assert(groupMemberCount: 5, viewingAsAdmin: true)
        
        app.buttons["Viewing as Admin"].tap()
        app.buttons["Member"].tap()
        assert(groupMemberCount: 5, viewingAsAdmin: false)
        
        pullToRefresh()
        assert(groupMemberCount: 6, viewingAsAdmin: false)
        
        app.buttons["Viewing as Member"].tap()
        app.buttons["Admin"].tap()
        assert(groupMemberCount: 6, viewingAsAdmin: true)
    }
    
    func testCanSelectUser() {
        app.cells.element(boundBy: 5).tap()
        
        _ = app.alerts.element(boundBy: 0).waitForExistence(timeout: 10)
        XCTAssertEqual(app.alerts.element(boundBy: 0).staticTexts.element(boundBy: 0).label, "Member Detail")
        app.buttons["Dismiss"].tap()
        XCTAssertEqual(app.alerts.count, 0)
    }
    
    
    // MARK: Helpers
    
    private func assert(groupMemberCount: Int, viewingAsAdmin: Bool, file: StaticString = #file, line: UInt = #line) {
        let expectedTotalCellCount = groupMemberCount + (viewingAsAdmin ? 4 : 3)
        
        expectation(
            for: NSPredicate(format: "count == \(expectedTotalCellCount)"),
            evaluatedWith: app.tables.cells,
            handler: nil)
        
        waitForExpectations(timeout: 10, handler: { _ in
            XCTAssertEqual(self.app.tables.cells.count, expectedTotalCellCount, file: file, line: line)
            
            XCTAssertEqual(
                self.app.tables.cells.element(boundBy: 0).staticTexts.element(boundBy: 1).label,
                "\(groupMemberCount) members")
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
