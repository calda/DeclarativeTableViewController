//
//  ReusableCellSection.swift
//  DeclarativeTableViewController
//
//  Created by Cal Stephens on 3/13/19.
//  Copyright © 2019 Cal Stephens. All rights reserved.
//

import UIKit


// MARK: - ReusableCellSection

/// A more traditional UITableView Section that dequeues reusable cells of a certain predefined type
public class ReusableCellSection: TableViewSectionProvider, Equatable {
    
    public var name: String?
    public var shouldDisplaySection: () -> Bool
    private let reuseIdentifier = UUID().uuidString
    private let dequeableCellType: AnyClass
    
    private var typeErasedItems: [Any]?
    private let retrieveTypeErasedItems: () -> [Any]?
    private let typeErasedDecoratorBlock: (Any, UITableViewCell) -> Void
    private let diffItemArrays: ([Any], [Any]) -> DiffResult
    
    /// The cell to be shown if `numberOfItems` is 0
    /// (i.e. before the content has finised loading)
    public var placeholderCell: UITableViewCell
    
    public init<DequeableCell: UITableViewCell, Model: Hashable>(
        name: String?,
        cellType: DequeableCell.Type,
        displayIf condition: @escaping () -> Bool = { true },
        placeholderCell: UITableViewCell = LoadingIndicatorCell(),
        items: @escaping () -> [Model]?,
        decorator: @escaping (Model, DequeableCell) -> Void)
    {
        if cellType == ConditionalCell.self {
            fatalError("`ReusableCellSection` does not support `ConditionalCell`.")
        }
        
        self.name = name
        self.shouldDisplaySection = condition
        self.dequeableCellType = cellType
        self.placeholderCell = placeholderCell
        
        // type-erase the `Model` and `DequeableCell` closures
        self.retrieveTypeErasedItems = { return items() }
        self.typeErasedItems = retrieveTypeErasedItems()
        
        self.typeErasedDecoratorBlock = { untypedModel, untypedCell in
            guard let typedModel = untypedModel as? Model else {
                fatalError("Unable to reconstruct `\(Model.self)` from `\(type(of: untypedModel))`")
            }
            
            guard let typedCell = untypedCell as? DequeableCell else {
                fatalError("Unable to reconstruct `\(DequeableCell.self)` from `\(type(of: untypedCell))`")
            }
            
            decorator(typedModel, typedCell)
        }
        
        self.diffItemArrays = { originalUntypedArray, newUntypedArray in
            guard let originalTypedArray = originalUntypedArray as? [Model] else {
                fatalError("Unable to reconstruct `\([Model].self)` from `\(type(of: originalUntypedArray))`")
            }
            
            guard let newUntypedArray = originalUntypedArray as? [Model] else {
                fatalError("Unable to reconstruct `\([Model].self)` from `\(type(of: originalUntypedArray))`")
            }
            
            return originalTypedArray.diff(against: newUntypedArray)
        }
    }
    
    public static func == (lhs: ReusableCellSection, rhs: ReusableCellSection) -> Bool {
        return lhs.reuseIdentifier == rhs.reuseIdentifier
    }
    
    
    // MARK: TableViewSectionProvider
    
    public func reloadData() -> DiffResult {
        let optionalItemsBeforeReload = typeErasedItems
        typeErasedItems = retrieveTypeErasedItems()
        let optionalItemsAfterReload = typeErasedItems
        
        switch (optionalItemsBeforeReload, optionalItemsAfterReload) {
        // Placeholder -> Placeholder
        case (.none, .none):
            return DiffResult(unchangedIndicies: [0])
            
        // Placeholder -> Content
        case (.none, .some(let itemsAfterReload)):
            return DiffResult(deletedIndicies: [0], insertedIndicies: Array(itemsAfterReload.indices))
            
        // Content -> Placeholder
        case (.some(let itemsBeforeReload), .none):
            return DiffResult(deletedIndicies: Array(itemsBeforeReload.indices), insertedIndicies: [0])
            
        // Content -> Content
        case (.some(let itemsBeforeReload), .some(let itemsAfterReload)):
            return diffItemArrays(itemsBeforeReload, itemsAfterReload)
        }
    }
    
    public var numberOfRows: Int {
        return max(1, typeErasedItems?.count ?? 0)
    }
    
    public func createCell(for indexPath: IndexPath, in tableView: UITableView) -> UITableViewCell {
        guard let typeErasedItems = typeErasedItems,
            !typeErasedItems.isEmpty else
        {
            return placeholderCell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath)
        typeErasedDecoratorBlock(typeErasedItems[indexPath.row], cell)
        return cell
    }
    
    public func cell(for indexPath: IndexPath, in tableView: UITableView) -> UITableViewCell {
        return tableView.cellForRow(at: indexPath) ?? createCell(for: indexPath, in: tableView)
    }
    
    public func additionalSectionConfiguration(for tableView: UITableView) {
        tableView.register(dequeableCellType, forCellReuseIdentifier: reuseIdentifier)
    }
    
}
