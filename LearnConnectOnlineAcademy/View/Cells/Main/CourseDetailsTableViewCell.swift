//
//  CourseDetailsTableViewCell.swift
//  LearnConnectOnlineAcademy
//
//  Created by Hüdahan Altun on 25.11.2024.
//

import UIKit


class CourseDetailsTableViewCell: UITableViewCell {

    @IBOutlet weak var courseVideoNameLabel: UILabel!
    
    @IBOutlet weak var videoDownloadImageView: UIImageView!
    
    @IBOutlet weak var videoProgressView: UIProgressView!
    
    override func awakeFromNib() {
        super.awakeFromNib()

        let customSelectionColor = UIView()
        customSelectionColor.backgroundColor = UIColor(rgb:0x30D158)
        self.selectedBackgroundView = customSelectionColor
       
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
        
    }
    
    

}
