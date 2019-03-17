//
//  Unerase.swift
//  DeclarativeTableViewController
//
//  Created by Cal Stephens on 3/17/19.
//  Copyright © 2019 Cal Stephens. All rights reserved.
//

func unerase<T>(_ typeErasedValue: Any, of type: T.Type) -> T {
    guard let unerasedValue = typeErasedValue as? T else {
        fatalError("Unable to reconstruct `\(T.self)` from `\(typeErasedValue)`")
    }
    
    return unerasedValue
}
