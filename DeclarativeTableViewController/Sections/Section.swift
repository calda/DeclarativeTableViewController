//
//  Section.swift
//  DeclarativeTableViewController
//
//  Created by Cal Stephens on 3/13/19.
//  Copyright © 2019 Cal Stephens. All rights reserved.
//

import UIKit


// MARK: - Section

/// A simple `UITableView` `Section` backed by an array of `UITableViewCell` instances.
public class Section: TableViewSectionProvider, Equatable {
    
    /// The `UITableViewCell` instances managed by this table.
    ///
    /// Rather than inserting and removing cells from this array,
    /// consider using `ConditionalCell`.
    ///
    /// The on-screen section is not updated until you call
    /// `DeclarativeTableViewController.reloadData(animated:)`.
    ///
    public var cells: [UITableViewCell] {
        didSet {
            reloadData()
        }
    }
    
    public var name: String?
    public var shouldDisplaySection: () -> Bool
    private var cellsToDisplay = [UITableViewCell]()
    
    /// Initializes a new `Section`, displaying the given `UITableViewCell` instances.
    ///
    /// This `Section` doesn't participate in `UITableViewCell` dequeueing or cell reuse,
    /// so be cognizant of the potential memory overhead when building your Table View.
    ///
    /// `Section` is most appropriate when there is a small, closed, and bounded configuration
    /// of cells that could be displayed in this section. If the number of cells is potentially unbounded,
    /// you should more likely be using `ReusableCellSection`.
    ///
    /// - Parameters:
    ///   - name: The name of the section, displayed by the Table View in `UITableView.Style.grouped`
    ///   - displayIf: A closure specifying whether or not this section should be visible in the UITableView.
    ///   - cells: The `UITableViewCell` instances to display in this section.
    ///
    public init(
        name: String? = nil,
        displayIf condition: @escaping () -> Bool = { true },
        cells: [UITableViewCell])
    {
        self.name = name
        self.shouldDisplaySection = condition
        self.cells = cells
        reloadData()
    }
    
    public static func ==(_ lhs: Section, _ rhs: Section) -> Bool {
        return lhs.name == rhs.name && lhs.cells == rhs.cells
    }
    
    
    // MARK: TableViewSectionProvider
    
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
    
    public var numberOfRows: Int {
        return cellsToDisplay.count
    }
    
    public func cell(for indexPath: IndexPath, in tableView: UITableView) -> UITableViewCell {
        guard (0 ..< cellsToDisplay.count).contains(indexPath.row) else {
            return UITableViewCell()
        }
        
        let cell = cellsToDisplay[indexPath.row]
        
        // There are few things that make me more upset than nonsense like this,
        // but there was an issue where refreshing the Table View would cause the
        // cells in this `Section` to disappear when using `UITableView.RowAnimation.fade`
        // (in `DemoApp.MultipleSectionExampleViewController`). This didn't happen with
        // `UITableView.RowAnimation.none` (or any of the other row animations, either).
        // So in lieu of an actual fix, this workaround seems to do for now.
        DispatchQueue.main.async {
            cell.alpha = 1
        }
        
        return cell
    }
    
    public func createCell(for indexPath: IndexPath, in tableView: UITableView) -> UITableViewCell {
        return cell(for: indexPath, in: tableView)
    }
    
    public func additionalSectionConfiguration(for tableView: UITableView) {
        // noop, nothing to configure
    }
    
    public func handleSelection(for indexPath: IndexPath, in tableView: UITableView) {
        // noop, selection needs to be handled on a per-cell basis. See: `SelectableCell`.
    }
    
}
