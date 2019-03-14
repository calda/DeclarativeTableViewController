//
//  GroupAPI.swift
//  Demo App
//
//  Created by Cal Stephens on 3/14/19.
//  Copyright © 2019 Cal Stephens. All rights reserved.
//

import Foundation

enum SocialAPI {
    
    private static var hasFetchedUsersBefore = false
    
    static func fetchUsers(in group: Group, completionHandler: @escaping ([User]) -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7, execute: {
            
            // simulate as if somebody joined the group between the first load and the following refresh
            if !SocialAPI.hasFetchedUsersBefore {
                completionHandler(Array(sampleUsers[1...]))
            } else {
                completionHandler(sampleUsers)
            }
            
            SocialAPI.hasFetchedUsersBefore = true
        })
    }
    
    public static var sampleGroup = Group(
        memberCount: sampleUsers.count,
        image: #imageLiteral(resourceName: "itunes"),
        name: "Music Lovers",
        description: "We love music of all kinds.",
        location: "The World")
    
    private static var sampleUsers = [
        User(profilePicture: #imageLiteral(resourceName: "Rahul"),
            name: "Rahul Malviya",
            location: "Istanbul"),
    
        User(profilePicture: #imageLiteral(resourceName: "Justine"),
             name: "Justine Marshall",
             location: "Kingston"),
        
        User(profilePicture: #imageLiteral(resourceName: "Olivia"),
             name: "Olivia Eklund",
             location: "Shanghai"),
        
        User(profilePicture: #imageLiteral(resourceName: "Roman"),
             name: "Roman Kutepov",
             location: "Boston"),
        
        User(profilePicture: #imageLiteral(resourceName: "Uzoma"),
             name: "Uzoma Buchi",
             location: "Seattle"),
        
        User(profilePicture: #imageLiteral(resourceName: "Carlota"),
             name: "Carlota Monteiro",
             location: "Perth")]
    
}
