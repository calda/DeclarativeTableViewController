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
        /// - Note: When the user pulls to refresh, the table view will call `rebuildTableViewContent`.
        case pullToRefresh
    }
    
    public init(tableStyle: UITableView.Style = .grouped, refreshStyle: RefreshStyle) {
        self.refreshStyle = refreshStyle
        super.init(style: tableStyle)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        tableView.keyboardDismissMode = .interactive
        tableView.delaysContentTouches = true
        
        buildTableViewContent()
        configure(for: refreshStyle)
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
    
    private func buildTableViewContent() {
        setupCells()
        
        for section in self.sections {
            section.additionalSectionConfiguration(for: self.tableView)
        }
        
        reloadData(animated: false)
    }
    
    /// Can be overridden in a subclass to perform some preparation
    /// before the table view is refreshed and rebuilt.
    open func tableViewWillRebuild() {
        // to be implemented in a subclass
    }
    
    /// Rebuilds the the UITableView by calling `setupCells()` and then `reloadData(animated: false)`
    public func rebuildTableViewContent(animated: Bool) {
        tableViewWillRebuild()
        buildTableViewContent()
        
        if animated {
            playFadeTransition()
        }
    }
    
    /// Reloads the UITableView content by updating the visibility of individual sections and cells.
    open func reloadData(animated: Bool = true) {
        let previousSectionCount = sectionsBeingDisplayed.count
        
        let _sectionsBeingDisplayed = sections.compactMap { section -> (TableViewSectionProvider, DiffResult)? in
            let diffResult = section.reloadData()
            
            if section.shouldDisplaySection {
                return (section, diffResult)
            } else {
                return nil
            }
        }
        
        self.sectionsBeingDisplayed = _sectionsBeingDisplayed.map { $0.0 }
        
        // If there's a different number of sections, do a hard table reload
        //
        // TODO: This could be rigged up to do a soft reload, but the Table View animation
        // insert/deletion math is really tricky to get right.
        guard previousSectionCount == sectionsBeingDisplayed.count,
            animated else
        {
            sectionsBeingDisplayed = sections.filter { $0.shouldDisplaySection }
            tableView.reloadData()
            
            if animated {
                UISelectionFeedbackGenerator().selectionChanged()
            }
            
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
        for (sectionIndex, (_, diffResult)) in _sectionsBeingDisplayed.enumerated() {
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
        
        // Then do a potentially deferred reload of the other sections.
        // This prevents a nasty visual glitch where cells in the non-mutated sections would jump erratically.
        if sectionsToDeferReloading.count != self.sectionsBeingDisplayed.count {
            DispatchQueue.main.async {
                self.tableView.reloadSections(IndexSet(sectionsToDeferReloading), with: .fade)
            }
        } else {
            // If all of the sections were deferred, then we actually have to just reload them all right now.
            // The workaround in `tableViewDidFinishRefreshing` somehow relies on there being atleast one
            // synchronous update animation.
            tableView.reloadSections(IndexSet(sectionsToDeferReloading), with: .fade)
        }
        
        // undo the contentInset hack applied above
        tableView.contentInset.bottom = _bottomContentInset
        
        // end any in-progress refreshes
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.tableViewDidFinishRefreshing()
        }
    }
    
    private func playFadeTransition() {
        let transition = CATransition()
        transition.type = .fade
        transition.duration = 0.2
        transition.timingFunction = CAMediaTimingFunction(name: .easeIn)
        self.view.layer.add(transition, forKey: nil)
    }
    
    
    // MARK: Refreshing
    
    private func configure(for refreshStyle: RefreshStyle) {
        switch refreshStyle {
        case .none:
            break
        case .pullToRefresh:
            let refreshControl = UIRefreshControl()
            
            refreshControl.addTarget(self,
                action: #selector(userPerformedPullToRefreshGesture),
                for: .valueChanged)
            
            self.refreshControl = refreshControl
        }
    }
    
    private var _refreshTableViewAfterScrollViewEndsDecelerating = false
    
    @objc private func userPerformedPullToRefreshGesture() {
        // Wait until the user releases finishes pull-down gesture (`scrollViewDidEndDecelerating`).
        // Otherwise, the Table View jumps around.
        // "Am I holding it wrong, or is it supposed to be this brittle?"
        _refreshTableViewAfterScrollViewEndsDecelerating = true
        
        // Since we have to wait for the scrolling animations to finish before we can move on
        // to the next step in the refresh process, increase the speed of the deceleration animations.
        tableView.decelerationRate = .fast
    }
    
    override open func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if _refreshTableViewAfterScrollViewEndsDecelerating {
            _refreshTableViewAfterScrollViewEndsDecelerating = false
            self.rebuildTableViewContent(animated: true)
        }
    }
    
    private func tableViewDidFinishRefreshing() {
        switch refreshStyle {
        case .none:
            break
        case .pullToRefresh:
            guard refreshControl?.isRefreshing == true else {
                return
            }
            
            // Scrolling to the top (even if already at the top) seems to prevent a visual glitch where the
            // animation would be jerky, and the Refresh Control would momentarily reappear afterwards.
            if tableView.contentOffset.y < 0 {
                tableView.scrollToRow(at: IndexPath(item: 0, section: 0), at: .top, animated: true)
            }
            
            DispatchQueue.main.async {
                self.refreshControl?.endRefreshing()
            }
            
            // reset the table back to `UIScrollView.DecelerationRate.normal`
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.35, execute: { [weak self] in
                self?.tableView.decelerationRate = .normal
            })
        }
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
        if sectionsBeingDisplayed[indexPath.section].cellIsSelectable(for: indexPath, in: tableView) {
            return indexPath
        } else {
            return nil
        }
    }
    
    override public final func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let section = sectionsBeingDisplayed[indexPath.section]
        section.handleSelection(for: indexPath, in: tableView)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05, execute: {
            tableView.selectRow(at: nil, animated: true, scrollPosition: .none)
        })
    }
    
    override public final func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sectionsBeingDisplayed[section].name
    }
    
}
