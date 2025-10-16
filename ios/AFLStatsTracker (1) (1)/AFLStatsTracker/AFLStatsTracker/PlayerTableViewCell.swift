//
//  PlayerTableViewCell.swift
//  AFLStatsTracker
//
//  Created by Jahnavi Dasari on 19/5/2025.
//

import UIKit

class PlayerTableViewCell: UITableViewCell {
    @IBOutlet weak var playerImageView: UIImageView!
    @IBOutlet weak var playerLabel: UILabel!
    override func awakeFromNib() {
            super.awakeFromNib()
            
            // Styling the image view
        playerImageView.layer.cornerRadius = 8
               playerImageView.clipsToBounds = true
               playerImageView.contentMode = .scaleAspectFill
           }
        }
    

