//
//  ProfileDisplayable.swift
//  Demo App
//
//  Created by Cal Stephens on 3/14/19.
//  Copyright © 2019 Cal Stephens. All rights reserved.
//

import UIKit


// MARK: - ProfileDisplayable

protocol ProfileDisplayable {
    var image: UIImage { get }
    var name: String { get }
    var subtitle: String? { get }
    var attributes: [Attribute] { get }
}

extension Group: ProfileDisplayable {
    
    var subtitle: String? {
        return description
    }
    
    var attributes: [Attribute] {
        return [.memberCount(memberCount), .location(location), .dateCreated(Date())]
    }
    
}

extension User: ProfileDisplayable {
    
    var image: UIImage {
        return profilePicture
    }
    
    var subtitle: String? {
        return nil
    }
    
    var attributes: [Attribute] {
        return [.location(location), .dateJoined(Date())]
    }
    
}
