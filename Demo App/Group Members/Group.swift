//
//  Group.swift
//  Demo App
//
//  Created by Cal Stephens on 3/14/19.
//  Copyright © 2019 Cal Stephens. All rights reserved.
//

import UIKit


// MARK: - Group

public struct Group: Hashable {
    
    public var memberCount: Int
    public var image: UIImage
    public var name: String
    public var description: String
    public var location: String
    
}

// MARK: - User

public struct User: Hashable {
    
    public var profilePicture: UIImage
    public var name: String
    public var location: String
    
}
