//
//  OnSaleTableViewCell.swift
//  LearnConnectOnlineAcademy
//
//  Created by Hüdahan Altun on 27.11.2024.
//

import UIKit

class OnSaleTableViewCell: UITableViewCell {

    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var onSaleItemImageView: UIImageView!
    @IBOutlet weak var onSaleItemNameLabel: UILabel!
    @IBOutlet weak var onSaleItemCategoryLabel: UILabel!
    @IBOutlet weak var onSaleItemPriceLabel: UILabel!
    
    var categoryVM = CategoryViewModel()
    var subCategoryVM = SubcategoryViewModel()
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        setCellUI()
        
    }
    private func setCellUI(){
        
        backgroundColor =  UIColor.white.withAlphaComponent(0.7)
        activityIndicator.hidesWhenStopped = true
        layer.borderColor = UIColor.systemGreen.cgColor
        layer.borderWidth = 0.5
        layer.cornerRadius = 5
        accessoryType = .disclosureIndicator
        let customSelectionColor = UIView()
        customSelectionColor.backgroundColor = UIColor.white.withAlphaComponent(0.7)
        self.selectedBackgroundView = customSelectionColor
        setOnSaleItemImageViewUI()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        // Hücre yeniden kullanılmadan önce sıfırlanacak işlemler burada yapılır.
        onSaleItemImageView.image = nil
        onSaleItemNameLabel.text = nil
        onSaleItemCategoryLabel.text = nil
        onSaleItemPriceLabel.text = nil
    }
    
    func createOnSaleItemsCell(_ item:Item){
   
        activityIndicator.startAnimating()
        onSaleItemNameLabel.text = item.name
        onSaleItemPriceLabel.text = LocalCurrency().convertCurrency(item.price)
        onSaleItemPriceLabel.adjustsFontSizeToFitWidth = true
        
        //sadece isim descp ve price gösterdik şimdi resim göstercez.
        
        //burda imageler indirelecek.
        
        if item.imageLink != nil && item.imageLink.count > 0{// resim varsa
            
            StorageManager().downloadImage(imageUrl: item.imageLink){//indirme
                imagess in //gelen imageler buradadır.
                self.activityIndicator.stopAnimating()//indirme bitince durdur.
                self.onSaleItemImageView.image = imagess as? UIImage //ilk resmi göster. commit atıldı.
                
            }
        }
        
        print("satışa sunulan item alt kategori id :\(item.subCategoryId)")
        categoryVM.downloadCategoryName(objectId: item.categoryId){
            name in
            DispatchQueue.main.async {
                self.onSaleItemCategoryLabel.text = name
            }
        }

  
    }
    private func setOnSaleItemImageViewUI(){
        onSaleItemImageView.layer.cornerRadius = onSaleItemImageView.frame.size.width / 8
        onSaleItemImageView.clipsToBounds = true
        onSaleItemImageView.contentMode = .scaleAspectFit
        
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
