//
//  MultipleSectionExampleViewController.swift
//  Demo App
//
//  Created by Cal Stephens on 3/14/19.
//  Copyright © 2019 Cal Stephens. All rights reserved.
//

import UIKit

class MultipleSectionExampleViewController: DeclarativeTableViewController {
    
    let group = SocialAPI.sampleGroup
    var groupMembers: [User]?
    
    init() {
        super.init(tableStyle: .grouped, refreshStyle: .pullToRefresh)
        title = "Group"
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: Setup
    
    override func setupCells() {
        sections = [
            Section(cells: [ProfilePreviewCell(group)]),
            
            ReusableCellSection(
                name: "Members",
                cellType: ProfilePreviewCell.self,
                items: { [unowned self] in self.groupMembers })]
        
        SocialAPI.fetchUsers(in: group) { users in
            self.groupMembers = users
            self.reloadData()
        }
    }
    
    override func tableViewWillRebuild() {
        self.groupMembers = nil
    }
    
}
