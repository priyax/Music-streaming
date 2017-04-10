//
//  StationTableViewCell.swift
//  MusicStreaming
//
//  Created by Priya Xavier on 4/10/17.
//  Copyright © 2017 Copper Mobile. All rights reserved.
//

import UIKit

class StationTableViewCell: UITableViewCell {
  
  @IBOutlet weak var stationLabel: UILabel!
  @IBOutlet weak var stationImage: UIImageView!
  @IBOutlet weak var cellBkg: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
