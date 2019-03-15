//
//  TableViewSectionProvider.swift
//  DeclarativeTableViewController
//
//  Created by Cal Stephens on 3/13/19.
//  Copyright © 2019 Cal Stephens. All rights reserved.
//

import UIKit


// MARK: - TableViewSectionProvider

public protocol TableViewSectionProvider {
    
    var numberOfRows: Int { get }
    var name: String? { get }
    var shouldDisplaySection: Bool { get }
    
    @discardableResult func reloadData() -> DiffResult
    func createCell(for indexPath: IndexPath, in tableView: UITableView) -> UITableViewCell
    func cell(for indexPath: IndexPath, in tableView: UITableView) -> UITableViewCell
    func additionalSectionConfiguration(for tableView: UITableView)
    
    func cellIsSelectable(for indexPath: IndexPath, in tableView: UITableView) -> Bool
    func handleSelection(for indexPath: IndexPath, in tableView: UITableView)
    
}
