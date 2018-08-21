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
    
    init(id: Int, name: String, description: String, path: String, imgExtension: String) {
        self.id = id
        self.name = name
        self.description = description
        self.path = path
        self.imgExtension = imgExtension
    }
}
struct CharacterResult: Codable {
    var results: [MarvelCharacter]?
}

