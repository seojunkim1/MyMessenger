//
//  YourCell.swift
//  FirebaseTalk
//
//  Created by Pigman on 12/02/2019.
//  Copyright © 2019 PigAngel. All rights reserved.
//

import UIKit

class YourCell: UITableViewCell {

 
    @IBOutlet weak var yourMessageTextView: UITextView!
    @IBOutlet weak var yourProfileImgView: UIImageView!
    @IBOutlet weak var yourNameLabel: UILabel!
    
    @IBOutlet weak var timeStampLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
