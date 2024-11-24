//
//  ItemsTableViewCell.swift
//  LearnConnectOnlineAcademy
//
//  Created by Hüdahan Altun on 22.11.2024.
//

import UIKit

class ItemTableViewCell: UITableViewCell {

    @IBOutlet weak var itemImageView: UIImageView!
    @IBOutlet weak var itemNameLabel: UILabel!
    @IBOutlet weak var itemOwnerLabel: UILabel!
    @IBOutlet weak var itemPointLabel: UILabel!
    @IBOutlet weak var itemPointProgressView: UIProgressView!
    @IBOutlet weak var itemPriceLabel: UILabel!
    @IBOutlet weak var itemActivityIndicator: UIActivityIndicatorView!
    
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
        itemNameLabel.text = nil
        itemOwnerLabel.text = nil
        itemPointLabel.text = nil
        itemPointProgressView.progress = 0
        itemPriceLabel.text = nil
    }

    private func setCellUI(){
        backgroundColor = UIColor(white: 1.0, alpha: 0.7)
        itemActivityIndicator.hidesWhenStopped = true
        accessoryType = .disclosureIndicator
        let customSelectionColor = UIView()
        customSelectionColor.backgroundColor = .systemGreen
        self.selectedBackgroundView = customSelectionColor
    }
    
    func createItemsCell(_ item:Item){
        
        itemActivityIndicator.startAnimating()
        itemNameLabel.text = item.name
        itemPriceLabel.text = LocalCurrency().convertCurrency(item.price)
        itemPriceLabel.adjustsFontSizeToFitWidth = true
        itemOwnerLabel.text = item.dealerMail
        
        if item.imageLink != nil && item.imageLink.count > 0{
            
            StorageManager().downloadImage(imageUrl: item.imageLink){
                image in
                self.itemImageView.image = image as? UIImage //ilk resmi göster. commit atıldı.
                self.itemActivityIndicator.stopAnimating()//indirme bitince durdur.

            }
        }
        
        UserViewModel().downloadUserFromFirestore(userMail: item.dealerMail){
            user in
            self.itemOwnerLabel.text = user.fullName
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
