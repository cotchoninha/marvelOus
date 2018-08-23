//
//  UIMarvelCharacter.swift
//  MarvelOus
//
//  Created by Marcela Ceneviva Auslenter on 23/08/2018.
//  Copyright © 2018 Marcela Ceneviva Auslenter. All rights reserved.
//

import Foundation

//UIMarvelCharacter will contain only the properties needed to be exibited on the DetailVC through CoreData or Network response
struct UIMarvelCharacter {
    var characterId: Int
    var characterName: String
    var characterPhoto: Data
    var characterDescription: String
    var isFavorite: Bool
}
