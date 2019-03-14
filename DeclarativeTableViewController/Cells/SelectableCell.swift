//
//  SelectableCell.swift
//  DeclarativeTableViewController
//
//  Created by Cal Stephens on 3/13/19.
//  Copyright © 2019 Cal Stephens. All rights reserved.
//


// MARK: - SelectableCell

public protocol SelectableCell: class {
    
    var isCurrentlySelectable: Bool { get }
    
    func handleSelection()
    
}
