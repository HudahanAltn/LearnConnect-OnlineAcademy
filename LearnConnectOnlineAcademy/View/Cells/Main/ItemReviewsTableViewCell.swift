//
//  ItemReviewsTableViewCell.swift
//  LearnConnectOnlineAcademy
//
//  Created by Hüdahan Altun on 26.11.2024.
//

import UIKit

class ItemReviewsTableViewCell: UITableViewCell {

    @IBOutlet weak var cellLoadActivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var profileActivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var commentTextView: UITextView!
    
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
        profileImageView.image = nil
        userNameLabel.text = nil
        commentTextView.text = nil
    }

    private func setCellUI(){
        self.backgroundColor = .clear
        commentTextView.isEditable = false
        profileActivityIndicator.hidesWhenStopped = true
        cellLoadActivityIndicator.hidesWhenStopped = true
        accessoryType = .disclosureIndicator
        let customSelectionColor = UIView()
        customSelectionColor.backgroundColor = .systemGreen
        self.selectedBackgroundView = customSelectionColor
    }
    
    func createItemsCell(_ review:Review){
        
        profileActivityIndicator.startAnimating()
        cellLoadActivityIndicator.startAnimating()
     
        print("review:\(review.ownerId)")
        UserViewModel().downloadUserFromFirestore(userMail: review.ownerId){
            user in
            
            self.userNameLabel.text = user.fullName
            StorageManager().downloadImage(imageUrl: user.profilePicture!){//resmi firebase'den getir.
                image in
                
                DispatchQueue.main.async {
                    self.profileImageView.image = image
                    self.profileActivityIndicator.stopAnimating()
                }
                
            }
        }
        
        commentTextView.text = review.comment!
    
        
    }

    private func setItemImageViewUI(){
        profileImageView.layer.cornerRadius = profileImageView.frame.size.width / 8
        profileImageView.clipsToBounds = true
        profileImageView.contentMode = .scaleAspectFill
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
