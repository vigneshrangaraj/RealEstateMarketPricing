//
//  PropertyTableViewCell.swift
//  FoodTracker
//
//  Created by Vic on 4/11/21.
//  Copyright © 2021 Harrisburg. All rights reserved.
//

import UIKit

class PropertyTableViewCell: UITableViewCell {
    //MARK: Properties
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var resultLabel: UILabel!
    @IBOutlet weak var photoImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
