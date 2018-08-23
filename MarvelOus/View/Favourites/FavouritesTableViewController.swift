//
//  FavoritesTableView.swift
//  MarvelOus
//
//  Created by Marcela Ceneviva Auslenter on 21/08/2018.
//  Copyright © 2018 Marcela Ceneviva Auslenter. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class FavouritesTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{
    
    private var fetchedRC: NSFetchedResultsController<Character>!
    
    @IBOutlet weak var tableView: UITableView!
    
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
        tableView.reloadData()
    }
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchedRC.fetchedObjects?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "tableCell", for: indexPath) as! FavouritesTableViewCell
        let myImage = UIImage(named: "heart")
        cell.favoriteButton.setImage(myImage?.withRenderingMode(.alwaysTemplate), for: .normal)
        cell.favoriteButton.tintColor = .red
        let fetchedObject = fetchedRC.object(at: indexPath)
        cell.characterName.text = fetchedObject.name
        if let photoImage = fetchedObject.photoImage{
            cell.characterPhoto.image = UIImage(data: photoImage)
        }
        
        cell.buttonAction = {
            if let index = tableView.indexPath(for: cell){
                let objectToDelete = self.fetchedRC.object(at: index)
                DataBaseController.getContext().delete(objectToDelete)
                DataBaseController.saveContext()
                self.fetchCharactersInDB()
                tableView.deleteRows(at: [index], with: .top)
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let controller = storyboard?.instantiateViewController(withIdentifier: "detailViewController") as! CharacterDetailsViewController
        let selectedCharacter = fetchedRC.object(at: indexPath)
        let favoriteCharacterDetailed = UIMarvelCharacter(characterId: Int(selectedCharacter.id), characterName: selectedCharacter.name!, characterPhoto: selectedCharacter.photoImage!, characterDescription: selectedCharacter.charDescription!, isFavorite: true)
        controller.marvelCharacter = favoriteCharacterDetailed
        self.present(controller, animated: true, completion: nil)
    }
    
    
}
