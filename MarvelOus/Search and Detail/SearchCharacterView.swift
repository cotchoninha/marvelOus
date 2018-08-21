//
//  SearchCharacterView.swift
//  MarvelOus
//
//  Created by Marcela Ceneviva Auslenter on 21/08/2018.
//  Copyright © 2018 Marcela Ceneviva Auslenter. All rights reserved.
//

import UIKit
import CoreData

class SearchCharacterView: UIViewController {
    
    var arrayofChars = [MarvelCharacter]()
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        activityIndicator.startAnimating()
        MarvelRequestManager.sharedInstance().getAllMarvelCharacters() { (success, arrayOfCharacters, error) in
            if success{
                if let arrayOfCharacters = arrayOfCharacters{
                    self.arrayofChars = arrayOfCharacters
                }
                DispatchQueue.main.async {
                    self.collectionView.reloadData()
                    self.activityIndicator.hidesWhenStopped = true
                    self.activityIndicator.stopAnimating()
                }
            }else{
                print("Couldn't get Marvel's Characters: \(error?.localizedDescription)")
            }
        }
    }
}

extension SearchCharacterView: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arrayofChars.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "searchCell", for: indexPath) as! CharacterSearchedCell
        cell.characterName.text = arrayofChars[indexPath.item].name
        cell.buttonAction = {
//             Do whatever you want from your button here.
            let character = Character(context: DataBaseController.getContext())
            character.id = Int32(self.arrayofChars[indexPath.item].id)
            character.charDescription = self.arrayofChars[indexPath.item].description
            character.name = self.arrayofChars[indexPath.item].name
            character.path = self.arrayofChars[indexPath.item].path
            character.imgExtension = self.arrayofChars[indexPath.item].imgExtension
            let urlString = "\(self.arrayofChars[indexPath.item].path).\(self.arrayofChars[indexPath.item].imgExtension)"
                MarvelRequestManager.sharedInstance().downloadImage(url: urlString) { (imageData, error) in
                    guard error == nil else{
                        print("MARCELA couldn't download data: \(error)")
                        return
                    }
                    print("MARCELA fim download da imagem")
                    if let imageDataDownloaded = imageData{
                        character.photoImage = imageDataDownloaded
                        print("MARCELA: saved photoImage ON CHARACTER : \(character.photoImage)")
                    }
                }
            print("MARCELA: saved id ON CHARACTER : \(character)")
            DataBaseController.saveContext()
            

        }
        return cell
    }
    
    
}
