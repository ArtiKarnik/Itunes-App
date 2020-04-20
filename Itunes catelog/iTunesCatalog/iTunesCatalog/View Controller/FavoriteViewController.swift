//
//  FavoriteViewController.swift
//  iTunesCatalog
//
//  Created by Kedar Mohile on 4/16/20.
//  Copyright © 2020 Arti Karnik. All rights reserved.
//

import UIKit

class FavoriteViewController: UIViewController , UITableViewDelegate, UITableViewDataSource
{
    // MARK: variable declaration
    let imageCache = NSCache<NSString, UIImage>()
    @IBOutlet var tblView: UITableView!
    
    // MARK: View didload
    override func viewDidLoad()
    {
        super.viewDidLoad()
    }
    // MARK: button events
    @IBAction func backButtonTapped(_ sender: UIButton) {
           self.navigationController?.popViewController(animated: true)
       }
    // MARK: Tableview delegate method
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrFavorite.count
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
           return 110
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
        let cell = tableView.dequeueReusableCell(withIdentifier: "CustomCell", for: indexPath) as! CustomCell
        let dict = arrFavorite[indexPath.row]
        cell.lblArtistName.text = dict["artistName"]
        cell.lblCollName.text = dict["collectionName"]
        cell.lbltrackId.text = dict["trackId"]
           
        let imgUrl = dict["artworkUrl"]

        if let cachedImage = self.imageCache.object(forKey:imgUrl! as NSString) {
               cell.imgViewProfile.image = cachedImage
        }
        else {
               DispatchQueue.global(qos: .background).async
                {
                    let url = URL(string:dict["artworkUrl"]! )
                   let data = try? Data(contentsOf: url!)
                   let image: UIImage = UIImage(data: data!)!
                                 
                   DispatchQueue.main.async
                   {
                    self.imageCache.setObject(image, forKey:imgUrl! as NSString)
                       cell.imgViewProfile.image = image
                   }
               }
           }
           return cell
    }
}
