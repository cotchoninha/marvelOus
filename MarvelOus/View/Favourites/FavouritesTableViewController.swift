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

class FavouritesTableViewController: UIViewController{
    
    //MARK: properties
    private var fetchedRC: NSFetchedResultsController<Character>!
    
    //MARK: IBOutlets
    @IBOutlet weak var tableView: UITableView!
    
    //MARK: Method for fetch results controller
    fileprivate func fetchCharactersInDB() {
        let request: NSFetchRequest<Character> = Character.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: #keyPath(Character.name), ascending: true)]
        do {
            fetchedRC = NSFetchedResultsController(fetchRequest: request, managedObjectContext: DataBaseController.getContext(), sectionNameKeyPath: nil, cacheName: nil)
            try fetchedRC.performFetch()
        } catch let error as NSError {
            UserAlertManager.showAlert(title: "Couldnt access the database. ", message: "It wasn't possible to acess your database. Please, try again.", buttonMessage: "Try again.", viewController: self)
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
    
    //MARK: UI preparation
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchCharactersInDB()
        tableView.reloadData()
    }
    
    //MARK: Method that will save user preference on Table view
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        UserDefaults.standard.set(viewController, forKey: "favoritesScreenPreference")
    }
}

extension FavouritesTableViewController: UITableViewDelegate, UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchedRC.fetchedObjects?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "tableCell", for: indexPath) as! FavouritesTableViewCell
        
        tableView.rowHeight = 130
        cell.characterPhoto.layer.cornerRadius = 25
        cell.characterPhoto.layer.masksToBounds = true
        
        let myImage = UIImage(named: "heart")
        cell.favoriteButton.setImage(myImage?.withRenderingMode(.alwaysTemplate), for: .normal)
        cell.favoriteButton.tintColor = .red
        
        let fetchedObject = fetchedRC.object(at: indexPath)
        cell.characterName.text = fetchedObject.name
        if let photoImage = fetchedObject.photoImage{
            cell.characterPhoto.image = UIImage(data: photoImage)
        }
        
        //COMMENT: determines what will be executed when favourite button is pressed
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
