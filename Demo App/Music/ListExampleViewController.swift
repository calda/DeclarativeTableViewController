//
//  ListExampleViewController.swift
//  Demo App
//
//  Created by Cal Stephens on 3/13/19.
//  Copyright © 2019 Cal Stephens. All rights reserved.
//

import AVKit


// MARK: - ListExampleViewController

class ListExampleViewController: DeclarativeTableViewController {
    
    var playlist: Playlist = .allSongs
    private var currentSong: Song?
    
    init() {
        super.init(tableStyle: .plain, refreshStyle: .none)
        configureNavigationItem()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: Setup
    
    override func setupCells() {
        sections = [
            ReusableCellSection(
                cellType: SongCell.self,
                items: { [unowned self] in
                    self.playlist.songs.lazy.map { song in
                        SongCell.ViewModel(
                            song: song,
                            isCurrentlyPlaying: self.currentSong == song)
                    }
                },
                selectionHandler: userSelected(_:in:))
        ]
    }
    
    
    // MARK: Song Selection and Playback
    
    private var currentPlayer: AVAudioPlayer?
    
    func userSelected(_ model: SongCell.ViewModel, in cell: SongCell) {
        try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [])
        
        currentPlayer?.stop()
        
        if model.song == currentSong {
            currentSong = nil
        } else {
            currentSong = model.song
            currentPlayer = try? AVAudioPlayer(contentsOf: model.song.audioFileUrl)
            currentPlayer?.play()
        }
        
        reloadData(animated: false)
    }
    
    
    // MARK: Playlist Selection
    
    private func configureNavigationItem() {
        navigationItem.title = playlist.name
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Playlists",
            style: .plain,
            target: self,
            action: #selector(selectPlaylist(_:)))
    }
    
    @objc private func selectPlaylist(_ sender: UIBarButtonItem) {
        let alertController = UIAlertController(title: "Select Playlist", message: nil, preferredStyle: .actionSheet)
        
        for playlist in Playlist.all {
            alertController.addAction(UIAlertAction(
                title: (self.playlist == playlist) ? "✓ \(playlist.name)" : playlist.name,
                style: .default,
                handler: { _ in
                    self.playlist = playlist
                    self.configureNavigationItem()
                    self.reloadData()
            }))
        }
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alertController.popoverPresentationController?.barButtonItem = sender
        present(alertController, animated: true)
    }
    
}
