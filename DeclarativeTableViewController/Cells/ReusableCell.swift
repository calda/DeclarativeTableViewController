//
//  ReusableCell.swift
//  DeclarativeTableViewController
//
//  Created by Cal Stephens on 3/14/19.
//  Copyright © 2019 Cal Stephens. All rights reserved.
//

import UIKit


// MARK: ReusableCell

/// A `UITableViewCell` that can be reused. See: `ReusableCellSection`.
public protocol ReusableCell: class {
    
    associatedtype ModelType
    
    func display(_ model: ModelType)
    
    
    /// The height of this `UITableViewCell` instance.
    ///
    /// - Note: By default, this property returns `UITableView.automaticDimension`.
    ///   You can implement this property and return an actual height
    ///   to opt-out of using AutoLayout to automatically define your cell height.
    var height: CGFloat { get }
    
    /// An estimate of the height of cells of this type.
    ///
    /// - Note: By default, this property returns `UITableView.automaticDimension`.
    ///   This means that the Table View will have to check `height` for every cell
    ///   in the `ReusableCellSection`, which can be especially expensive if there are
    ///   a lot of cells to be displayed.
    ///
    ///   If you implement `estimatedHeight`, cells of this type will be capable of being loaded lazily.
    ///
    static var estimatedHeight: CGFloat { get }
    
}


public extension ReusableCell {
    
    static var estimatedHeight: CGFloat {
        return UITableView.automaticDimension
    }
    
    var height: CGFloat {
        return UITableView.automaticDimension
    }
    
}
