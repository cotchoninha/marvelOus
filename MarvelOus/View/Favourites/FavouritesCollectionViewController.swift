//
//  FavoritesCollectionView.swift
//  MarvelOus
//
//  Created by Marcela Ceneviva Auslenter on 21/08/2018.
//  Copyright © 2018 Marcela Ceneviva Auslenter. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class FavouritesCollectionViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    //TODO: not repeat favorite chars
    @IBOutlet weak var collectionView: UICollectionView!
    private var fetchedRC: NSFetchedResultsController<Character>!
    
    fileprivate func fetchCharactersInDB() {
        let request: NSFetchRequest<Character> = Character.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: #keyPath(Character.name), ascending: true)]
        do {
            fetchedRC = NSFetchedResultsController(fetchRequest: request, managedObjectContext: DataBaseController.getContext(), sectionNameKeyPath: nil, cacheName: nil)
            try fetchedRC.performFetch()
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchCharactersInDB()
        collectionView.reloadData()
    }
    

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return fetchedRC.fetchedObjects?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
         let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "collectionCell", for: indexPath) as! FavouritesCollectionViewCell
        let myImage = UIImage(named: "heart")
        cell.favoriteButton.setImage(myImage?.withRenderingMode(.alwaysTemplate), for: .normal)
        cell.favoriteButton.tintColor = .red
        let fetchedObject = fetchedRC.object(at: indexPath)
        
        cell.characterName.text = fetchedObject.name
        if let photoImage = fetchedObject.photoImage{
            cell.characterPhoto.image = UIImage(data: photoImage)
        }
        
        cell.buttonAction = {
            if let index = collectionView.indexPath(for: cell){
                let objectToDelete = self.fetchedRC.object(at: index)
                DataBaseController.getContext().delete(objectToDelete)
                DataBaseController.saveContext()
                self.fetchCharactersInDB()
                collectionView.deleteItems(at: [index])
            }
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let controller = storyboard?.instantiateViewController(withIdentifier: "detailViewController") as! CharacterDetailsViewController
        let selectedCharacter = fetchedRC.object(at: indexPath)
        let favoriteCharacterDetailed = UIMarvelCharacter(characterId: Int(selectedCharacter.id), characterName: selectedCharacter.name!, characterPhoto: selectedCharacter.photoImage!, characterDescription: selectedCharacter.charDescription!, isFavorite: true)
            controller.marvelCharacter = favoriteCharacterDetailed
        self.present(controller, animated: true, completion: nil)
    }
    
}