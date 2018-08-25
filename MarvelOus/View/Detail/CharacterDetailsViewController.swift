//
//  DetailCharacterView.swift
//  MarvelOus
//
//  Created by Marcela Ceneviva Auslenter on 21/08/2018.
//  Copyright © 2018 Marcela Ceneviva Auslenter. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class CharacterDetailsViewController: UIViewController {
    
    //MARK: properties
    var marvelCharacter: UIMarvelCharacter?
    private var fetchedRC: NSFetchedResultsController<Character>!
    
    //MARK: IBOutlets
    @IBOutlet weak var characterPhoto: UIImageView!
    @IBOutlet weak var characterName: UILabel!
    @IBOutlet weak var characterDescription: UILabel!
    @IBOutlet weak var favoriteButton: UIButton!
    
    //MARK: UI preparation
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //set rounded corners of photoImage
        characterPhoto.layer.cornerRadius = 7.0
        characterPhoto.clipsToBounds = true
        
        //COMMENT: set heart to be alwaysTemplate to change colour later in the code
        let myImage = UIImage(named: "heart")
        self.favoriteButton.setImage(myImage?.withRenderingMode(.alwaysTemplate), for: .normal)
        
        //COMMENT: set UI photo/name/description/favouriteButton
        if let marvelCharacter = self.marvelCharacter{
            characterPhoto.image = UIImage(data: marvelCharacter.characterPhoto)
            characterName.text = marvelCharacter.characterName
            if marvelCharacter.characterDescription.isEmpty{
                characterDescription.text = "There's no description for this Character."
            }else{
                characterDescription.text = marvelCharacter.characterDescription
            }
            fetchCharacterWithId(characterId: marvelCharacter.characterId)
            if marvelCharacter.isFavorite == false{
                self.favoriteButton.tintColor = .black
            }else{
                self.favoriteButton.tintColor = .red

            }
        }
    }
    
    //MARK: Method for fetch results controller
    fileprivate func fetchCharacterWithId(characterId: Int) {
        let request: NSFetchRequest<Character> = Character.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: #keyPath(Character.name), ascending: true)]
        request.predicate = NSPredicate(format: "id == %i", characterId)
        do {
            fetchedRC = NSFetchedResultsController(fetchRequest: request, managedObjectContext: DataBaseController.getContext(), sectionNameKeyPath: nil, cacheName: nil)
            try fetchedRC.performFetch()
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
    
    //MARK: Method for saving or deleting characters when back button is pressed
    @IBAction func backToTab(_ sender: Any) {
        if let fetchedObject = fetchedRC.fetchedObjects{
            if let marvelCharacter = self.marvelCharacter{
                if fetchedObject.isEmpty && marvelCharacter.isFavorite == true{
                    let character = Character(context: DataBaseController.getContext())
                    character.id = Int32(marvelCharacter.characterId)
                    character.charDescription = marvelCharacter.characterDescription
                    character.name = marvelCharacter.characterName
                    character.photoImage = marvelCharacter.characterPhoto
                }else if fetchedObject.isEmpty && marvelCharacter.isFavorite == false{
                    self.dismiss(animated: true, completion: nil)
                }else if !fetchedObject.isEmpty && marvelCharacter.isFavorite == true{
                    self.dismiss(animated: true, completion: nil)
                }else if !fetchedObject.isEmpty && marvelCharacter.isFavorite == false{
                    for character in fetchedObject {
                        DataBaseController.getContext().delete(character)
                    }
                }
            }
        }
        DataBaseController.saveContext()
        self.dismiss(animated: true, completion: nil)
    }
    
    //MARK: Method for setting the character to be favourite or not
    @IBAction func setFavourite(_ sender: Any) {
        if let marvelCharacter = self.marvelCharacter{
            if marvelCharacter.isFavorite{
                self.marvelCharacter?.isFavorite = false
                self.favoriteButton.tintColor = .black
            }else{
                self.marvelCharacter?.isFavorite = true
                self.favoriteButton.tintColor = .red
            }
        }
    }
    
}
