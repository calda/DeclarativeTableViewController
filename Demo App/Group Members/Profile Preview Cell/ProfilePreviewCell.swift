//
//  ProfilePreviewCell.swift
//  Window
//
//  Created by Cal Stephens on 3/2/19.
//  Copyright © 2019 Cal Stephens. All rights reserved.
//

import UIKit
import DeclarativeTableViewController


// MARK: - Preview Cell

class ProfilePreviewCell: UITableViewCell, ReusableCell {
    
    
    // MARK: ReusableCell
    
    typealias ModelType = User
    
    func display(_ profile: User) {
        profileView.display(profile)
    }
    
    func display(_ profileDisplayable: ProfileDisplayable) {
        profileView.display(profileDisplayable)
    }
    
    
    // MARK: Initialization
    
    let profileView = ProfileView()
    
    init(_ profile: ProfileDisplayable? = nil) {
        super.init(style: .default, reuseIdentifier: nil)
        
        setupCell()
        
        if let profile = profile {
            display(profile)
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupCell()
    }
    
    func setupCell() {
        contentView.addSubviewAndConstrainToEqualSize(profileView,
            with: UIEdgeInsets(top: 16, left: 20, bottom: 16, right: 20))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
