//
//  FavoritesCollectionView.swift
//  MarvelOus
//
//  Created by Marcela Ceneviva Auslenter on 21/08/2018.
//  Copyright © 2018 Marcela Ceneviva Auslenter. All rights reserved.
//

import Foundation
import UIKit

class FavoritesCollectionView: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    var charactersArray: [MarvelCharacter] = [MarvelCharacter(id: 1, name: "SpiderMan", description: "Homem Aranha"), MarvelCharacter(id: 2, name: "IronMan", description: "Homem de Ferro"), MarvelCharacter(id: 3, name: "Ant Man", description: "Homem Formiga"), MarvelCharacter(id: 4, name: "Captain America", description: "Capitão América")]
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return charactersArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
         let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "collectionCell", for: indexPath) as! FavoritesCollectionViewCell
        cell.characterName.text = charactersArray[indexPath.row].name
        cell.favoriteButton.tintColor = .blue
        cell.characterPhoto.image = #imageLiteral(resourceName: "placeholder")
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let controller = storyboard?.instantiateViewController(withIdentifier: "detailViewController") as! DetailCharacterView
        self.present(controller, animated: true, completion: nil)
    }
    
}
