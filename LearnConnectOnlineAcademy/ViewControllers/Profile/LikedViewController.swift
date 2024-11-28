//
//  LikedViewController.swift
//  LearnConnectOnlineAcademy
//
//  Created by Hüdahan Altun on 26.11.2024.
//

import UIKit
import EmptyDataSet_Swift

class LikedViewController: UIViewController {

    @IBOutlet weak var userProfilePictureImageView: UIImageView!
    
    @IBOutlet weak var profileActivityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var userNameLabel: UILabel!
    
    @IBOutlet weak var itemsInLikedLabel: UILabel!
    
    @IBOutlet weak var likedItemsTableView: UITableView!
    var likedItems:[Item] = [Item]()
    var likedVM = LikedViewModel()
    
    var liked:Liked?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        likedItemsTableView.delegate = self
        likedItemsTableView.dataSource = self
        likedItemsTableView.emptyDataSetSource = self
        likedItemsTableView.emptyDataSetDelegate = self
        profileActivityIndicator.hidesWhenStopped = true
        userProfilePictureImageView.setImageViewFrame(cornerRadius: userProfilePictureImageView.frame.size.width / 2)
        loadUserDetails()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        print("liketvcgörüncek")
        let loggedUser = UserViewModel.currentUser()
        
        likedItems.removeAll()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1){
            self.loadLikedFromFirebase(loggedUser: loggedUser!)
        }
        
    }
    
    func loadUserDetails(){
        profileActivityIndicator.startAnimating()
        StorageManager().downloadImage(imageUrl: UserViewModel.currentUser()!.profilePicture!){//resmi firebase'den getir.
            image in
            DispatchQueue.main.async {
                self.userProfilePictureImageView.image = image
                self.profileActivityIndicator.stopAnimating()

            }
            
        }
        userNameLabel.text = "\(UserViewModel.currentUser()!.fullName)"
    }

}

//MARK: - LikedHelper
extension LikedViewController{
    
    private func loadLikedFromFirebase(loggedUser:User?){//
        likedVM.downloadLikedFromFirestore(loggedUser!.email!){ liked in//oturum açan kullanıcının sepetini indir.
            self.liked = liked
            self.loadItemsFromLiked()//sepetteki itemleri getir.
        }
    }
    
    private func loadItemsFromLiked(){//sepetteki itemleri getir.
        if liked != nil{
            likedVM.downloadItemsForLiked(liked!.itemIds){ allItems in//sepetteki itemleri getir.
                self.likedItems = allItems
                self.likedItemsTableView.reloadData()
                self.itemsInLikedLabel.text = "\(self.likedItems.count) Adet Beğenilen Ürün"
            }
        }
    }
    
    private func removeItemFromLiked(itemId:String){//tablevie' dataosruce'dan sildik şimdi sepet'den silcez.
        for i in 0...(liked?.itemIds.count)! {// sepetteki ürün sayısı kadar git
            if itemId == liked?.itemIds[i] {//silinen item id'si ile sepetteki id'leri eşle
                liked?.itemIds.remove(at: i)//sepetteki itemi sil
                return
            }
        }
    }
    
    func approveDeleteAlert(indexPath:IndexPath){
        let alertController = UIAlertController(title: "Kaldır", message: "Seçili ürünü beğeni listenizden kaldırmak istediğinizden eminmisin ?", preferredStyle: .alert)
        
        let OKButton = UIAlertAction(title: "Sil", style: .destructive){ _ in
            
            let deletedItem = self.likedItems.remove(at: indexPath.row)//data source'dan seçili itemi'i sil
            self.likedItemsTableView.reloadData()//reload
            self.removeItemFromLiked(itemId: deletedItem.id)//sepetten kaldır
        
            self.likedVM.updateLikedInFirestore(self.liked!, withValues: [FirebaseConstants().kITEMIDS:self.liked!.itemIds]){ error in
                if error != nil {
                    print("günc hatası")
                }
                self.loadItemsFromLiked()
            }
        }
        let cancelButton = UIAlertAction(title: "İptal", style: .cancel){_ in
            print("iptal tıklandı")
            self.view.endEditing(true)
        }
        
        alertController.addAction(OKButton)
        alertController.addAction(cancelButton)
        
        self.present(alertController, animated: true)
    }
    
}
//MARK: -UITableViewDelegate
extension LikedViewController:UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let itemVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "itemVC") as! ItemViewController
        itemVC.item = likedItems[indexPath.row]
        self.navigationController?.pushViewController(itemVC, animated: true)
    }

    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let delete = UIContextualAction(style: .destructive, title: "Sil"){ _,_,_ in
            self.approveDeleteAlert(indexPath: indexPath)
        }
        return UISwipeActionsConfiguration(actions: [delete])
    }
    
}
//MARK: - UITableViewDataSource
extension LikedViewController:UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return likedItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LikedCell",for:indexPath) as! LikedTableViewCell
        cell.createLikedItemsCell(likedItems[indexPath.row])
        return cell
    }
}
//MARK: - EmptyData
extension LikedViewController:EmptyDataSetSource,EmptyDataSetDelegate{
    
    func title(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
        
        return NSAttributedString(string: "Beğenilen kurs bulunamadı!")
    }
    
    func image(forEmptyDataSet scrollView: UIScrollView) -> UIImage? {
        
        return UIImage(named: "heart")
    }
  
}

