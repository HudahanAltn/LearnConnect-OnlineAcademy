//
//  CoursesTableViewCell.swift
//  LearnConnectOnlineAcademy
//
//  Created by Hüdahan Altun on 24.11.2024.
//

import UIKit

class CoursesTableViewCell: UITableViewCell {

    
    @IBOutlet weak var courseImageView: UIImageView!
    @IBOutlet weak var courseActivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var courseNameLabel: UILabel!
    @IBOutlet weak var courseDealerLabel: UILabel!
    @IBOutlet weak var courseProgressView: UIProgressView!
    @IBOutlet weak var courseCompleteLabel: UILabel!
    
   
    
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
        courseImageView.image = nil
        courseNameLabel.text = nil
        courseDealerLabel.text = nil
        courseProgressView.progress = 0
        courseCompleteLabel.text = nil
    }

    private func setCellUI(){
        backgroundColor = .clear
        courseActivityIndicator.hidesWhenStopped = true
        accessoryType = .disclosureIndicator
        let customSelectionColor = UIView()
        customSelectionColor.backgroundColor = .systemGreen
        self.selectedBackgroundView = customSelectionColor
    }
    
    func createItemsCell(_ item:Item){
        
        courseActivityIndicator.startAnimating()
        courseNameLabel.text = item.name

        
        if item.imageLink != nil && item.imageLink.count > 0{
            
            StorageManager().downloadImage(imageUrl: item.imageLink){
                image in
                self.courseImageView.image = image as? UIImage //ilk resmi göster. commit atıldı.
                self.courseActivityIndicator.stopAnimating()//indirme bitince durdur.

            }
        }
        
        UserViewModel().downloadUserFromFirestore(userMail: item.dealerMail){
            user in
            self.courseDealerLabel.text = user.fullName
        }
        
        
    }

    private func setItemImageViewUI(){
        courseImageView.layer.cornerRadius = courseImageView.frame.size.width / 8
        courseImageView.clipsToBounds = true
        courseImageView.contentMode = .scaleAspectFill
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
