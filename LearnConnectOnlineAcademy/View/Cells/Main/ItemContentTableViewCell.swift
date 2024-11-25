//
//  ItemContentTableViewCell.swift
//  LearnConnectOnlineAcademy
//
//  Created by Hüdahan Altun on 23.11.2024.
//

import UIKit

class ItemContentTableViewCell: UITableViewCell {

    @IBOutlet weak var itemContentLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()

        setCellUI()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    private func setCellUI(){
        backgroundColor = .clear
        accessoryType = .disclosureIndicator
        let customSelectionColor = UIView()
        customSelectionColor.backgroundColor = .systemGreen
        self.selectedBackgroundView = customSelectionColor
        
    }
    
    func createCell(itemContentName:String,itemContentCount:Int){
        
        for count in 1...itemContentCount{
            itemContentLabel.text = "\(count)- \(itemContentName)"
        }
        
    }
}
