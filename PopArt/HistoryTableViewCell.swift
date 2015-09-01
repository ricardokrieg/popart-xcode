//
//  HistoryTableViewCell.swift
//  PopArt
//
//  Created by Ricardo Franco on 28/08/15.
//  Copyright (c) 2015 Ricardo Franco. All rights reserved.
//

import UIKit

class HistoryTableViewCell: UITableViewCell {
    @IBOutlet weak var imageContainer: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
