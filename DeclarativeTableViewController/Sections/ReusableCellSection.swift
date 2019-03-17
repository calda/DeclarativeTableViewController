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
    // so this is reasonably safe.
    private struct Items {
        let wrappedItems: Any
        
        init(_ wrapped: Any) {
            wrappedItems = wrapped
        }
    }
    
    private struct Item {
        let wrappedItem: Any
        
        init(_ wrapped: Any) {
            wrappedItem = wrapped
        }
    }
    
    private var typeErasedItems: Items?
    private let retrieveTypeErasedItems: () -> Items?
    private let itemCount: (Items?) -> Int?
    private let itemAtIndex: (Items?, Int) -> Item?
    
    private let typeErasedDecorator: (Item, UITableViewCell) -> Void
    private let diffItemArrays: (Items, Items) -> DiffResult
    private let typeErasedSelectionHandler: ((Item, UITableViewCell) -> Void)?
    
    private var estimatedCellHeight = UITableView.automaticDimension
    private var heightForCell: (UITableViewCell) -> CGFloat? = { _ in UITableView.automaticDimension }
    
    
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
    ///   - items: A closure that returns an optional collection of `CellType.ModelType`.
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
    public convenience init<CellType, CollectionType>(
        name: String? = nil,
        cellType: CellType.Type,
        displayIf condition: @escaping () -> Bool = { true },
        placeholderCell: UITableViewCell? = LoadingIndicatorCell(),
        items: @escaping () -> CollectionType?,
        selectionHandler: ((CellType.ModelType, CellType) -> Void)? = nil)
        where CellType: UITableViewCell,
              CellType: ReusableCell,
              CellType.ModelType: Hashable,
              CollectionType: RandomAccessCollection,
              CollectionType.Element == CellType.ModelType,
              CollectionType.Index == Int
    {
        self.init(
            name: name,
            cellType: cellType,
            displayIf: condition,
            placeholderCell: placeholderCell,
            items: items,
            decorator: { $1.display($0) },
            selectionHandler: selectionHandler)
        
        estimatedCellHeight = CellType.estimatedHeight
        
        heightForCell = { untypedCell in
            guard let typedCell = untypedCell as? CellType else {
                return nil
            }
            
            return typedCell.height
        }
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
    ///   - items: A closure that returns an optional collection of `CellType.ModelType`.
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
    public init<CellType, ModelType, CollectionType>(
        name: String? = nil,
        cellType: CellType.Type,
        displayIf condition: @escaping () -> Bool = { true },
        placeholderCell: UITableViewCell? = LoadingIndicatorCell(),
        items: @escaping () -> CollectionType?,
        decorator: @escaping (ModelType, CellType) -> Void,
        selectionHandler: ((ModelType, CellType) -> Void)? = nil)
        where CellType: UITableViewCell,
              ModelType: Hashable,
              CollectionType: RandomAccessCollection,
              CollectionType.Element == ModelType,
              CollectionType.Index == Int
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
        
        // type-erase the closures for storage in this non-generic instance
        self.retrieveTypeErasedItems = {
            guard let items = items() else {
                return nil
            }
            
            return Items(items)
        }
        
        self.itemCount = { typeErasedItems in
            guard let typeErasedItems = typeErasedItems else { return nil }
            let typedItems = unerase(typeErasedItems.wrappedItems, of: CollectionType.self)
            return typedItems.count
        }
        
        self.itemAtIndex = { typeErasedItems, index in
            guard let typeErasedItems = typeErasedItems else { return nil }
            let typedItems = unerase(typeErasedItems.wrappedItems, of: CollectionType.self)
            return Item(typedItems[index])
        }
        
        self.typeErasedDecorator = { untypedModel, untypedCell in
            let model = unerase(untypedModel.wrappedItem, of: ModelType.self)
            let cell = unerase(untypedCell, of: CellType.self)
            decorator(model, cell)
        }
        
        if let selectionHandler = selectionHandler {
            self.typeErasedSelectionHandler = { untypedModel, untypedCell in
                let model = unerase(untypedModel.wrappedItem, of: ModelType.self)
                let cell = unerase(untypedCell, of: CellType.self)
                selectionHandler(model, cell)
            }
        } else {
            self.typeErasedSelectionHandler = nil
        }
        
        self.diffItemArrays = { originalUntypedArray, newUntypedArray in
            let originalArray = unerase(originalUntypedArray.wrappedItems, of: CollectionType.self)
            let newArray = unerase(newUntypedArray.wrappedItems, of: CollectionType.self)
            return originalArray.diff(against: newArray)
        }
    }
    
    public static func == (lhs: ReusableCellSection, rhs: ReusableCellSection) -> Bool {
        return lhs.reuseIdentifier == rhs.reuseIdentifier
    }
    
    
    // MARK: TableViewSectionProvider
    
    @discardableResult
    public func reloadData() -> DiffResult {
        
        func currentItems() -> (collection: Items, count: Int)? {
            guard let items = self.typeErasedItems,
                let count = self.itemCount(typeErasedItems) else
            {
                return nil
            }
            
            return (items, count)
        }
        
        let optionalItemsBeforeReload = currentItems()
        typeErasedItems = retrieveTypeErasedItems()
        let optionalItemsAfterReload = currentItems()
        
        shouldDisplaySection = displayCondition() && numberOfRows > 0
        
        switch (optionalItemsBeforeReload, optionalItemsAfterReload) {
        // Placeholder -> Placeholder
        case (.none, .none):
            return DiffResult(unchangedIndicies: [0])
            
        // Placeholder -> Content
        case (.none, .some(let itemsAfterReload)):
            return DiffResult(deletedIndicies: [0], insertedIndicies: Array(0 ..< itemsAfterReload.count))
            
        // Content -> Placeholder
        case (.some(let itemsBeforeReload), .none):
            return DiffResult(deletedIndicies: Array(0 ..< itemsBeforeReload.count), insertedIndicies: [0])
            
        // Content -> Content
        case (.some(let itemsBeforeReload), .some(let itemsAfterReload)):
            return diffItemArrays(itemsBeforeReload.collection, itemsAfterReload.collection)
        }
    }
    
    public var numberOfRows: Int {
        if let numberOfModelItems = itemCount(typeErasedItems) {
            return numberOfModelItems
        } else if placeholderCell != nil {
            return 1
        } else {
            return 0
        }
    }
    
    public func createCell(for indexPath: IndexPath, in tableView: UITableView) -> UITableViewCell {
        guard let itemAtIndex = itemAtIndex(typeErasedItems, indexPath.row) else {
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
        
        typeErasedDecorator(itemAtIndex, cell)
        return cell
    }
    
    public func cell(for indexPath: IndexPath, in tableView: UITableView) -> UITableViewCell {
        return tableView.cellForRow(at: indexPath) ?? createCell(for: indexPath, in: tableView)
    }
    
    public func additionalSectionConfiguration(for tableView: UITableView) {
        tableView.register(dequeableCellType, forCellReuseIdentifier: reuseIdentifier)
    }
    
    public func estimatedHeight(for indexPath: IndexPath, in tableView: UITableView) -> CGFloat {
        if itemCount(typeErasedItems) == nil {
            return UITableView.automaticDimension
        }
        
        return estimatedCellHeight
    }
    
    public func height(for indexPath: IndexPath, in tableView: UITableView) -> CGFloat {
        let cell = self.cell(for: indexPath, in: tableView)
        return heightForCell(cell) ?? UITableView.automaticDimension
    }
    
    public func cellIsSelectable(for indexPath: IndexPath, in tableView: UITableView) -> Bool {
        return typeErasedSelectionHandler != nil
    }
    
    public func handleSelection(for indexPath: IndexPath, in tableView: UITableView) {
        guard let itemAtIndex = itemAtIndex(typeErasedItems, indexPath.row) else {
            return
        }
        
        typeErasedSelectionHandler?(itemAtIndex, cell(for: indexPath, in: tableView))
    }
    
    
    
}
