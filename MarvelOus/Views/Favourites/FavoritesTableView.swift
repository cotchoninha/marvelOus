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
        print("MARCELA: FETCHEDREQUEST \(fetchedRC.fetchedObjects)")
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchedRC.fetchedObjects?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "tableCell", for: indexPath) as! FavoritesTableViewCell
        let fetchedObject = fetchedRC.object(at: indexPath)
        cell.characterName.text = fetchedObject.name
        if let photoImage = fetchedObject.photoImage{
            cell.characterPhoto.image = UIImage(data: photoImage)
        }
        cell.favoriteButton.tintColor = .blue
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let controller = storyboard?.instantiateViewController(withIdentifier: "detailViewController") as! CharacterDetailsViewController
        self.present(controller, animated: true, completion: nil)
    }
    
    
}
