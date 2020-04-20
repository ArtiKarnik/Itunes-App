//
//  ViewController.swift
//  iTunesCatalog
//
//  Created by Arti karnik on 4/13/20.
//  Copyright © 2020 Arti Karnik. All rights reserved.
//

import UIKit

class ViewController: UIViewController , UITableViewDelegate, UITableViewDataSource , UISearchBarDelegate
{
    // MARK: variable declaration
    @IBOutlet var tblView: UITableView!
    @IBOutlet var searchBar : UISearchBar!
    
    var MediaCount = Dictionary <String,Any>()
    var Result = Dictionary <String,Any>()
    let imageCache = NSCache<NSString, UIImage>()

    // MARK: ViewdidLoad
    override func viewDidLoad()
    {
        setBasicDelegate()
        // API called by default
        getListFromSearchTermWithSearchString(key: "jackson michael")

        super.viewDidLoad()
    }
    // MARK: App start up
    func setBasicDelegate() {
        // get favorite item list
        if isKeyPresentInUserDefaults(key: favoriteKey) {
            arrFavorite =  getFavoriteList()
        }
        tblView.delegate = self
        tblView.dataSource = self
        
        searchBar.delegate = self
    }
    // MARK: search bar delegate methods
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.becomeFirstResponder()
    }
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        if searchBar.text != nil && searchBar.text != "" {
            getListFromSearchTermWithSearchString(key: searchBar.text!)
        }
    }
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
    searchBar.endEditing(true)
}
    // MARK: button events
    @IBAction func favButtonTapped(_ sender: UIButton)
    {
        let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "FavoriteViewController") as? FavoriteViewController
            self.navigationController?.pushViewController(vc!, animated: true)
    }
    // MARK: Tableview delegate methods
func numberOfSections(in tableView: UITableView) -> Int {
        return self.Result.count
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let arr =  Array(Result.values)[section]
        return  (arr as AnyObject).count
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
   func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 110
    }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String?{
        let arr =  Array(Result.values)[section]
        if  (arr as AnyObject).count  > 0
        {
            return Array(Result.keys)[section]
        }
        return ""
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CustomCell", for: indexPath) as! CustomCell
        
        let currentSection :String = Array(Result.keys)[indexPath.section]
        let arr = Result[currentSection] as? Array<[String : Any]>
        let dict = arr?[indexPath.row]
        
        cell.lblArtistName.text = dict?["artistName"] as? String
        cell.lblCollName.text = dict?["collectionName"] as? String
        cell.lbltrackId.text = dict?["trackId"] as? String
        
        let imgUrl = dict?["artworkUrl"]

        if let cachedImage = self.imageCache.object(forKey:imgUrl as! NSString)
        {
            cell.imgViewProfile.image = cachedImage
        }
        else
        {
            DispatchQueue.global(qos: .background).async
             {
                let url = URL(string:dict?["artworkUrl"]! as! String)
                let data = try? Data(contentsOf: url!)
                let image: UIImage = UIImage(data: data!)!
                              
                DispatchQueue.main.async
                {
                    self.imageCache.setObject(image, forKey:imgUrl as! NSString)
                    cell.imgViewProfile.image = image
                }
            }
        }
        cell.actionBlock =
        {
            if  cell.btnFav.currentImage == UIImage(named: "un-fav.jpg")
            {
                var i : Int = 0
                for fav in arrFavorite {
                    let id = fav["trackId"]!
                    let currentId =  dict?["trackId"] as? String
                    if (id == currentId) {
                        arrFavorite.remove(at: i)
                        self.saveFavorites(arr: arrFavorite)
                        self.tblView.reloadData()
                    }
                    i = i + 1
                }
            }
            else {
                arrFavorite.append(dict as! [String : String])
                self.saveFavorites(arr: arrFavorite)
                self.tblView.reloadData()
            }
        }
        for fav in arrFavorite {
            let id = fav["trackId"]!
            let currentId =  dict?["trackId"] as? String
            if (id == currentId) {
                [cell.btnFav .setImage(UIImage(named: "un-fav.jpg"), for: .normal)]
                cell.backgroundColor = UIColor.clear
                return cell
            }
            else {
                [cell.btnFav .setImage(UIImage(named: "fav.png"), for: .normal)]
                cell.backgroundColor = UIColor.clear
            }
        }
        return cell
    }
func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
       
        let currentSection :String = Array(Result.keys)[indexPath.section]
        let arr = Result[currentSection] as? Array<[String : String]>
        let dict = arr?[indexPath.row]
        
        let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "DetailViewController") as? DetailViewController
        vc?.dictDetail  = dict!
        self.navigationController?.pushViewController(vc!, animated: true)
}
//MARK: get-set favorite list
func isKeyPresentInUserDefaults(key: String) -> Bool    {
        return UserDefaults.standard.object(forKey: key) != nil
}
private func saveFavorites(arr : [Dictionary<String, String>])    {
        let defaults = UserDefaults.standard
        defaults.setValue(arr, forKey: favoriteKey)
}
private func getFavoriteList()-> [Dictionary<String, String>]    {
        let defaults = UserDefaults.standard
        return defaults.value(forKey: favoriteKey) as! [Dictionary<String, String>]
}
// MARK: reload table
func reloadTable() {
        self.tblView.reloadData()
}
// MARK: generate random number if track id not found
func random(digits:Int) -> String
{
    var number = String()
    for _ in 1...digits {
        number += "\(Int.random(in: 1...9))"
    }
    return number
}
// MARK: create API from Json data
func createAPIFromJsonData(data: Array<[String : Any]>) -> Dictionary <String,Any>
{
    //====== count total media type available for ex- song:  10 , feature-movie:20
    var arrMediaType = [String]()
    var dictResult = Dictionary <String,Any>()
    
    for result in data
    {
        var tempMediaType = result["kind"] as? String
        if tempMediaType == "" { // in case 'kind' option not available use wrapper type
            tempMediaType = result["wrapperType"] as? String
        }
        arrMediaType.append(tempMediaType ?? "")
    }
    // print(arrMediaType)
    
    // sort media type and calculate it count
    let mappedItems = arrMediaType.map { ($0, 1) }
    self.MediaCount = Dictionary(mappedItems, uniquingKeysWith: +)
    //======
    
    // check for media type and create dictionary specific to type
    for (key, value) in self.MediaCount {
        var arrMedia = [Dictionary<String, Any>]()
                           
        for result in data {
        let currentMediaType = result["kind"] as? String ?? result["wrapperType"] as? String
        
            if currentMediaType ==  key {
                var tempDict = Dictionary<String,String>()
                let trackId : Int = result["trackId"] as? Int ?? 0
                    
                tempDict = ["artistName" : result["artistName"] as? String ?? "",
                            "kind" : result["kind"] as? String ?? "",
                            "collectionName" : result["collectionName"] as? String ?? "",
                            "artworkUrl" : result["artworkUrl100"] as? String ?? "",
                            "genre" : result["genre"] as? String ?? ""]
                if trackId != 0 {
                        tempDict["trackId"] = String(trackId)
                    }
                    else {
                        tempDict["trackId"] = String(self.random(digits: 5))
                    }
                
                arrMedia.append(tempDict  as [String : Any])
            }
        }
        dictResult[key] = arrMedia
    }
    return dictResult
}
    
// MARK: Network call
private func getListFromSearchTermWithSearchString(key: String)
{
    if (key != nil  && key != "")
    {
      let formattedString = key.replacingOccurrences(of: " ", with: "+")
      let url = URL(string: baseUrl + formattedString)
    
      URLSession.shared.dataTask(with: url!) {(data :Data? ,response : URLResponse? ,error : Error?) -> Void in
        
      if(error == nil)
      {
        do {
            if let json = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.allowFragments) as? [String : Any]
            {
                if var output = json["results"] as? Array<[String : Any]> {
                    self.Result.removeAll()
                    output = (output as NSArray).sortedArray(using: [NSSortDescriptor(key: "kind", ascending: true)]) as! [[String:AnyObject]]
                    self.Result = self.createAPIFromJsonData(data: output)
                   
                    DispatchQueue.main.async
                    {
                        self.tblView.reloadData()
                    }
            }
        }
    } catch {
            print("error is JSON")
            }
    }
   } .resume()
}
}
}


