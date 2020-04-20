//
//  DetailViewController.swift
//  iTunesCatalog
//
//  Created by Kedar Mohile on 4/16/20.
//  Copyright © 2020 Arti Karnik. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {

    // MARK: variable declaration
    @IBOutlet var lblArtistName: UILabel!
    @IBOutlet var lblCollectionName : UILabel!
    @IBOutlet var lblGenre : UILabel!
    @IBOutlet var lblTrackId : UILabel!
    @IBOutlet var imgViewProfile : UIImageView!
    @IBOutlet weak var titleBar: UINavigationBar!
    var dictDetail : Dictionary<String,String> = [:]
    var strArtistName : String!
    var strReleaseDate : String!
    var imgViewProfileUrl : String!
    let imageCache = NSCache<NSString, UIImage>()
    
    // MARK: ViewdidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        basicUI()
    }
    // MARK: Basic UI
    func basicUI() {
        setProfilePic()
        setArtistInfo()
    }
    func  setProfilePic() {
        
        let key =  "Detail" + (dictDetail["artworkUrl"] ?? "") 
        self.imgViewProfileUrl = dictDetail["artworkUrl"]
        
        // check for cache image
        if let cachedImage = self.imageCache.object(forKey:key as NSString) {
              print("in cache")
               imgViewProfile.image = cachedImage
        }
        else {
              DispatchQueue.global(qos: .background).async
              {
                let url = URL(string:self.imgViewProfileUrl ?? "")
                      let data = try? Data(contentsOf: url!)
                      let image: UIImage = UIImage(data: data!)!
                     
                      DispatchQueue.main.async {
                        self.imageCache.setObject(image, forKey:key as NSString)
                          self.imgViewProfile.image = image
                      }
                }
        }
    }
func setArtistInfo() {
   
    if  dictDetail != nil {
        lblArtistName.text = "Artist Name : " + (dictDetail["artistName"] ?? "")
        lblCollectionName.text = "Collection Name" + ":" +  (dictDetail["collectionName"] ?? "")
        lblTrackId.text = "Track Id : " +  (dictDetail["trackId"] ?? "")
        lblGenre.text = "Genre : " +  (dictDetail["genre"] ?? "")
        }
    }
// MARK: - Navigation
 @IBAction func showPreview(_ sender: UIButton) {

let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "FavoriteViewController") as? FavoriteViewController
self.navigationController?.pushViewController(vc!, animated: true)
}
@IBAction func buttonTapped(_ sender: UIButton) {
           self.navigationController?.popViewController(animated: true)
}
@IBAction func favButtonTapped(_ sender: UIButton) {
        let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "FavoriteViewController") as? FavoriteViewController
        self.navigationController?.pushViewController(vc!, animated: true)
}
}
