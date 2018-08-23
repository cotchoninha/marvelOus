//
//  DetailCharacterView.swift
//  MarvelOus
//
//  Created by Marcela Ceneviva Auslenter on 21/08/2018.
//  Copyright © 2018 Marcela Ceneviva Auslenter. All rights reserved.
//

import Foundation
import UIKit

class CharacterDetailsViewController: UIViewController {
    
    var character: APIMarvelCharacter?
    var marvelCharacter: UIMarvelCharacter?
    var isFavourite = false
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let marvelCharacter = self.marvelCharacter{
            characterPhoto.image = UIImage(data: marvelCharacter.characterPhoto)
            characterName.text = marvelCharacter.characterName
            characterDescription.text = marvelCharacter.characterDescription
        }
    }
    
    @IBOutlet weak var characterPhoto: UIImageView!
    
    @IBOutlet weak var characterName: UILabel!
    
    @IBOutlet weak var characterDescription: UILabel!
    
    @IBOutlet weak var favoriteButton: UIButton!
    
    @IBAction func backToTab(_ sender: Any) {
        if isFavourite{
            let character = Character(context: DataBaseController.getContext())
            if let marvelCharacter = self.character{
                character.id = Int32(marvelCharacter.id)
                character.charDescription = marvelCharacter.description
                character.name = marvelCharacter.name
                character.photoImage = marvelCharacter.characterPhoto
                character.path = marvelCharacter.path
                character.imgExtension = marvelCharacter.imgExtension
            }
            DataBaseController.saveContext()
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func setFavourite(_ sender: Any) {
        if !isFavourite{
            isFavourite = true
        }else{
            isFavourite = false
        }
        
    }
    
}
