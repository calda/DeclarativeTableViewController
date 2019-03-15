//
//  PassthroughCell.swift
//  DeclarativeTableViewController
//
//  Created by Cal Stephens on 3/15/19.
//  Copyright © 2019 Cal Stephens. All rights reserved.
//

import UIKit


// MARK: - PassthroughCell

/// A protocol for creating specialized `UITableViewCell` constructs.
/// Cells that conform to this protocol shouldn't be displayed on-screen
/// -- instead, theymanage the lifecycle and visibility of a "child" cell.
///
/// - Note: It could be said that it's rather unusual to create `UITableViewCell` instances
///   that aren't actually intented to be displayed on-screen (since they're `UIView` subclasses),
///   BUT the declaration-site ergonomics are fantastic. See: `DemoApp.MultipleSectionExampleViewController`.
///
protocol PassthroughCell {
    
    /// The immediate child of this `PassthroughCell`
    /// - Note: This property does not recursively descend through any child `PassthroughCell`s.
    ///      See: `childToDisplay`
    var childCell: UITableViewCell { get }
    
    /// Whether or not the immediate child of this `PassthroughCell` should be displayed in the Table View
    var shouldDisplayChild: Bool { get }
    
    /// Notifies this `PassthroughCell` that it should update its immediate child cell as part of a Table View reload
    /// - Note: This property does not recursively descend through any child `PassthroughCell`s.
    ///      See: `reloadData`
    func reloadImmediateChild()
    
}

extension PassthroughCell {
    
    /// The actual child of this `PashhthroughCell`, recursively descending through child `PassthroughCell`s.
    var childToDisplay: UITableViewCell? {
        guard shouldDisplayChild else { return nil }
        
        if let passthroughChild = childCell as? PassthroughCell {
            return passthroughChild.childCell
        } else {
            return childCell
        }
        
    }
    
    func reloadData() {
        reloadImmediateChild()
        reloadPassthroughChild()
    }
    
    func reloadPassthroughChild() {
        if let passthroughChild = childCell as? PassthroughCell {
            passthroughChild.reloadData()
        }
    }
    
}
