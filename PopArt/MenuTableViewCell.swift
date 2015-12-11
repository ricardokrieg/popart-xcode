//
//  MenuTableViewCell.swift
//  PopsArt
//
//  Created by Netronian Inc. on 03/09/15.
//  Copyright © 2015 Art Catch. All rights reserved.
//

import UIKit

class MenuTableViewCell: UITableViewCell {
    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var label: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
