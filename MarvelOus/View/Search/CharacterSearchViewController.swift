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
    
    var arrayofChars = [APIMarvelCharacter]()
    
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

extension CharacterSearchViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arrayofChars.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "searchCell", for: indexPath) as! CharacterSearchCellItem
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
                print("MARCELA fim download da imagem")
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
        print("MARCELA: ARRAY: \(arrayofChars)")
        cell.buttonAction = {
            let character = Character(context: DataBaseController.getContext())
            character.id = Int32(self.arrayofChars[indexPath.item].id)
            character.charDescription = self.arrayofChars[indexPath.item].description
            character.name = self.arrayofChars[indexPath.item].name
            character.path = self.arrayofChars[indexPath.item].path
            character.imgExtension = self.arrayofChars[indexPath.item].imgExtension
            character.photoImage = self.arrayofChars[indexPath.item].characterPhoto
            DataBaseController.saveContext()
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let controller = storyboard?.instantiateViewController(withIdentifier: "detailViewController") as! CharacterDetailsViewController
        controller.character = self.arrayofChars[indexPath.item]
        self.present(controller, animated: true, completion: nil)
    }
}
