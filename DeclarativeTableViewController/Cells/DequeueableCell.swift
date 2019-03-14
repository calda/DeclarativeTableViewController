//
//  DequeueableCell.swift
//  DeclarativeTableViewController
//
//  Created by Cal Stephens on 3/14/19.
//  Copyright © 2019 Cal Stephens. All rights reserved.
//

import UIKit


// MARK: DequeueableCell

public protocol DequeueableCell: class {
    
    associatedtype ModelType
    
    func display(_ model: ModelType)
    
}
