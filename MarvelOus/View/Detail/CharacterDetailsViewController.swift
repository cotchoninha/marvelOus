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
    
    var marvelCharacter: UIMarvelCharacter?
    private var fetchedRC: NSFetchedResultsController<Character>!
    
    @IBOutlet weak var characterPhoto: UIImageView!
    @IBOutlet weak var characterName: UILabel!
    @IBOutlet weak var characterDescription: UILabel!
    @IBOutlet weak var favoriteButton: UIButton!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.favoriteButton.setBackgroundImage(#imageLiteral(resourceName: "heart"), for: .normal)
        if let marvelCharacter = self.marvelCharacter{
            characterPhoto.image = UIImage(data: marvelCharacter.characterPhoto)
            characterName.text = marvelCharacter.characterName
            characterDescription.text = marvelCharacter.characterDescription
            fetchCharacterWithId(characterId: marvelCharacter.characterId)
        }
    }
    
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
                    //deleta do banco de dados
                }
            }
        }
        DataBaseController.saveContext()
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func setFavourite(_ sender: Any) {
        if var marvelCharacter = self.marvelCharacter{
            if marvelCharacter.isFavorite{
                self.marvelCharacter?.isFavorite = false
                self.favoriteButton.setBackgroundImage(#imageLiteral(resourceName: "heart"), for: .normal)
            }else{
                self.marvelCharacter?.isFavorite = true
                self.favoriteButton.setBackgroundImage(#imageLiteral(resourceName: "redheart"), for: .normal)
            }
        }
    }
    
}
