//
//  SongsAPI.swift
//  Demo App
//
//  Created by Cal Stephens on 3/13/19.
//  Copyright © 2019 Cal Stephens. All rights reserved.
//

import UIKit


// MARK: Playlist

struct Playlist: Hashable {
    
    let name: String
    let songs: [Song]
    
    static let all = [Playlist.allSongs, .indie, .rock]
    
    static let indie = Playlist(
        name: "Indie",
        songs: [.bambi, .bunker, .eventually, .heathrow, .theMotherWeShare, .tryingToBeCool, .weMoveLikeTheOcean])
    
    static let rock = Playlist(
        name: "Classic Rock",
        songs: [.alone, .freeBird, .inTheAirTonight, .rocknMe, .sweetChildOfMine])
    
    static let allSongs = Playlist(
        name: "All Songs",
        songs: (Playlist.indie.songs + Playlist.rock.songs).sorted(by: { $0.title < $1.title }))
    
}


// MARK: Song

struct Song: Hashable {
    
    let title: String
    let artist: String
    let albumArt: UIImage
    
    var audioFileUrl: URL {
        return Bundle.main.url(forResource: title, withExtension: "m4a")!
    }
    
    fileprivate static let bambi = Song(title: "Bambi", artist: "Hippo Campus", albumArt: #imageLiteral(resourceName: "Bambi"))
    fileprivate static let bunker = Song(title: "Bunker", artist: "Balthazar", albumArt: #imageLiteral(resourceName: "Bunker"))
    fileprivate static let eventually = Song(title: "Eventually", artist: "Tame Impala", albumArt: #imageLiteral(resourceName: "Eventually"))
    fileprivate static let heathrow = Song(title: "Heathrow", artist: "Catfish and the Bottlemen", albumArt: #imageLiteral(resourceName: "Heathrow"))
    fileprivate static let theMotherWeShare = Song(title: "The Mother We Share", artist: "CHVRCHES", albumArt: #imageLiteral(resourceName: "The Mother We Share"))
    fileprivate static let tryingToBeCool = Song(title: "Trying to Be Cool", artist: "Phoenix", albumArt: #imageLiteral(resourceName: "Trying to Be Cool"))
    fileprivate static let weMoveLikeTheOcean = Song(title: "We Move Like The Ocean", artist: "Bad Suns", albumArt: #imageLiteral(resourceName: "We Move Like The Ocean"))
    
    fileprivate static let alone = Song(title: "Alone", artist: "Heart", albumArt: #imageLiteral(resourceName: "Alone"))
    fileprivate static let freeBird = Song(title: "Free Bird", artist: "Lynyrd Skynyrd", albumArt: #imageLiteral(resourceName: "Free Bird"))
    fileprivate static let inTheAirTonight = Song(title: "In The Air Tonight", artist: "Phil Collins", albumArt: #imageLiteral(resourceName: "In The Air Tonight"))
    fileprivate static let rocknMe = Song(title: "Rock'n Me", artist: "Steve Miller Band", albumArt: #imageLiteral(resourceName: "Rock'n Me"))
    fileprivate static let sweetChildOfMine = Song(title: "Sweet Child O' Mine", artist: "Guns N' Roses", albumArt: #imageLiteral(resourceName: "Sweet Child O' Mine"))
    
}
