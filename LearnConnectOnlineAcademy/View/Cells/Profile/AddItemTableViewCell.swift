//
//  AddItemTableViewCell.swift
//  LearnConnectOnlineAcademy
//
//  Created by Hüdahan Altun on 22.11.2024.
//

import UIKit

class AddItemTableViewCell: UITableViewCell {

    @IBOutlet weak var videoLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        setCellUI()
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        
    }

    private func setCellUI(){
        backgroundColor = .clear
        accessoryType = .disclosureIndicator
        let customSelectionColor = UIView()
        customSelectionColor.backgroundColor = .systemGreen
        self.selectedBackgroundView = customSelectionColor
        videoLabel.text = nil
    }
    
  
    
}
