//
//  FavoritesTabBarController.swift
//  MarvelOus
//
//  Created by Marcela Ceneviva Auslenter on 25/08/2018.
//  Copyright © 2018 Marcela Ceneviva Auslenter. All rights reserved.
//

import Foundation
import UIKit

class FavoritesTabBarController: UITabBarController, UITabBarControllerDelegate {
    
    let tabPreferenceKey = "favoritesScreenPreference"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        let tabTag = UserDefaults.standard.integer(forKey: tabPreferenceKey)
        switch tabTag {
        case 1:
            self.selectedIndex = 0
        case 2:
            self.selectedIndex = 1
        default:
            self.selectedIndex = 0
        }
    }
    
    //MARK: Method that will save user preference on Collection view
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
         UserDefaults.standard.set(item.tag, forKey: tabPreferenceKey)
    }
    
}
