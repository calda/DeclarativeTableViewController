//
//  MultipleSectionExampleViewController.swift
//  Demo App
//
//  Created by Cal Stephens on 3/14/19.
//  Copyright © 2019 Cal Stephens. All rights reserved.
//

import UIKit

class MultipleSectionExampleViewController: DeclarativeTableViewController {
    
    var group = SocialAPI.sampleGroup
    var groupMembers: [User]?
    var viewGroupAsAdministrator = false
    
    init() {
        super.init(tableStyle: .grouped, refreshStyle: .pullToRefresh)
        configureNavigationItem()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: Setup
    
    override func setupCells() {
        
        let viewingAsAdministrator = { [unowned self] in
            return self.viewGroupAsAdministrator
        }
        
        let viewingAsRegularMember = { [unowned self] in
            return !self.viewGroupAsAdministrator
        }
        
        sections = [
            Section(cells: [
                AutoupdatingCell(
                    ProfilePreviewCell(group),
                    onReload: { [unowned self] in $0.display(self.group) })]),
            
            Section(cells: [
                ButtonCell(title: "Invite Your Friends", handler: { return }),
                
                ConditionalCell(
                    ButtonCell(title: "Leave Group", style: .destructive, handler: { return }),
                    displayIf: viewingAsRegularMember)]),
            
            Section(
                name: "Admin Tools",
                displayIf: viewingAsAdministrator,
                cells: [
                    ButtonCell(title: "Edit Group", handler: { return }),
                    
                    ButtonCell(title: "Delete Group", style: .destructive, handler: { return })]),
            
            ReusableCellSection(
                name: "Members",
                cellType: ProfilePreviewCell.self,
                items: { [unowned self] in self.groupMembers }),
        ]
        
        SocialAPI.fetchUsers(in: group) { updatedGroup, users in
            self.group = updatedGroup
            self.groupMembers = users
            self.reloadData()
        }
    }
    
    
    // MARK: User Status selection
    
    private func configureNavigationItem() {
        navigationItem.title = "Group"
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Viewing as Member",
            style: .plain,
            target: self,
            action: #selector(selectUserStatus(_:)))
    }
    
    @objc private func selectUserStatus(_ sender: UIBarButtonItem) {
        let alertController = UIAlertController(title: "View group as...", message: nil, preferredStyle: .actionSheet)
        
        alertController.addAction(UIAlertAction(
            title: (self.viewGroupAsAdministrator) ? "✓ Admin" : "Admin",
            style: .default,
            handler: { _ in
                self.navigationItem.rightBarButtonItem?.title = "Viewing as Admin"
                self.viewGroupAsAdministrator = true
                self.reloadData()
        }))
        
        alertController.addAction(UIAlertAction(
            title: (!self.viewGroupAsAdministrator) ? "✓ Member" : "Member",
            style: .default,
            handler: { _ in
                self.navigationItem.rightBarButtonItem?.title = "Viewing as Member"
                self.viewGroupAsAdministrator = false
                self.reloadData()
        }))
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alertController.popoverPresentationController?.barButtonItem = sender
        present(alertController, animated: true)
    }
    
}
