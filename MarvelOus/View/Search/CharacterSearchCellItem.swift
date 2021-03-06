//
//  CharacterSearchedCell.swift
//  MarvelOus
//
//  Created by Marcela Ceneviva Auslenter on 21/08/2018.
//  Copyright © 2018 Marcela Ceneviva Auslenter. All rights reserved.
//

import UIKit

class CharacterSearchCellItem: UICollectionViewCell{
    
    @IBOutlet weak var characterPhoto: UIImageView!
    
    @IBOutlet weak var characterName: UILabel!
    
    @IBOutlet weak var favoriteButton: UIButton!
    
    var buttonAction: (() -> Void)?
    
    @IBAction func setFavourite(_ sender: Any) {
        self.buttonAction?()
    }
    @IBOutlet weak var activityIndicatorCell: UIActivityIndicatorView!
    
}
