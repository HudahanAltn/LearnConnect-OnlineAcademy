//
//  LikedTableViewCell.swift
//  LearnConnectOnlineAcademy
//
//  Created by Hüdahan Altun on 26.11.2024.
//

import UIKit

class LikedTableViewCell: UITableViewCell {
    
    @IBOutlet weak var likedItemImageView: UIImageView!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var likedItemNameLabel: UILabel!
    
    @IBOutlet weak var dealerNameLabel: UILabel!
    
    @IBOutlet weak var likedItemPriceLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        setCellUI()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        // Hücre yeniden kullanılmadan önce sıfırlanacak işlemler burada yapılır.
        likedItemImageView.image = nil
        likedItemNameLabel.text = nil
        dealerNameLabel.text = nil
        likedItemPriceLabel.text = nil
    }
    
    private func setCellUI(){
        backgroundColor = UIColor.white.withAlphaComponent(0.7)
        activityIndicator.hidesWhenStopped = true
        layer.borderColor = UIColor.systemGreen.cgColor
        layer.borderWidth = 0.5
        layer.cornerRadius = 5
        accessoryType = .disclosureIndicator
        let customSelectionColor = UIView()
        customSelectionColor.backgroundColor = UIColor.white.withAlphaComponent(0.7)
        self.selectedBackgroundView = customSelectionColor
        setLikedItemImageViewUI()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    func createLikedItemsCell(_ item:Item){
   
        activityIndicator.startAnimating()
        likedItemNameLabel.text = item.name
        likedItemPriceLabel.text = LocalCurrency().convertCurrency(item.price)
        likedItemPriceLabel.adjustsFontSizeToFitWidth = true

        if item.imageLink != nil && item.imageLink.count > 0{// resim varsa
            
            StorageManager().downloadImage(imageUrl: item.imageLink){//indirme
                imagess in //gelen imageler buradadır.
                self.activityIndicator.stopAnimating()//indirme bitince durdur.
                self.likedItemImageView.image = imagess as? UIImage //ilk resmi göster. commit atıldı.
                
            }
        }
        UserViewModel().downloadUserFromFirestore(userMail: item.dealerMail){
            user in
            self.dealerNameLabel.text = user.fullName
        }
    
    }
    private func setLikedItemImageViewUI(){
        likedItemImageView.layer.cornerRadius = likedItemImageView.frame.size.width / 8
        likedItemImageView.clipsToBounds = true
        likedItemImageView.contentMode = .scaleAspectFit
        
    }
    func runCellAnimation(){//cell gösterim animasyonu

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
