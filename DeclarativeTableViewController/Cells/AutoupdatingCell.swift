//
//  AutoupdatingCell.swift
//  DeclarativeTableViewController
//
//  Created by Cal Stephens on 3/15/19.
//  Copyright © 2019 Cal Stephens. All rights reserved.
//

import UIKit


// MARK: AutoupdatingCell

/// A specialized cell that displays and updates its child by calling a `reloadHandler` closure as necessary
public class AutoupdatingCell: UITableViewCell, PassthroughCell {
    
    let childCell: UITableViewCell
    let shouldDisplayChild = true
    private let reloadHandler: () -> Void
    
    func reloadImmediateChild() {
        reloadHandler()
    }
    
    
    // MARK: Initalization
    
    public init<CellType: UITableViewCell>(_ cell: CellType, onReload reloadHandler: @escaping (CellType) -> Void) {
        self.childCell = cell
        self.reloadHandler = { reloadHandler(cell) }
        super.init(style: .default, reuseIdentifier: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
