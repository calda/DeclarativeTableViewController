//
//  Section.swift
//  DeclarativeTableViewController
//
//  Created by Cal Stephens on 3/13/19.
//  Copyright © 2019 Cal Stephens. All rights reserved.
//

import UIKit


// MARK: - Section

/// A simple UITableView Section backed by an array of UITableViewCells
public class Section: TableViewSectionProvider, Equatable {
    
    public var name: String?
    public var shouldDisplaySection: () -> Bool
    public var cells: [UITableViewCell] {
        didSet {
            reloadData()
        }
    }
    
    private var cellsToDisplay = [UITableViewCell]()
    
    public init(name: String? = nil, displayIf condition: @escaping () -> Bool = { true }, cells: [UITableViewCell]) {
        self.name = name
        self.shouldDisplaySection = condition
        self.cells = cells
        reloadData()
    }
    
    public static func ==(_ lhs: Section, _ rhs: Section) -> Bool {
        return lhs.name == rhs.name && lhs.cells == rhs.cells
    }
    
    @discardableResult
    public func reloadData() -> DiffResult {
        let cellsBeforeReload = cellsToDisplay
        
        cellsToDisplay = cells.compactMap { cell in
            // support `ConditionalCell`
            if let conditionalCell = cell as? ConditionalCell {
                if conditionalCell.shouldDisplayCell() {
                    return conditionalCell.cellToDisplay
                } else {
                    return nil
                }
            }
            
            return cell
        }
        
        return cellsBeforeReload.diff(against: cellsToDisplay)
    }
    
    
    // MARK: TableViewSectionProvider
    
    public var numberOfRows: Int {
        return cellsToDisplay.count
    }
    
    public func cell(for indexPath: IndexPath, in tableView: UITableView) -> UITableViewCell {
        guard (0 ..< cellsToDisplay.count).contains(indexPath.row) else {
            return UITableViewCell()
        }
        
        return cellsToDisplay[indexPath.row]
    }
    
    public func createCell(for indexPath: IndexPath, in tableView: UITableView) -> UITableViewCell {
        return cell(for: indexPath, in: tableView)
    }
    
    public func additionalSectionConfiguration(for tableView: UITableView) {
        return
    }
    
}
