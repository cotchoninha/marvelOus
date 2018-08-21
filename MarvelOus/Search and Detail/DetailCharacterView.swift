//
//  DetailCharacterView.swift
//  MarvelOus
//
//  Created by Marcela Ceneviva Auslenter on 21/08/2018.
//  Copyright © 2018 Marcela Ceneviva Auslenter. All rights reserved.
//

import Foundation
import UIKit

class DetailCharacterView: UIViewController {
    
    @IBOutlet weak var characterPhoto: UIImageView!
    
    @IBOutlet weak var characterName: UILabel!
    
    @IBOutlet weak var characterDescription: UILabel!
    
    @IBOutlet weak var favoriteButton: UIButton!
    
    @IBAction func backToTab(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
}
