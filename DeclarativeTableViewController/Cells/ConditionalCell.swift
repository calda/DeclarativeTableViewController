//
//  ConditionalCell.swift
//  DeclarativeTableViewController
//
//  Created by Cal Stephens on 3/13/19.
//  Copyright © 2019 Cal Stephens. All rights reserved.
//

import UIKit


// MARK: - ConditionalCell

/// A specialized cell that conditionally displays its child based on a `displayCondition` closure.
public class ConditionalCell: UITableViewCell, PassthroughCell {
    
    let childCell: UITableViewCell
    var shouldDisplayChild: Bool
    private let displayCondition: () -> Bool
    
    func reloadImmediateChild() {
        shouldDisplayChild = displayCondition()
    }
    
    
    // MARK: Initalization
    
    public init(_ cell: UITableViewCell, displayIf condition: @escaping () -> Bool) {
        self.childCell = cell
        self.displayCondition = condition
        self.shouldDisplayChild = displayCondition()
        super.init(style: .default, reuseIdentifier: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
