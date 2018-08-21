//
//  FavoritesTableView.swift
//  MarvelOus
//
//  Created by Marcela Ceneviva Auslenter on 21/08/2018.
//  Copyright © 2018 Marcela Ceneviva Auslenter. All rights reserved.
//

import Foundation
import UIKit

class FavoritesTableView: UIViewController, UITableViewDelegate, UITableViewDataSource{
    
    var charactersArray: [MarvelCharacter] = [MarvelCharacter(id: 1, name: "SpiderMan", description: "Homem Aranha"), MarvelCharacter(id: 2, name: "IronMan", description: "Homem de Ferro"), MarvelCharacter(id: 3, name: "Ant Man", description: "Homem Formiga"), MarvelCharacter(id: 4, name: "Captain America", description: "Capitão América")]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return charactersArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "tableCell", for: indexPath) as! FavoritesTableViewCell
        cell.characterName.text = charactersArray[indexPath.row].name
        cell.favoriteButton.tintColor = .blue
        cell.characterPhoto.image = #imageLiteral(resourceName: "placeholder")
        return cell
    }
    
    
}
