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
    var viewGroupAsAdministrator: Bool = true
    
    init() {
        super.init(tableStyle: .grouped, refreshStyle: .pullToRefresh)
        title = "Group"
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: Setup
    
    override func setupCells() {
        
        // TODO: make it possible to switch between admin and regular member
        
        let viewingAsAdministrator = { [unowned self] in
            return self.viewGroupAsAdministrator
        }
        
        let viewingAsRegularMember = { [unowned self] in
            return !self.viewGroupAsAdministrator
        }
        
        
        sections = [
            Section(cells: [
                ProfilePreviewCell(group),
                
                ConditionalCell(
                    ButtonCell(title: "Edit Group", handler: { return }),
                    displayIf: viewingAsAdministrator)]),
            
            Section(cells: [
                ConditionalCell(
                    ButtonCell(title: "Invite Your Friends", handler: { return }),
                    displayIf: viewingAsAdministrator),
                
                ConditionalCell(
                    ButtonCell(title: "Delete Group", style: .destructive, handler: { return }),
                    displayIf: viewingAsAdministrator),
                
                ConditionalCell(
                    ButtonCell(title: "Leave Group", style: .destructive, handler: { return }),
                    displayIf: viewingAsRegularMember)]),
            
            ReusableCellSection(
                name: "Members",
                cellType: ProfilePreviewCell.self,
                items: { [unowned self] in self.groupMembers }),
            
        ]
        
        
        SocialAPI.fetchUsers(in: group) { users in
            self.groupMembers = users
            self.reloadData()
        }
    }
    
}
