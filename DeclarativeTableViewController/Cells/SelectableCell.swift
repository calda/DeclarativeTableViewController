//
//  SelectableCell.swift
//  DeclarativeTableViewController
//
//  Created by Cal Stephens on 3/13/19.
//  Copyright © 2019 Cal Stephens. All rights reserved.
//

import UIKit


// MARK: - SelectableCell

public protocol SelectableCell: class {
    
    var isCurrentlySelectable: Bool { get }
    var preferredSelectionStyle: UITableViewCell.SelectionStyle { get }
    
    func handleSelection()
    
}

public extension SelectableCell {
    
    var preferredSelectionStyle: UITableViewCell.SelectionStyle {
        return .gray
    }
    
}
