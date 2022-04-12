//
//  TabBarViewController.swift
//  Photo_Share
//
//  Created by Timothy Mazenge on 2/24/22.
//

import UIKit

class TabBarViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let email = UserDefaults.standard.string(forKey: "email"), let username = UserDefaults.standard.string(forKey: "username") else {
            return
        }
        
        let currentUser = User(username: username, email: email)

        let home = HomeViewController()
        let explore = ExploreViewController()
        let camera = CameraViewController()
        let profile = ProfileViewController(user: currentUser)
        
        let nav1 = UINavigationController(rootViewController: home)
        let nav2 = UINavigationController(rootViewController: explore)
        let nav3 = UINavigationController(rootViewController: camera)
        let nav4 = UINavigationController(rootViewController: profile)
        
        nav1.navigationBar.tintColor = .label
        nav2.navigationBar.tintColor = .label
        nav3.navigationBar.tintColor = .label
        nav4.navigationBar.tintColor = .label
        
        nav1.tabBarItem = UITabBarItem(title: "Home", image: UIImage(systemName: "house"), tag: 1)
        nav2.tabBarItem = UITabBarItem(title: "Explore", image: UIImage(systemName: "safari"), tag: 1)
        nav3.tabBarItem = UITabBarItem(title: "Post", image: UIImage(systemName: "camera"), tag: 1)
        nav4.tabBarItem = UITabBarItem(title: "Profile", image: UIImage(systemName: "person.circle"), tag: 1)
        self.setViewControllers([nav1, nav2, nav3, nav4], animated: false)
    }
    

  

}
