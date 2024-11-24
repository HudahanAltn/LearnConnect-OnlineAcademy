//
//  CartTableViewCell.swift
//  LearnConnectOnlineAcademy
//
//  Created by Hüdahan Altun on 23.11.2024.
//

import UIKit

class CartTableViewCell: UITableViewCell {

    @IBOutlet weak var cartItemImageView: UIImageView!
    
    
    @IBOutlet weak var cartItemNameLabel: UILabel!
    
    @IBOutlet weak var dealerNameLabel: UILabel!
    
    
    @IBOutlet weak var cartItemPriceLabel: UILabel!
    
    
    @IBOutlet weak var cartActivityIndicator: UIActivityIndicatorView!
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        setCellUI()
        
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        // Hücre yeniden kullanılmadan önce sıfırlanacak işlemler burada yapılır.
        cartItemImageView.image = nil
        cartItemNameLabel.text = nil
        dealerNameLabel.text = nil
        cartItemPriceLabel.text = nil
    }
    
    private func setCellUI(){
        
        backgroundColor = UIColor(white: 1.0, alpha: 0.7)
        cartActivityIndicator.hidesWhenStopped = true
        layer.borderColor = UIColor.systemGreen.cgColor
        layer.borderWidth = 0.5
        layer.cornerRadius = 5
        accessoryType = .disclosureIndicator
        let customSelectionColor = UIView()
        customSelectionColor.backgroundColor = .systemGreen
        self.selectedBackgroundView = customSelectionColor
        setCartItemImageViewUI()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func createItemsCell(_ item:Item){
   
        cartActivityIndicator.startAnimating()
        cartItemNameLabel.text = item.name
        cartItemPriceLabel.text = LocalCurrency().convertCurrency(item.price)
        cartItemPriceLabel.adjustsFontSizeToFitWidth = true
        dealerNameLabel.text = item.dealerMail
        //sadece isim descp ve price gösterdik şimdi resim göstercez.
        
        //burda imageler indirelecek.
        
        if item.imageLink != nil && item.imageLink.count > 0{// resim varsa
            
            StorageManager().downloadImage(imageUrl: item.imageLink){//indirme
                imagess in //gelen imageler buradadır.
                self.cartActivityIndicator.stopAnimating()//indirme bitince durdur.
                self.cartItemImageView.image = imagess as? UIImage //ilk resmi göster. commit atıldı.
                
            }
        }
        
        UserViewModel().downloadUserFromFirestore(userMail: item.dealerMail){
            user in
            self.dealerNameLabel.text = user.fullName
        }
    }
    
    private func setCartItemImageViewUI(){
        cartItemImageView.layer.cornerRadius = cartItemImageView.frame.size.width / 8
        cartItemImageView.clipsToBounds = true
        cartItemImageView.contentMode = .scaleAspectFit
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
