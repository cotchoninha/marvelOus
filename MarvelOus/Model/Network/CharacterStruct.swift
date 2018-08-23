//
//  CharacterStruct.swift
//  MarvelOus
//
//  Created by Marcela Ceneviva Auslenter on 21/08/2018.
//  Copyright © 2018 Marcela Ceneviva Auslenter. All rights reserved.
//

import Foundation

struct MarvelCharacter: Codable {
    
    var id: Int
    var name: String
    var description: String
    var path: String
    var imgExtension: String
    var characterPhoto: Data?
    
}
struct CharacterResult: Codable {
    var results: [MarvelCharacter]?
}

