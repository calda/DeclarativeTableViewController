//
//  ReusableCellSection.swift
//  DeclarativeTableViewController
//
//  Created by Cal Stephens on 3/13/19.
//  Copyright © 2019 Cal Stephens. All rights reserved.
//

import UIKit


// MARK: - ReusableCellSection

/// A homogeneous UITableView Section that dequeues reusable cells of a certain predefined type,
/// and populates them using an array of Model objects.
public class ReusableCellSection: TableViewSectionProvider, Equatable {
    
    public var name: String?
    public var shouldDisplaySection = true
    private let displayCondition: () -> Bool
    
    /// The cell to be shown if the current `[Model]?` is nil, or has 0 items.
    /// (i.e. before the content has finised loading)
    public var placeholderCell: UITableViewCell?
    
    private let dequeableCellType: AnyClass
    private let reuseIdentifier = UUID().uuidString
    
    // These are type-erased so that the Section doesn't have to be generic.
    // They're all set during the strongly-typed generic init implementations, though,
    // so this is perfectly safe.
    private var typeErasedItems: [Any]?
    private let retrieveTypeErasedItems: () -> [Any]?
    private let typeErasedDecorator: (Any, UITableViewCell) -> Void
    private let diffItemArrays: ([Any], [Any]) -> DiffResult
    private let typeErasedSelectionHandler: ((Any, UITableViewCell) -> Void)?
    
    /// Initializes a `ReusableCellSection` displaying instances of `CellType`.
    ///
    /// Since the `ReusableCell` protocol specifies the `ModelType` and provides a `decorate(_:)` method
    /// using that `ModelType`, this initialize automatically uses your `CellType.decorate(_:)` method.
    ///
    /// - Parameters:
    ///   - name: The name of the section, displayed by the Table View in `UITableView.Style.grouped`
    ///   - cellType: The `ReusableCell`-conforming `UITableViewCell` subclass to display
    ///   - displayIf: A closure specifying whether or not this section should be visible in the UITableView.
    ///   - placeholderCell: An optional `UITableViewCell` instance that is displayed if `items` is `nil`.
    ///        By default, a `LoadingIndicatorCell` instance.
    ///
    ///   - items: A closure that returns an optional array of `CellType.ModelType`.
    ///
    ///        The exact `ModelType` is specified by the `typealias ModelType = ...` in your `ReusableCell`
    ///        instance. This closure is called when the cell is initialized, and then subsequently called by the
    ///        `DeclarativeTableView` when you call `reloadData()`.
    ///
    ///        If this closure returns `nil`, the section will display the `placeholderCell`
    ///        (if it exists). This is especially useful for awaiting network requests.
    ///
    ///   - selectionHandler: A closure that is called when the user taps a cell in this section.
    ///
    /// - Note: If you're getting an error "Cannot convert value of type `() -> [CellType.ModelType]`
    ///      to expected argument type `() -> [_]?`", make sure that `SongCell.ModelType` conforms to `Hashable`.
    ///
    public convenience init<CellType: UITableViewCell>(
        name: String? = nil,
        cellType: CellType.Type,
        displayIf condition: @escaping () -> Bool = { true },
        placeholderCell: UITableViewCell? = LoadingIndicatorCell(),
        items: @escaping () -> [CellType.ModelType]?,
        selectionHandler: ((CellType.ModelType, CellType) -> Void)? = nil)
        where CellType: ReusableCell, CellType.ModelType: Hashable
    {
        self.init(
            name: name,
            cellType: cellType,
            displayIf: condition,
            placeholderCell: placeholderCell,
            items: items,
            decorator: { $1.display($0) },
            selectionHandler: selectionHandler)
    }
    
    /// Initializes a `ReusableCellSection` displaying instances of `CellType`.
    ///
    /// - Parameters:
    ///   - name: The name of the section, displayed by the Table View in `UITableView.Style.grouped`
    ///   - cellType: The `ReusableCell`-conforming `UITableViewCell` subclass to display
    ///   - displayIf: A closure specifying whether or not this section should be visible in the UITableView.
    ///   - placeholderCell: An optional `UITableViewCell` instance that is displayed if `items` is `nil`.
    ///        By default, a `LoadingIndicatorCell` instance.
    ///
    ///   - items: A closure that returns an optional array of `CellType.ModelType`.
    ///
    ///        The exact `ModelType` is specified by the `typealias ModelType = ...` in your `ReusableCell`
    ///        instance. This closure is called when the cell is initialized, and then subsequently called by the
    ///        `DeclarativeTableView` when you call `reloadData()`.
    ///
    ///        If this closure returns `nil`, the section will display the `placeholderCell`
    ///        (if it exists). This is especially useful for awaiting network requests.
    ///
    ///   - decorator: A closure that displays a given `ModelType` instance inside the `UITableViewCell` instance.
    ///
    ///        If your `UITableViewCell` subclass implements the `ReusableCell` protocol, this closure can be
    ///        automatically inferred (`CellType.decorate(_:)`).
    ///
    ///   - selectionHandler: A closure that is called when the user taps a cell in this section.
    ///
    /// - Note: If you're getting an error "Cannot convert value of type `() -> [ModelType]` to
    ///      expected argument type `() -> [_]?`", make sure that `SongCell.ModelType` conforms to `Hashable`.
    ///
    public init<CellType: UITableViewCell, ModelType: Hashable>(
        name: String? = nil,
        cellType: CellType.Type,
        displayIf condition: @escaping () -> Bool = { true },
        placeholderCell: UITableViewCell? = LoadingIndicatorCell(),
        items: @escaping () -> [ModelType]?,
        decorator: @escaping (ModelType, CellType) -> Void,
        selectionHandler: ((ModelType, CellType) -> Void)? = nil)
    {
        if cellType is PassthroughCell {
            // `PassthroughCell` is specifically designed to work with `Section`
            // (a table view section backed by an array of UITableViewCell instances)
            fatalError("`ReusableCellSection` does not support `PassthroughCell`.")
        }
        
        self.name = name
        self.displayCondition = condition
        self.dequeableCellType = cellType
        self.placeholderCell = placeholderCell
        
        // type-erase the closures
        self.retrieveTypeErasedItems = { return items() }
        self.typeErasedItems = retrieveTypeErasedItems()
        
        func unerase<T>(_ typeErasedValue: Any, of type: T.Type) -> T {
            guard let unerasedValue = typeErasedValue as? T else {
                fatalError("Unable to reconstruct `\(T.self)` from `\(typeErasedValue)`")
            }
            
            return unerasedValue
        }
        
        self.typeErasedDecorator = { untypedModel, untypedCell in
            let model = unerase(untypedModel, of: ModelType.self)
            let cell = unerase(untypedCell, of: CellType.self)
            decorator(model, cell)
        }
        
        if let selectionHandler = selectionHandler {
            self.typeErasedSelectionHandler = { untypedModel, untypedCell in
                let model = unerase(untypedModel, of: ModelType.self)
                let cell = unerase(untypedCell, of: CellType.self)
                selectionHandler(model, cell)
            }
        } else {
            self.typeErasedSelectionHandler = nil
        }
        
        self.diffItemArrays = { originalUntypedArray, newUntypedArray in
            let originalArray = unerase(originalUntypedArray, of: [ModelType].self)
            let newArray = unerase(newUntypedArray, of: [ModelType].self)
            return originalArray.diff(against: newArray)
        }
        
        reloadData()
    }
    
    public static func == (lhs: ReusableCellSection, rhs: ReusableCellSection) -> Bool {
        return lhs.reuseIdentifier == rhs.reuseIdentifier
    }
    
    
    // MARK: TableViewSectionProvider
    
    @discardableResult
    public func reloadData() -> DiffResult {
        let optionalItemsBeforeReload = typeErasedItems
        typeErasedItems = retrieveTypeErasedItems()
        let optionalItemsAfterReload = typeErasedItems
        
        shouldDisplaySection = displayCondition() && numberOfRows > 0
        
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
        if let numberOfModelItems = typeErasedItems?.count {
            return numberOfModelItems
        } else if placeholderCell != nil {
            return 1
        } else {
            return 0
        }
    }
    
    public func createCell(for indexPath: IndexPath, in tableView: UITableView) -> UITableViewCell {
        guard let typeErasedItems = typeErasedItems else {
            if let placeholderCell = placeholderCell {
                return placeholderCell
            } else {
                return UITableViewCell()
            }
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath)
        
        if typeErasedSelectionHandler == nil {
            cell.selectionStyle = .none
        }
        
        typeErasedDecorator(typeErasedItems[indexPath.row], cell)
        return cell
    }
    
    public func cell(for indexPath: IndexPath, in tableView: UITableView) -> UITableViewCell {
        return tableView.cellForRow(at: indexPath) ?? createCell(for: indexPath, in: tableView)
    }
    
    public func additionalSectionConfiguration(for tableView: UITableView) {
        tableView.register(dequeableCellType, forCellReuseIdentifier: reuseIdentifier)
    }
    
    public func cellIsSelectable(for indexPath: IndexPath, in tableView: UITableView) -> Bool {
        return typeErasedSelectionHandler != nil
    }
    
    public func handleSelection(for indexPath: IndexPath, in tableView: UITableView) {
        guard let typeErasedItems = typeErasedItems else {
            return
        }
        
        typeErasedSelectionHandler?(typeErasedItems[indexPath.item], cell(for: indexPath, in: tableView))
    }
    
}
