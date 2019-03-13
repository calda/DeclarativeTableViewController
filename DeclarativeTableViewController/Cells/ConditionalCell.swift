//
//  ConditionalCell.swift
//  DeclarativeTableViewController
//
//  Created by Cal Stephens on 3/13/19.
//  Copyright © 2019 Cal Stephens. All rights reserved.
//

import UIKit


// MARK: - ConditionalCell

public class ConditionalCell: UITableViewCell {
    
    public let cellToDisplay: UITableViewCell
    public let shouldDisplayCell: () -> Bool
    
    public init(_ cell: UITableViewCell, displayIf condition: @escaping () -> Bool) {
        self.cellToDisplay = cell
        self.shouldDisplayCell = condition
        super.init(style: .default, reuseIdentifier: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
