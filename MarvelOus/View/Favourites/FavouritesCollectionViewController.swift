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

class FavouritesCollectionViewController: UIViewController, UITabBarControllerDelegate {
    
    //MARK: properties
    private var fetchedRC: NSFetchedResultsController<Character>!
    
    //MARK: IBOutlets
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    @IBOutlet weak var tabBarGrid: UITabBarItem!
    
    //MARK: Method for fetch results controller
    fileprivate func fetchCharactersInDB() {
        let request: NSFetchRequest<Character> = Character.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: #keyPath(Character.name), ascending: true)]
        do {
            fetchedRC = NSFetchedResultsController(fetchRequest: request, managedObjectContext: DataBaseController.getContext(), sectionNameKeyPath: nil, cacheName: nil)
            try fetchedRC.performFetch()
        } catch let error as NSError {
            UserAlertManager.showAlert(title: "Couldn't access the database. ", message: "It wasn't possible to acess your database. Please, try again.", buttonMessage: "Try again.", viewController: self)
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }

    //MARK: UI preparation

    override func viewDidLoad() {
        super.viewDidLoad()
        //COMMENT: Collection Layout
        let width = (view.frame.size.width - 20) / 3
        flowLayout.itemSize = CGSize(width: width, height: width*1.5)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchCharactersInDB()
        collectionView.reloadData()
    }
    
}

extension FavouritesCollectionViewController: UICollectionViewDelegate, UICollectionViewDataSource{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return fetchedRC.fetchedObjects?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
         let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "collectionCell", for: indexPath) as! FavouritesCollectionViewCell
        
        cell.characterPhoto.layer.cornerRadius = 7.0
        cell.characterPhoto.clipsToBounds = true

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

