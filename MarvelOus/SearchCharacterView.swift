//
//  SearchCharacterView.swift
//  MarvelOus
//
//  Created by Marcela Ceneviva Auslenter on 21/08/2018.
//  Copyright © 2018 Marcela Ceneviva Auslenter. All rights reserved.
//

import UIKit


class SearchCharacterView: UIViewController {
    
    var arrayofChars = [MarvelCharacter]()
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        MarvelRequestManager.sharedInstance().getAllMarvelCharacters() { (success, arrayOfCharacters, error) in
            if success{
                if let arrayOfCharacters = arrayOfCharacters{
                    self.arrayofChars = arrayOfCharacters
                }
                DispatchQueue.main.async {
                    self.collectionView.reloadData()
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
        cell.characterName.text = arrayofChars[indexPath.row].name
        
        return cell
    }
    
    
}
