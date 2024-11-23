//
//  ItemsTableViewCell.swift
//  LearnConnectOnlineAcademy
//
//  Created by Hüdahan Altun on 22.11.2024.
//

import UIKit

class ItemTableViewCell: UITableViewCell {

    @IBOutlet weak var itemImageView: UIImageView!
    
    @IBOutlet weak var itemLabel: UILabel!
    
    @IBOutlet weak var itemOwnerLabel: UILabel!
    
    @IBOutlet weak var itemPointLabel: UILabel!
    
    @IBOutlet weak var itemPointProgressView: UIProgressView!
    
    @IBOutlet weak var itemPriceLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        setCellUI()
        setItemImageViewUI()
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        itemImageView.image = nil
        itemLabel.text = nil
        itemPriceLabel.text = nil
        dealerNameLabel.text = nil
    }

    private func setCellUI(){
        backgroundColor = UIColor(white: 1.0, alpha: 0.7)
        activityIndicator.hidesWhenStopped = true
        layer.borderColor = UIColor(rgb:0xF2BD41).cgColor
        layer.borderWidth = 0.5
        layer.cornerRadius = 5
        accessoryType = .disclosureIndicator
        let customSelectionColor = UIView()
        customSelectionColor.backgroundColor = UIColor(rgb:0xF2BD41)
        self.selectedBackgroundView = customSelectionColor
    }
    
    func createItemsCell(_ item:Item){
   
        activityIndicator.startAnimating()
        itemNameLabel.text = item.name
        itemDescriptionLabel.text = item.description
        itemPriceLabel.text = LocalCurrency().convertCurrency(item.price)
        itemPriceLabel.adjustsFontSizeToFitWidth = true
        dealerNameLabel.text = item.dealerName
        
        if item.imageLinks != nil && item.imageLinks.count > 0{
            ImageManager().downloadImages(imageUrls: item.imageLinks){
                imagess in
    
                self.itemImageView.image = imagess.first as? UIImage //ilk resmi göster. commit atıldı.
                self.activityIndicator.stopAnimating()//indirme bitince durdur.
            }
        }
    }

    private func setItemImageViewUI(){
        itemImageView.layer.cornerRadius = itemImageView.frame.size.width / 8
        itemImageView.clipsToBounds = true
        itemImageView.contentMode = .scaleAspectFill
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
