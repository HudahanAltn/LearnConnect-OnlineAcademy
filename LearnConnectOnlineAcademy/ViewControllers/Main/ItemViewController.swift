//
//  ItemViewController.swift
//  LearnConnectOnlineAcademy
//
//  Created by Hüdahan Altun on 23.11.2024.
//

import UIKit

class ItemViewController: UIViewController {

    
    @IBOutlet weak var itemImageView: UIImageView!
    @IBOutlet weak var itemNameLabel: UILabel!
    @IBOutlet weak var itemOwnerLabel: UILabel!
    @IBOutlet weak var itemOwnerProfileImageView: UIImageView!
    @IBOutlet weak var profileActiviyIndicator: UIActivityIndicatorView!
    @IBOutlet weak var itemPoint: UILabel!
    @IBOutlet weak var itemPointProgressView: UIProgressView!
    @IBOutlet weak var itemPriceLabel: UILabel!
    @IBOutlet weak var itemDescriptionLabel: UITextView!
    @IBOutlet weak var itemContentTableView: UITableView!
    
    var item:Item?
    var itemVM = ItemViewModel()
    var userVM = UserViewModel()
    var cartVM = CartViewModel()
    var itemContent:[String] = [String]()
    
    
    private let minimumTapInterval = CFTimeInterval(4)
    private var lastTapTime = CFAbsoluteTime(0)
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        profileActiviyIndicator.hidesWhenStopped = true
        profileActiviyIndicator.startAnimating()
        itemContentTableView.dataSource = self
        
        itemOwnerProfileImageView.setImageViewFrame(cornerRadius: itemOwnerProfileImageView.frame.size.width/2)

        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "chevron.backward"), style: .plain, target: self, action: #selector(self.turnBackToPage))
    }
 
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        if Connectivity.isInternetAvailable(){
            setItemContent()
        }else{
            Alert.createAlert(title: Alert.noConnectionTitle, message: Alert.noConnectionMessage, view: self)

        }
        
    }

    func setItemContent(){
        itemImageView.contentMode = .scaleAspectFill
        itemDescriptionLabel.isEditable = false
        if let item = item{
            itemNameLabel.text = item.name
            itemOwnerLabel.text = "sd"
            itemOwnerProfileImageView.image = UIImage(named: "person.circle")
            itemPoint.text = "4.5"
            itemPointProgressView.progress = 0.5
            itemPriceLabel.text = "₺\(item.price!)"
            itemDescriptionLabel.text = item.description
            
            userVM.downloadUserFromFirestore(userMail: item.dealerMail){
                user in
                
                self.itemOwnerLabel.text = user.fullName
                StorageManager().downloadImage(imageUrl: user.profilePicture!){//resmi firebase'den getir.
                    image in
                    
                    DispatchQueue.main.async {
                        self.itemOwnerProfileImageView.image = image
                        self.profileActiviyIndicator.stopAnimating()
                    }
                    
                }
            }
            StorageManager().downloadImage(imageUrl: item.imageLink){
                image in
                
                DispatchQueue.main.async {
                    self.itemImageView.image = image
                    
                }
            }
            StorageManager().fetchVideoNames(itemId: item.id){
                names in
                self.itemContent =  names
                print("video: \(self.itemContent[0])")
                self.itemContentTableView.reloadData()

            }
        }
    }

    @IBAction func addCartButtonPressed(_ sender: Any) {
    
        let now = CFAbsoluteTimeGetCurrent()
        guard now >= lastTapTime + minimumTapInterval else { return }
        lastTapTime = now
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        if UserViewModel.currentUser()?.email != item?.dealerMail{
            checkLoginStatusForItemVC()
        }else{
            Alert.createAlert(title: "Bilgilendirme", message: "Kendi Ürününüzü Sepete Ekleyemezsiniz", view: self)
        }
       
    }
    

    private func updateCart(cart:Cart,withValues:[String:Any]){
        cartVM.updateCartInFirestore(cart, withValues: withValues){ error in
            if error != nil{
                Alert.createAlert(title: "Hata", message: error!.localizedDescription, view: self)
            }else{
                Alert.createAlert(title: "Başarılı", message: "Ürün Sepete Eklendi", view: self)
            }
        }
    }
}

extension ItemViewController{
    
    private func checkLoginStatusForItemVC(){
        let loggedUser = UserViewModel.currentUser()
        if loggedUser == nil {//oturum açan kullanıcı yok
            showLogin()//kullanıcıyı login ekranına taşı
        }else {//oturum açan kullanıcı var. Mevcut sepetine ürünü ekle
            if loggedUser?.email != item?.dealerMail{
                cartVM.downloadCartFromFirestore(loggedUser!.email!){ [self] cart in
                    if cart == nil {
                        cartVM.createNewCart(item: item!,ownerId: loggedUser!.email!)
                        Alert.createAlert(title: "Başarılı", message: "Ürün Sepete Eklendi!", view: self)
//                        DispatchQueue.main.asyncAfter(deadline: .now() + 4){
//                            self.tabBarController!.tabBar.items![2].badgeValue = "\(cart!.itemIds.count)"
//                        }
                        
                    }else {
                        cart!.itemIds.append(self.item!.id)
                        self.updateCart(cart:cart!,withValues:[FirebaseConstants().kITEMIDS:cart!.itemIds])
                        self.tabBarController!.tabBar.items![1].badgeValue = "\(cart!.itemIds.count)"
                    }
                }
            }else{
                Alert.createAlert(title: "Bilgilendirme", message: "Satışa sunduğunuz ürünü sepetinize ekleyemezsiniz!", view: self)
            }
        }
    }
    
    private func showLogin(){
        let itemVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "loginVC") as! WelcomeViewController
        self.navigationController?.pushViewController(itemVC, animated: true)
    }
}

extension ItemViewController:UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemContent.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let itemContentCell = tableView.dequeueReusableCell(withIdentifier: "itemContentCell", for: indexPath) as! ItemContentTableViewCell
        
        if let prefix = itemContent[indexPath.row].components(separatedBy: ".").first {
            itemContentCell.itemContentLabel.text = "\(indexPath.row + 1))\(prefix)"
        }

        return itemContentCell
    }
    
    
    
}

extension ItemViewController{
    
    @objc func turnBackToPage(){
        self.navigationController?.popViewController(animated: true)
    }
}

