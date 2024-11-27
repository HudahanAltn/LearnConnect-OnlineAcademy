//
//  DownloadedVideosTableViewCell.swift
//  LearnConnectOnlineAcademy
//
//  Created by Hüdahan Altun on 26.11.2024.
//

import UIKit

class DownloadedVideosTableViewCell: UITableViewCell {

    @IBOutlet weak var videoNameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = UIColor.white.withAlphaComponent(0.8)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
