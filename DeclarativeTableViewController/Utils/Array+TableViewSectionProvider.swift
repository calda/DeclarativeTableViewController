//
//  Array+TableViewSectionProvider.swift
//  DeclarativeTableViewController
//
//  Created by Cal Stephens on 3/13/19.
//  Copyright © 2019 Cal Stephens. All rights reserved.
//

public extension Array where Element == TableViewSectionProvider {
    
    public func index<SectionType: TableViewSectionProvider & Equatable>(of section: SectionType) -> Int? {
        return firstIndex(where: { ($0 as? SectionType) == section })
    }
    
}
