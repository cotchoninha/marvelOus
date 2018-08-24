//
//  ViewController.swift
//  MarvelOus
//
//  Created by Marcela Ceneviva Auslenter on 20/08/2018.
//  Copyright © 2018 Marcela Ceneviva Auslenter. All rights reserved.
//

import UIKit

class MarvelRequestManager: NSObject{
    
    //singleton
    class func sharedInstance() -> MarvelRequestManager {
        struct Singleton {
            static var sharedInstance = MarvelRequestManager()
        }
        return Singleton.sharedInstance
    }
    
    func getAllMarvelCharacters(offSet: Int, _ completionHandlerForGETMARVEL: @escaping (_ success: Bool, _ imagesArray: [APIMarvelCharacter]?, _ totalNumberOfCharacters: Int?, _ error: Error?) -> Void) {
        
        let methodParameters = [Constants.MarvelParameterKeys.APIPublicKey: Constants.MarvelParameterValues.APIPublicKey, Constants.MarvelParameterKeys.Hash: Constants.MarvelParameterValues.Hash,  Constants.MarvelParameterKeys.Limit: Constants.MarvelParameterValues.Limit, Constants.MarvelParameterKeys.Ts: Constants.MarvelParameterValues.Ts, Constants.MarvelParameterKeys.Offset: offSet] as [String : Any]
        
        let urlString = Constants.Marvel.APIBaseURL + escapedParameters(methodParameters as [String:AnyObject])
        print("MARCELA: URLSTRING \(urlString)")
        let url = URL(string: urlString)!
        let request = URLRequest(url: url)
        let session = URLSession.shared
        
        let task = session.dataTask(with: request) { (data, response, error) in
            
            //colocar o botao de NewCollection como disabled
            
            // if an error occurs, print it and re-enable the UI
            func displayError(_ error: String) {
                print(error)
                print("URL at time of error: \(url)")
                completionHandlerForGETMARVEL(false, nil, nil, error as? Error)
            }
            
            /* GUARD: Was there an error? */
            guard (error == nil) else {
                displayError("There was an error with your request: \(error)")
                return
            }
            
            /* GUARD: Did we get a successful 2XX response? */
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                displayError("Your request returned a status code other than 2xx!")
                return
            }
            
            /* GUARD: Was there any data returned? */
            guard let data = data else {
                displayError("No data was returned by the request!")
                return
            }
            
            // parse the data
            let parsedResult: [String:AnyObject]!
            do {
                parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String:AnyObject]
            } catch {
                displayError("Could not parse the data as JSON: '\(data)'")
                return
            }
            
            /* GUARD: Did Marvel return an error (stat != ok)? */
            guard let stat = parsedResult[Constants.MarvelResponseKeys.Status] as? String, stat == Constants.MarvelResponseValues.OKStatus else {
                displayError("Marvel API returned an error. See error code and message in \(parsedResult)")
                return
            }
            
            /* GUARD: Are the "photos" and "photo" keys in our result? */
            guard let dataKey = parsedResult[Constants.MarvelResponseKeys.Data] as? [String:AnyObject], let results = dataKey[Constants.MarvelResponseKeys.Results] as? [[String:AnyObject]], let totalCharacters = dataKey[Constants.MarvelResponseKeys.Total] as? Int else {
                displayError("Cannot find keys '\(Constants.MarvelResponseKeys.Data)' and '\(Constants.MarvelResponseKeys.Results)' in \(parsedResult)")
                return
            }
            
//            self.totalNumberOfCharacters = totalCharacters
            var charactersArray = [APIMarvelCharacter]()
            for item in results{
                guard let id = item[Constants.MarvelResponseKeys.Id], let name = item[Constants.MarvelResponseKeys.Name], let description = item[Constants.MarvelResponseKeys.Description], let thumbnail = item[Constants.MarvelResponseKeys.Thumbnail], let path = thumbnail[Constants.MarvelResponseKeys.Path], let imgExtension = thumbnail[Constants.MarvelResponseKeys.ImgExtension] else{
                    displayError("Cannot find values")
                    return
                }
                charactersArray.append(APIMarvelCharacter(id: id as! Int, name: name as! String, description: description as! String, path: path as! String, imgExtension: imgExtension as! String, characterPhoto: nil))
                
            }
            completionHandlerForGETMARVEL(true, charactersArray, totalCharacters, nil)
        }
        task.resume()
        
    }
    
    func getMarvelCharactersWithName(nameStartsWith: String?, _ completionHandlerForGETMARVEL: @escaping (_ success: Bool, _ imagesArray: [APIMarvelCharacter]?, _ error: Error?) -> Void) {
        
        let methodParameters = [Constants.MarvelParameterKeys.APIPublicKey: Constants.MarvelParameterValues.APIPublicKey, Constants.MarvelParameterKeys.Hash: Constants.MarvelParameterValues.Hash,  Constants.MarvelParameterKeys.Limit: Constants.MarvelParameterValues.Limit, Constants.MarvelParameterKeys.NameStartsWith: (nameStartsWith ?? nil), Constants.MarvelParameterKeys.Ts: Constants.MarvelParameterValues.Ts] as [String : Any]
        
        let urlString = Constants.Marvel.APIBaseURL + escapedParameters(methodParameters as [String:AnyObject])
        print("MARCELA: URLSTRING \(urlString)")
        let url = URL(string: urlString)!
        let request = URLRequest(url: url)
        let session = URLSession.shared
        
        let task = session.dataTask(with: request) { (data, response, error) in
            
            //colocar o botao de NewCollection como disabled
            
            // if an error occurs, print it and re-enable the UI
            func displayError(_ error: String) {
                print(error)
                print("URL at time of error: \(url)")
                completionHandlerForGETMARVEL(false, nil, error as? Error)
            }
            
            /* GUARD: Was there an error? */
            guard (error == nil) else {
                displayError("There was an error with your request: \(error)")
                return
            }
            
            /* GUARD: Did we get a successful 2XX response? */
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                displayError("Your request returned a status code other than 2xx!")
                return
            }
            
            /* GUARD: Was there any data returned? */
            guard let data = data else {
                displayError("No data was returned by the request!")
                return
            }
            
            // parse the data
            let parsedResult: [String:AnyObject]!
            do {
                parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String:AnyObject]
            } catch {
                displayError("Could not parse the data as JSON: '\(data)'")
                return
            }
            
            /* GUARD: Are the "photos" and "photo" keys in our result? */
            guard let dataKey = parsedResult[Constants.MarvelResponseKeys.Data] as? [String:AnyObject], let results = dataKey[Constants.MarvelResponseKeys.Results] as? [[String:AnyObject]] else {
                displayError("Cannot find keys '\(Constants.MarvelResponseKeys.Data)' and '\(Constants.MarvelResponseKeys.Results)' in \(parsedResult)")
                return
            }
            var charactersArray = [APIMarvelCharacter]()
            for item in results{
                guard let id = item[Constants.MarvelResponseKeys.Id], let name = item[Constants.MarvelResponseKeys.Name], let description = item[Constants.MarvelResponseKeys.Description], let thumbnail = item[Constants.MarvelResponseKeys.Thumbnail], let path = thumbnail[Constants.MarvelResponseKeys.Path], let imgExtension = thumbnail[Constants.MarvelResponseKeys.ImgExtension] else{
                    displayError("Cannot find values")
                    return
                }
                charactersArray.append(APIMarvelCharacter(id: id as! Int, name: name as! String, description: description as! String, path: path as! String, imgExtension: imgExtension as! String, characterPhoto: nil))
                
            }
            completionHandlerForGETMARVEL(true, charactersArray, nil)
        }
        task.resume()
        
    }
    private func escapedParameters(_ parameters: [String:AnyObject]) -> String {
        
        if parameters.isEmpty {
            return ""
        } else {
            var keyValuePairs = [String]()
            
            for (key, value) in parameters {
                
                // make sure that it is a string value
                let stringValue = "\(value)"
                
                // escape it
                let escapedValue = stringValue.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
                
                // append it
                keyValuePairs.append(key + "=" + "\(escapedValue!)")
                
            }
            
            return "?\(keyValuePairs.joined(separator: "&"))"
        }
    }
    
    func parseDataWithCodable(data: Data) -> [APIMarvelCharacter]? {
        
        let jsonDecoder = JSONDecoder()
        do{
            let characterResult = try jsonDecoder.decode(CharacterResult.self, from: data)
            return characterResult.results
        } catch{
            print("Could not parse the data as JSON: '\(data)'")
            return nil
        }
    }
    
    func downloadImage(url: String, _ completionHandlerOnImageDownloaded: @escaping (_ imageData: Data?, _ error: Error?) -> Void){
        if let urlString = URL(string: url){
            let task = URLSession.shared.dataTask(with: urlString) { (imageData, response, error) in
                func displayError(_ error: String) {
                    print(error)
                    print("URL at time of error: \(url)")
                    completionHandlerOnImageDownloaded(nil, error as? Error)
                }
                
                /* GUARD: Was there an error? */
                guard (error == nil) else {
                    displayError("There was an error with your request: \(error)")
                    return
                }
                
                /* GUARD: Did we get a successful 2XX response? */
                guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                    displayError("Your request returned a status code other than 2xx!")
                    return
                }
                
                /* GUARD: Was there any data returned? */
                guard let imageData = imageData else {
                    displayError("No data was returned by the request!")
                    return
                }
                
                completionHandlerOnImageDownloaded(imageData, nil)
            }
            task.resume()
        }
    }

}

