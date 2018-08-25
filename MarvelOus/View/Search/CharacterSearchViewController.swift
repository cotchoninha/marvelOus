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
    
    var isOnSearchMode = false
    var offSet = 0
    var arrayofChars = [APIMarvelCharacter]()
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    private var fetchedRC: NSFetchedResultsController<Character>!
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    
    
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
                    for item in arrayOfCharacters{
                        self.arrayofChars.append(item)
                    }
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
        self.isOnSearchMode = false
        self.offSet = 0
        fetchCharactersInDB()
        activityIndicator.startAnimating()
        makeRequest(offSetBy: offSet)
        
        //COMMENT: Collection Layout
//        let width = (view.frame.size.width - 10) / 2
//        let height = (view.frame.size.height - searchBar.frame.height - 10)/2
//        flowLayout.itemSize = CGSize(width: width, height: height)
        let width = (view.frame.size.width - 30) / 4
        let height = (view.frame.size.height) - 30/4
        flowLayout.itemSize = CGSize(width: width, height: height)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //when returned from DetailVC needs to check again what is in the DB to design UI with correct heart colours
        fetchCharactersInDB()
        collectionView.reloadData()
    }
    
//    override func viewWillDisappear(_ animated: Bool) {
//        super.viewWillDisappear(animated)
//        self.offSet = 0
//    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let contentOffset = scrollView.contentOffset.y;
        let contentHeight = scrollView.contentSize.height;
        let diffHeight = contentHeight - contentOffset;
        let frameHeight = scrollView.bounds.size.height;
        let pullHeight  = fabs(diffHeight - frameHeight);
        print("pullHeight:\(pullHeight)");
        if pullHeight == 0.0
        {
            if !isOnSearchMode{
                makeRequest(offSetBy: offSet)
                collectionView.reloadData()
            }
        }
    }
}

extension CharacterSearchViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (view.frame.width - 30)/4, height: 150)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arrayofChars.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "searchCell", for: indexPath) as! CharacterSearchCellItem
        if self.arrayofChars[indexPath.item].name == ""{
            cell.characterName.text = "Marvel character"
        }else{
        cell.characterName.text = self.arrayofChars[indexPath.item].name
        }
        
        cell.characterPhoto.layer.cornerRadius = 7.0
        cell.characterPhoto.clipsToBounds = true
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
        arrayofChars.removeAll()
        collectionView.reloadData()
        self.isOnSearchMode = true
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
        //TODO: fetch new items
        arrayofChars.removeAll()
        collectionView.reloadData()
        isOnSearchMode = false
        makeRequest(offSetBy: 0)
        collectionView.reloadData()
        searchBar.text = nil
        searchBar.resignFirstResponder()
    }
}
