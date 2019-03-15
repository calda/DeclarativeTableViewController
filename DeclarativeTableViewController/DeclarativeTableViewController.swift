//
//  DeclarativeTableViewController.swift
//  DeclarativeTableViewController
//
//  Created by Cal Stephens on 3/13/19.
//  Copyright © 2019 Cal Stephens. All rights reserved.
//

import UIKit

/// A `UITableViewController` subclass with a more declarative API.
///
/// - Note: A subclass of this type should implement the `setupCells` method.
open class DeclarativeTableViewController: UITableViewController {
    
    
    /// The sections to be displayed by this Table View.
    ///
    /// - Note: Updating this array or the contents within it doesn't automatically
    ///   reload the table view. You still need to call `tableViewController.reloadData()`.
    /// - Note: Since a TableViewSectionProvider can specify whether or not it should actually be displayed,
    ///   this array may not be equal to the list of sections actually being displayed at this moment.
    public var sections = [TableViewSectionProvider]()
    
    /// The sections currently being displayed by the Table View.
    /// - Note: Call `reloadData()` to update the visible sections.
    private(set) var sectionsBeingDisplayed = [TableViewSectionProvider]()
    
    /// The method in which the contents of this table view can be refreshed by the user
    public var refreshStyle: RefreshStyle
    
    public enum RefreshStyle {
        /// The Table View cannot be refreshed by the user
        case none
        
        /// The Table View can be refreshed using the standard Pull to Refresh pattern.
        /// - Note: When the user pulls to refresh, the table view will call `tableViewWillRebuild`,
        ///         and then call `setupCells` again.
        case pullToRefresh
    }
    
    public init(tableStyle: UITableView.Style = .grouped, refreshStyle: RefreshStyle) {
        self.refreshStyle = refreshStyle
        super.init(style: tableStyle)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// Sets up the Table View sections and cells,
    /// and generally kicks off any network requests necessary to populate the table.
    ///
    /// - Note: This method must be overridden in the `DeclarativeTableViewController` subclass.
    /// - Note: You should probably never call this method manually. Instead, call `rebuildTableViewContent`.
    /// - Note: This method is called as a part of `rebuildTableViewContent`,
    ///         which can be triggered programatically, or when the user pulls-to-refresh.
    open func setupCells() {
        fatalError("`setupCells()` must be overridden in this `DeclarativeTableViewController` subclass.")
    }
    
    /// Rebuilds the the UITableView by calling `setupCells()` and then `reloadData()`
    public func rebuildTableViewContent() {
        buildTableViewContent()
    }
    
    private func buildTableViewContent() {
        setupCells()
        
        for section in self.sections {
            section.additionalSectionConfiguration(for: self.tableView)
        }
        
        reloadData(animated: false)
    }
    
    /// Reloads the UITableView content by updating the visibility of individual sections and cells.
    open func reloadData(animated: Bool = true) {
        let previousSectionCount = sectionsBeingDisplayed.count
        sectionsBeingDisplayed = sections.filter { $0.shouldDisplaySection() && $0.numberOfRows > 0 }
        
        // If there's a different number of sections, do a hard table reload
        guard previousSectionCount == sectionsBeingDisplayed.count,
            animated else
        {
            sectionsBeingDisplayed.forEach { $0.reloadData() }
            tableView.reloadData()
            return
        }
        
        // Work around an issue where the table jump erratically when reloading in some conditions.
        // This seems to have to do with the Table View miscalculating its new contentSize on reload
        // (which happens here because the entire system is built around `UITableView.automaticDimension`
        // https://stackoverflow.com/a/53113789/2530060
        let _bottomContentInset = tableView.contentInset.bottom
        tableView.contentInset.bottom = 300
            
        // Do an animated reload of the individual sections
        tableView.beginUpdates()
        
        var sectionsToDeferReloading = [Int]()
        
        // First, do an insert/deletion reload of all of the sections that changed their row count
        for (sectionIndex, section) in sectionsBeingDisplayed.enumerated() {
            let diffResult = section.reloadData()
            
            // defer the reload of sections that don't change their cell count
            if diffResult.deletedIndicies.isEmpty && diffResult.insertedIndicies.isEmpty {
                sectionsToDeferReloading.append(sectionIndex)
            } else {
                tableView.deleteRows(at: diffResult.deletedIndicies.indexPaths(in: sectionIndex),   with: .fade)
                tableView.insertRows(at: diffResult.insertedIndicies.indexPaths(in: sectionIndex),  with: .fade)
                tableView.reloadRows(at: diffResult.unchangedIndicies.indexPaths(in: sectionIndex), with: .fade)
            }
        }
        
        tableView.endUpdates()
        
        // Then do a slightly deferred reload of the other sections.
        // This prevents a nasty visual glitch where cells in the non-mutated sections would jump erratically.
        DispatchQueue.main.async {
            self.tableView.reloadSections(IndexSet(sectionsToDeferReloading), with: .fade)
        }
        
        // undo the contentInset hack applied above
        tableView.contentInset.bottom = _bottomContentInset
    }
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        tableView.keyboardDismissMode = .interactive
        tableView.delaysContentTouches = true
        
        buildTableViewContent()
        
        switch refreshStyle {
        case .none:
            break
        case .pullToRefresh:
            let refreshControl = UIRefreshControl()
            refreshControl.addTarget(self, action: #selector(refreshTableViewContent), for: .valueChanged)
            self.refreshControl = refreshControl
        }
    }
    
    // TODO: instead of forcing shut the refresh control immediately, maybe keep it visible until the following `relaodData`
    @objc private func refreshTableViewContent() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: { [weak self] in
            // stop the in-progress scroll associated with the pull-to-refresh action
            // so the table view can refresh correctly without an unusual animation
            self?.tableView.panGestureRecognizer.isEnabled = false
            self?.refreshControl?.endRefreshing()
        })
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.725, execute: { [weak self] in
            guard let self = self else { return }
            self.tableViewWillRebuild()
            self.tableView.panGestureRecognizer.isEnabled = true
            self.rebuildTableViewContent()
            
            let transition = CATransition()
            transition.type = .fade
            transition.duration = 0.2
            transition.timingFunction = CAMediaTimingFunction(name: .easeIn)
            self.view.layer.add(transition, forKey: nil)
        })
    }
    
    /// Can be overridden in a subclass to reset any model objects (i.e. fetched arrays)
    /// or perform other preparation before the table view is refreshed and rebuilt.
    open func tableViewWillRebuild() {
        // to be implemented in a subclass
    }
    
    
    // MARK: UITableViewDataSource
    
    override public final func numberOfSections(in tableView: UITableView) -> Int {
        return sectionsBeingDisplayed.count
    }
    
    override public final func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sectionsBeingDisplayed[section].numberOfRows
    }
    
    override public final func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = sectionsBeingDisplayed[indexPath.section].createCell(for: indexPath, in: tableView)
        cell.alpha = 1.0
        return cell
    }
    
    
    // MARK: UITableViewDelegate
    
    override public final func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if let cell = sectionsBeingDisplayed[indexPath.section].cell(for: indexPath, in: tableView) as? SelectableCell,
            !cell.isCurrentlySelectable
        {
            return nil
        }
        
        return indexPath
    }
    
    override public final func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let section = sectionsBeingDisplayed[indexPath.section]
        section.handleSelection(for: indexPath, in: tableView)
        
        if let cell = section.cell(for: indexPath, in: tableView) as? SelectableCell {
            cell.handleSelection()
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05, execute: {
            tableView.selectRow(at: nil, animated: true, scrollPosition: .none)
        })
    }
    
    override public final func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sectionsBeingDisplayed[section].name
    }
    
}
