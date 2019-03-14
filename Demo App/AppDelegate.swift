//
//  AppDelegate.swift
//  Demo App
//
//  Created by Cal Stephens on 3/13/19.
//  Copyright © 2019 Cal Stephens. All rights reserved.
//

@_exported import UIKit
@_exported import DeclarativeTableViewController

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool
    {
        let window = UIWindow(frame: UIScreen.main.bounds)
        self.window = window
        
        let tabBarController = UITabBarController(nibName: nil, bundle: nil)
        
        tabBarController.viewControllers = [
            UINavigationController.displaying(
                ListExampleViewController(),
                tabBarItemTitle: "Music",
                image: #imageLiteral(resourceName: "Music Tab Bar Icon")),
            
            UINavigationController.displaying(
                MultipleSectionExampleViewController(),
                tabBarItemTitle: "Group",
                image: #imageLiteral(resourceName: "Group Tab Bar Icon"))]
        
        window.rootViewController = tabBarController
        window.makeKeyAndVisible()
        return true
    }

}


fileprivate extension UINavigationController {
    
    static func displaying(
        _ rootViewController: UIViewController,
        tabBarItemTitle: String,
        image: UIImage) -> UINavigationController
    {
        let navigationController = UINavigationController(rootViewController: rootViewController)
        navigationController.tabBarItem = UITabBarItem(title: tabBarItemTitle, image: image, selectedImage: image)
        navigationController.navigationBar.prefersLargeTitles = true
        return navigationController
    }
    
}

