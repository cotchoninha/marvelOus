//
//  ConstantsMarvel.swift
//  MarvelOus
//
//  Created by Marcela Ceneviva Auslenter on 21/08/2018.
//  Copyright © 2018 Marcela Ceneviva Auslenter. All rights reserved.
//

import Foundation

struct Constants {
    
    // MARK: Flickr
    struct Marvel {
        static let APIBaseURL = "https://gateway.marvel.com/v1/public/characters"
    }
    
    // MARK: Flickr Parameter Keys
    struct MarvelParameterKeys {
        static let APIPublicKey = "apikey"
        static let Hash = "hash"
        static let Ts = "ts"
        static let Limit = "limit"
        static let NameStartsWith = "nameStartsWith"
    }
    
    // MARK: Flickr Parameter Values
    struct MarvelParameterValues {
        static let APIPublicKey = "f46b026b0934a8cb453cf647d4168905"
        static let Hash = "247e3aecb47579e933d7b66d2e06d453"
        static let Ts = 1
        static let Limit = 100
    }
    
    // MARK: Flickr Response Keys
    struct MarvelResponseKeys {
        static let Status = "status"
        static let Code = "code"
        static let Data = "data"
        static let Results = "results"
        static let Id = "id"
        static let Name = "name"
        static let Description = "description"
        static let Thumbnail = "thumbnail"
        static let Path = "path"
        static let ImgExtension = "extension"
    }
    
    // MARK: Flickr Response Values
    struct MarvelResponseValues {
        static let OKStatus = "ok"
    }
}
