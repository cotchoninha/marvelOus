//
//  FavoritesTableViewCell.swift
//  MarvelOus
//
//  Created by Marcela Ceneviva Auslenter on 21/08/2018.
//  Copyright © 2018 Marcela Ceneviva Auslenter. All rights reserved.
//

import Foundation
import UIKit

class FavouritesTableViewCell: UITableViewCell {
    
    @IBOutlet weak var characterPhoto: UIImageView!
    
    @IBOutlet weak var characterName: UILabel!
    
    @IBOutlet weak var favoriteButton: UIButton!
    
    var buttonAction: (() -> Void)?
    
    @IBAction func defavoriteCharacter(_ sender: Any) {
        self.buttonAction?()
    }
}
