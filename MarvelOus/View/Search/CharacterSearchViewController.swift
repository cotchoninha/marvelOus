//
//  SearchCharacterView.swift
//  MarvelOus
//
//  Created by Marcela Ceneviva Auslenter on 21/08/2018.
//  Copyright © 2018 Marcela Ceneviva Auslenter. All rights reserved.
//

import UIKit
import CoreData

class CharacterSearchViewController: UIViewController {
    
    var offSet = 0
    var arrayofChars = [APIMarvelCharacter]()
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
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
    
    @objc fileprivate func makeRequest(offSetBy: Int) {
        MarvelRequestManager.sharedInstance().getAllMarvelCharacters(offSet: offSetBy) { (success, arrayOfCharacters, totalNumberOfCharacters, error) in
            if success{
                if let arrayOfCharacters = arrayOfCharacters{
                    self.arrayofChars = arrayOfCharacters
                }
                DispatchQueue.main.async {
                    self.collectionView.reloadData()
                    self.activityIndicator.hidesWhenStopped = true
                    self.activityIndicator.stopAnimating()
                }
                if let totalNumberOfCharacters = totalNumberOfCharacters{
                    if self.offSet <= totalNumberOfCharacters{
                        self.offSet += 50
                    }
                }
            }else{
                print("Couldn't get Marvel's Characters: \(error?.localizedDescription)")
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchCharactersInDB()
        activityIndicator.startAnimating()
        makeRequest(offSetBy: offSet)
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(self.refresh), for: UIControlEvents.valueChanged)
        collectionView.refreshControl  = refreshControl
    }
    
    @objc func refresh(){
        arrayofChars.removeAll()
        collectionView.reloadData()
        makeRequest(offSetBy: offSet)
        collectionView.reloadData()
        collectionView.refreshControl?.endRefreshing()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //when returned from DetailVC needs to check again what is in the DB to design UI with correct heart colours
        fetchCharactersInDB()
        collectionView.reloadData()
        
    }
}

extension CharacterSearchViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arrayofChars.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "searchCell", for: indexPath) as! CharacterSearchCellItem
        
        //set button red or black depending on be already saved on DB
        let myImage = UIImage(named: "heart")
        cell.favoriteButton.setImage(myImage?.withRenderingMode(.alwaysTemplate), for: .normal)
        if let objects = fetchedRC.fetchedObjects{
            if objects.contains(where: {$0.id == arrayofChars[indexPath.item].id}){
                cell.favoriteButton.tintColor = .red
            }else{
                cell.favoriteButton.tintColor = .black
            }
        }
        
        cell.characterName.text = arrayofChars[indexPath.item].name
        if arrayofChars[indexPath.item].characterPhoto == nil{
            cell.characterPhoto.image = #imageLiteral(resourceName: "placeholder")
            cell.activityIndicatorCell.startAnimating()
            let urlString = "\(self.arrayofChars[indexPath.item].path).\(self.arrayofChars[indexPath.item].imgExtension)"
            MarvelRequestManager.sharedInstance().downloadImage(url: urlString) { (imageData, error) in
                guard error == nil else{
                    print("MARCELA couldn't download data: \(error)")
                    return
                }
                if let imageDataDownloaded = imageData{
                    self.arrayofChars[indexPath.item].characterPhoto = imageDataDownloaded
                }
                //chamar as linhas abaixo quando for para comecar o activity indicator pra cada célula antes das imagens serem downlodadas
                DispatchQueue.main.async {
                    collectionView.reloadItems(at: [indexPath])
                }
            }
        }else{
            cell.activityIndicatorCell.stopAnimating()
            cell.activityIndicatorCell.hidesWhenStopped = true
            if let photoChar = self.arrayofChars[indexPath.item].characterPhoto{
                cell.characterPhoto.image = UIImage(data: photoChar)
            }
        }
        cell.buttonAction = {
            if cell.favoriteButton.tintColor == .red{
                cell.favoriteButton.tintColor = .black
                //delete from DB
                if let objectsInDB = self.fetchedRC.fetchedObjects{
                    for itemId in objectsInDB{
                        if itemId.id == self.arrayofChars[indexPath.item].id{
                            DataBaseController.getContext().delete(itemId)
                        }
                    }
                }
                DataBaseController.saveContext()
                self.fetchCharactersInDB()
            }else{
                cell.favoriteButton.tintColor = .red
                //add to DB
                let character = Character(context: DataBaseController.getContext())
                character.id = Int32(self.arrayofChars[indexPath.item].id)
                character.charDescription = self.arrayofChars[indexPath.item].description
                character.name = self.arrayofChars[indexPath.item].name
                character.photoImage = self.arrayofChars[indexPath.item].characterPhoto
                DataBaseController.saveContext()
                self.fetchCharactersInDB()
            }
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let controller = storyboard?.instantiateViewController(withIdentifier: "detailViewController") as! CharacterDetailsViewController
        let selectedCharacter = self.arrayofChars[indexPath.item]
        let isSelectedFavourite = checkIfObjectItsFavourite(networkCharacter: selectedCharacter)
        let favoriteCharacterDetailed = UIMarvelCharacter(characterId: Int(selectedCharacter.id), characterName: selectedCharacter.name, characterPhoto: selectedCharacter.characterPhoto!, characterDescription: selectedCharacter.description, isFavorite: isSelectedFavourite)
        //TODO: verify is char is favorite
        controller.marvelCharacter = favoriteCharacterDetailed
        self.present(controller, animated: true, completion: nil)
    }
    
    func checkIfObjectItsFavourite(networkCharacter: APIMarvelCharacter) -> Bool{
        var isFavourite = true
        if let objectsInDB = fetchedRC.fetchedObjects{
            for itemId in objectsInDB{
                if itemId.id == Int32(networkCharacter.id){
                    isFavourite = true
                    return isFavourite
                }else{
                    isFavourite = false
                }
            }
        }
        return isFavourite
    }
}

extension CharacterSearchViewController: UISearchBarDelegate{
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        activityIndicator.startAnimating()
        guard let query = searchBar.text else {
            return
        }
        MarvelRequestManager.sharedInstance().getMarvelCharactersWithName(nameStartsWith: query) { (success, listOfSearchedCharacters, error) in
            if success{
                if let searchedCharacters = listOfSearchedCharacters{
                    self.arrayofChars = searchedCharacters
                }
                DispatchQueue.main.async {
                    searchBar.resignFirstResponder()
                    self.collectionView.reloadData()
                    self.activityIndicator.hidesWhenStopped = true
                    self.activityIndicator.stopAnimating()
                }
            }else{
                print("Couldn't get Marvel's Characters: \(error?.localizedDescription)")
            }
        }
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = nil
        searchBar.resignFirstResponder()
    }
}
