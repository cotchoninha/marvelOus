//
//  SearchCharacterView.swift
//  MarvelOus
//
//  Created by Marcela Ceneviva Auslenter on 21/08/2018.
//  Copyright © 2018 Marcela Ceneviva Auslenter. All rights reserved.
//

import UIKit
import CoreData
import SystemConfiguration

class CharacterSearchViewController: UIViewController {
    
    //MARK: properties
    var isOnSearchMode = false
    var offSet = 0
    var arrayofChars = [APIMarvelCharacter]()
    private var fetchedRC: NSFetchedResultsController<Character>!
    
    //MARK: IBOutlets
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    
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
    
    //MARK: Method for making request on Marvel API
    @objc fileprivate func makeRequest(offSetBy: Int) {
        if Reachability.isConnectedToNetwork(){
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
                            self.offSet += 52
                        }
                    }
                }else{
                    DispatchQueue.main.async {
                        self.activityIndicator.stopAnimating()
                        self.activityIndicator.hidesWhenStopped = true
                        UserAlertManager.showAlert(title: "No characters were found.", message: "Due to network connection or invalid input no characters were found.", buttonMessage: "Try again.", viewController: self)
                    }
                    print("Couldn't get Marvel's Characters: \(error?.localizedDescription)")
                }
            }
        }else{
            self.activityIndicator.stopAnimating()
            self.activityIndicator.hidesWhenStopped = true
            UserAlertManager.showAlert(title: "There's no internet connection.", message: "Please connect your phone to the internet and try again.", buttonMessage: "Ok", viewController: self)
        }
    }
    
    //MARK: UI preparation
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //COMMENT: if search mode is true the view will load more characters when scrolled down to the end
        self.isOnSearchMode = false
        
        //COMMENT: offSet will change the range of characters searched
        self.offSet = 0
        
        fetchCharactersInDB()
        activityIndicator.startAnimating()
        makeRequest(offSetBy: offSet)
        
        //Collection Layout
        let width = (view.frame.size.width - 30) / 4
        let height = (view.frame.size.height) - 30/4
        flowLayout.itemSize = CGSize(width: width, height: height)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchCharactersInDB()
        collectionView.reloadData()
    }
    
    //MARK: Method will detect if user has scrolled to the end of the page and if off search mode will load another 52 characters from Marvel API
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let contentOffset = scrollView.contentOffset.y;
        let contentHeight = scrollView.contentSize.height;
        let diffHeight = contentHeight - contentOffset;
        let frameHeight = scrollView.bounds.size.height;
        let pullHeight  = fabs(diffHeight - frameHeight);
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
        return CGSize(width: (view.frame.width - 30)/4, height: 125)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arrayofChars.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "searchCell", for: indexPath) as! CharacterSearchCellItem
        
        cell.characterPhoto.layer.cornerRadius = 7.0
        cell.characterPhoto.clipsToBounds = true
        
        if self.arrayofChars[indexPath.item].name == ""{
            cell.characterName.text = "Marvel character"
        }else{
            cell.characterName.text = self.arrayofChars[indexPath.item].name
        }
        
        //COMMENT: set button red or black depending on character be already saved on DB
        let myImage = UIImage(named: "heart")
        cell.favoriteButton.setImage(myImage?.withRenderingMode(.alwaysTemplate), for: .normal)
        if let objects = fetchedRC.fetchedObjects{
            if objects.contains(where: {$0.id == arrayofChars[indexPath.item].id}){
                cell.favoriteButton.tintColor = .red
            }else{
                cell.favoriteButton.tintColor = .black
            }
        }
        
        //COMMENT: while image has not been downloaded activity indicator will start running
        if arrayofChars[indexPath.item].characterPhoto == nil{
            cell.characterPhoto.image = #imageLiteral(resourceName: "placeholder")
            cell.activityIndicatorCell.startAnimating()
            let urlString = "\(self.arrayofChars[indexPath.item].path).\(self.arrayofChars[indexPath.item].imgExtension)"
            if Reachability.isConnectedToNetwork(){
                MarvelRequestManager.sharedInstance().downloadImage(url: urlString) { (imageData, error) in
                    guard error == nil else{
                        print("couldn't download data: \(error)")
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
                UserAlertManager.showAlert(title: "There's no internet connection.", message: "Please connect your phone to the internet and try again.", buttonMessage: "Ok", viewController: self)
            }
            //COMMENT: after image has been downloaded activity indicator will stop and the image will be placed on cell
        }else{
            cell.activityIndicatorCell.stopAnimating()
            cell.activityIndicatorCell.hidesWhenStopped = true
            if let photoChar = self.arrayofChars[indexPath.item].characterPhoto{
                cell.characterPhoto.image = UIImage(data: photoChar)
            }
        }
        
        //COMMENT: determines what will be executed when favourite button is pressed
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
        controller.marvelCharacter = favoriteCharacterDetailed
        self.present(controller, animated: true, completion: nil)
    }
    
    //MARK: Method that checks if selected character is already favourite or not 
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
        if Reachability.isConnectedToNetwork(){
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
                    UserAlertManager.showAlert(title: "No characters were found.", message: "Due to network connection or invalid input no characters were found.", buttonMessage: "Try again.", viewController: self)
                    print("Couldn't get Marvel's Characters: \(error?.localizedDescription)")
                }
            }
        }else{
            self.activityIndicator.stopAnimating()
            self.activityIndicator.hidesWhenStopped = true
            UserAlertManager.showAlert(title: "There's no internet connection.", message: "Please connect your phone to the internet and try again.", buttonMessage: "Ok", viewController: self)
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        arrayofChars.removeAll()
        collectionView.reloadData()
        isOnSearchMode = false
        makeRequest(offSetBy: 0)
        collectionView.reloadData()
        searchBar.text = nil
        searchBar.resignFirstResponder()
    }
}

public class Reachability {
    
    class func isConnectedToNetwork() -> Bool {
        
        var zeroAddress = sockaddr_in(sin_len: 0, sin_family: 0, sin_port: 0, sin_addr: in_addr(s_addr: 0), sin_zero: (0, 0, 0, 0, 0, 0, 0, 0))
        zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        let defaultRouteReachability = withUnsafePointer(to: &zeroAddress) {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {zeroSockAddress in
                SCNetworkReachabilityCreateWithAddress(nil, zeroSockAddress)
            }
        }
        
        var flags: SCNetworkReachabilityFlags = SCNetworkReachabilityFlags(rawValue: 0)
        if SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) == false {
            return false
        }
        
        /* Only Working for WIFI
         let isReachable = flags == .reachable
         let needsConnection = flags == .connectionRequired
         
         return isReachable && !needsConnection
         */
        
        // Working for Cellular and WIFI
        let isReachable = (flags.rawValue & UInt32(kSCNetworkFlagsReachable)) != 0
        let needsConnection = (flags.rawValue & UInt32(kSCNetworkFlagsConnectionRequired)) != 0
        let ret = (isReachable && !needsConnection)
        
        return ret
        
    }
}


