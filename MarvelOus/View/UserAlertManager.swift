//
//  UserAlertManager.swift
//  MarvelOus
//
//  Created by Marcela Ceneviva Auslenter on 25/08/2018.
//  Copyright © 2018 Marcela Ceneviva Auslenter. All rights reserved.
//

import Foundation
import UIKit

class UserAlertManager{
    
    class func showAlert(title: String, message: String, buttonMessage: String, viewController: UIViewController){
        // create the alert
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        
        // add an action (button)
        alert.addAction(UIAlertAction(title: buttonMessage, style: UIAlertActionStyle.default, handler: nil))
        
        // show the alert
        viewController.present(alert, animated: true, completion: nil)
    }
    
}
