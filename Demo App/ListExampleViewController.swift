//
//  ListExampleViewController.swift
//  Demo App
//
//  Created by Cal Stephens on 3/13/19.
//  Copyright © 2019 Cal Stephens. All rights reserved.
//


// MARK: - ListExampleViewController

class ListExampleViewController: DeclarativeTableViewController {
    
    var playlist: Playlist!
    
    init() {
        super.init(style: .plain)
        display(.allSongs, animated: false)
        configureBarButtonItems()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: Setup
    
    override func setupCells() {
        sections = [
            ReusableCellSection(
                cellType: SongCell.self,
                items: { [unowned self] in self.playlist.songs })
        ]
    }
    
    private func display(_ playlist: Playlist, animated: Bool) {
        self.playlist = playlist
        self.title = playlist.name
        reloadData(animated: animated)
    }
    
    
    // MARK: User Interaction
    
    private func configureBarButtonItems() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Playlists", style: .plain,
            target: self, action: #selector(selectPlaylist(_:)))
    }
    
    @objc private func selectPlaylist(_ sender: UIBarButtonItem) {
        let alertController = UIAlertController(title: "Select Playlist", message: nil, preferredStyle: .actionSheet)
        
        for playlist in Playlist.all {
            alertController.addAction(UIAlertAction(
                title: (self.playlist == playlist) ? "✓ \(playlist.name)" : playlist.name,
                style: .default,
                handler: { _ in
                    self.display(playlist, animated: true)
            }))
        }
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alertController.popoverPresentationController?.barButtonItem = sender
        present(alertController, animated: true)
    }
    
}
