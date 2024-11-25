//
//  SubcategoryTableViewCell.swift
//  LearnConnectOnlineAcademy
//
//  Created by Hüdahan Altun on 22.11.2024.
//

import UIKit

class SubcategoryTableViewCell: UITableViewCell {

    @IBOutlet weak var subcategoryNameLabel: UILabel!
    
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
        subcategoryNameLabel.text = nil
        
    }

    private func setCellUI(){
        backgroundColor = UIColor(named: "")
        accessoryType = .disclosureIndicator
        let customSelectionColor = UIView()
        customSelectionColor.backgroundColor = UIColor(rgb:0x30D158)
        self.selectedBackgroundView = customSelectionColor
    }
    
    func createItemsCell(_ category:Category){
        subcategoryNameLabel.text = category.name
    }
    
    func runCellAnimation(){
        layer.transform = CATransform3DMakeScale(0.1,0.1,1)
        UIView.animate(withDuration: 0.5, animations: {
            self.layer.transform = CATransform3DMakeScale(1.0,1.0,1.0)
            },completion: { finished in
                UIView.animate(withDuration: 0.3, animations: {
                    self.layer.transform = CATransform3DMakeScale(1,1,1)
                })
        })
    }

}
