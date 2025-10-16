//
//  PlayerStatsCell.swift
//  AFLStatsTracker
//
//  Created by Jahnavi Dasari on 18/5/2025.
//

import UIKit

class PlayerStatsCell: UICollectionViewCell {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var statsLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        contentView.layer.cornerRadius = 8
        contentView.layer.borderWidth = 1
        contentView.layer.borderColor = UIColor.systemGray4.cgColor
    }
}

