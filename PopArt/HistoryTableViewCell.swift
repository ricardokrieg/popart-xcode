//
//  HistoryTableViewCell.swift
//  PopsArt
//
//  Created by Netronian Inc. on 28/08/15.
//  Copyright © 2015 Art Catch. All rights reserved.
//

import UIKit

class HistoryTableViewCell: UITableViewCell {
    @IBOutlet weak var imageContainer: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var locationAreaLabel: UILabel!
    @IBOutlet weak var locationCountryLabel: UILabel!
    
    override var frame: CGRect {
        get {
            return super.frame
        }
        set (newFrame) {
            var frame = newFrame
            frame.size.width = CGFloat(frame.size.width + 15)
            super.frame = frame
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
