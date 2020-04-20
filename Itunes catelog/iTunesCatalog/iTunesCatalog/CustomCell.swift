
//
//  CustomCell.swift
//  iOSCodingChallenge
//
//  Created by Arti Karnik on 4/13/20.
//  Copyright © 2020 Arti Karnik. All rights reserved.
//
import UIKit

class CustomCell: UITableViewCell
{
    @IBOutlet var imgViewProfile: UIImageView!
    @IBOutlet var lblArtistName : UILabel!
    @IBOutlet var lblGenre : UILabel!
    @IBOutlet var lbltrackId : UILabel!
    @IBOutlet var lblCollName : UILabel!

    @IBOutlet weak var btnFav: UIButton!
    
    var actionBlock: (() -> Void)? = nil
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?)
    {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
      
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
    }
    
    
    @IBAction func didTapButton(sender: UIButton)
    {
        actionBlock?()
    }
    
    
}
