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
    
    var rightBarButtonItem:UIBarButtonItem!
    var item:Item?
    
    var itemVM = ItemViewModel()
    var userVM = UserViewModel()
    var cartVM = CartViewModel()
    var likedVM = LikedViewModel()
    var reviewVM = ReviewViewModel()
    
    var liked:Liked!
    var allItemsInCart:[Item] = []
    var isItemLikedBefore:Bool = false
    var isItemPurchasedBefore:Bool = false
    
    var itemContent:[String] = [String]()
    var reviewContent:[Review] = [Review]()
    
    private let minimumTapInterval = CFTimeInterval(4)
    private var lastTapTime = CFAbsoluteTime(0)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadPurchasedItem()
        profileActiviyIndicator.hidesWhenStopped = true
        profileActiviyIndicator.startAnimating()
        itemContentTableView.dataSource = self
        setupUI()
    }
 
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        loadPurchasedItem()
        if Connectivity.isInternetAvailable(){
            setItemContent()
            loadLikedFromFirebase(loggedUser: UserViewModel.currentUser())
        }else{
            Alert.createAlert(title: Alert.noConnectionTitle, message: Alert.noConnectionMessage, view: self)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "itemToReview"{
            let itemReviewVC = segue.destination as! ItemReviewsViewController
            itemReviewVC.item = sender as? Item
        }
    }
    
    @IBAction func addCartButtonPressed(_ sender: Any) {
        let now = CFAbsoluteTimeGetCurrent()
        guard now >= lastTapTime + minimumTapInterval else { return }
        lastTapTime = now
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        if Connectivity.isInternetAvailable(){
            self.checkLoginStatusForItemVC()
        }else{
            Alert.createAlert(title: Alert.noConnectionTitle, message: Alert.noConnectionMessage, view: self)
        }
    }
    
    @IBAction func reviewButtonPressed(_ sender: Any) {
        performSegue(withIdentifier: "itemToReview", sender: item)
    }
}

//MARK: - Login/Logut
extension ItemViewController{
    
    private func containsMatchingString(target: String, in array: [String]) -> Bool {
        return array.contains(target)
    }
    
    private func checkLoginStatusForItemVC(){
        let loggedUser = UserViewModel.currentUser()
        if loggedUser == nil {//oturum açan kullanıcı yok
            showLogin()//kullanıcıyı login ekranına taşı
        }else {//oturum açan kullanıcı var. Mevcut sepetine ürünü ekle
            if loggedUser?.email != item?.dealerMail{
                if containsMatchingString(target: item!.id!, in: UserViewModel.currentUser()!.purchasedItemIds) {
                    Alert.createAlert(title: "Bilgilendirme", message: "Bu ürünü daha önceden satın aldınız.", view: self)
                }else{
                    self.cartVM.downloadCartFromFirestore(loggedUser!.email!){ [self] cart in
                        if cart == nil {
                            cartVM.createNewCart(item: item!,ownerId: loggedUser!.email!)
                            Alert.createAlert(title: "Başarılı", message: "Kurs Sepete Eklendi!", view: self)
                        }else {
                            if containsMatchingString(target: self.item!.id!, in: cart!.itemIds){
                                Alert.createAlert(title: "Bilgilendirme", message: "Bu kursu zaten sepete eklediniz!", view: self)
                            }else{
                                cart!.itemIds.append(self.item!.id)
                                self.updateCart(cart:cart!,withValues:[FirebaseConstants().kITEMIDS:cart!.itemIds])
                                self.tabBarController!.tabBar.items![2].badgeValue = "\(cart!.itemIds.count)"
                            }
                        }
                    }
                }
            }else{
                Alert.createAlert(title: "Bilgilendirme", message: "Kendi kursunuzu sepetinize ekleyemezsiniz!", view: self)
            }
        }
    }
    
    private func showLogin(){
        let itemVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "loginVC") as! WelcomeViewController
        self.navigationController?.pushViewController(itemVC, animated: true)
    }
}
//MARK: - Functions
extension ItemViewController{
    
    func setupUI(){
        itemOwnerProfileImageView.setImageViewFrame(cornerRadius: itemOwnerProfileImageView.frame.size.width/2)
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "chevron.backward"), style: .plain, target: self, action: #selector(self.turnBackToPage))
        createRightBarButtonItem()
    }
    
    func loadPurchasedItem(){
        itemVM.downloadPurchasedItems([item!.id!]){ allItems in
            if allItems.isEmpty{
                self.isItemPurchasedBefore = false
            }else{
                self.isItemPurchasedBefore = true
            }
        }
    }
    
    func setItemContent(){
        itemImageView.contentMode = .scaleAspectFill
        itemDescriptionLabel.isEditable = false
        if let item = item{
            itemNameLabel.text = item.name
            itemOwnerLabel.text = "sd"
            itemOwnerProfileImageView.image = UIImage(named: "person.circle")
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
            setHeartBarButtonItem()
            
            reviewVM.downloadReviewsFromFirebase(itemID: item.id){
                reviews in
                
                self.reviewContent = reviews

                self.setReview()
            }
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
    
    private func showFullScreenImage(image: UIImage?) {
        guard let image = image else { return }
        
        let fullScreenImageView = UIImageView(image: image)
        fullScreenImageView.frame = self.view.frame
        fullScreenImageView.backgroundColor = .white
        fullScreenImageView.contentMode = .scaleAspectFit
        fullScreenImageView.isUserInteractionEnabled = true
        
        let dismissTapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissFullScreenImage))
        fullScreenImageView.addGestureRecognizer(dismissTapGesture)
        
        self.view.addSubview(fullScreenImageView)
        
        fullScreenImageView.alpha = 0
        UIView.animate(withDuration: 0.3) {
            fullScreenImageView.alpha = 1
        }
    }

}
//MARK: - UITableViewDataSource
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
//MARK: - Liked
extension ItemViewController{
 
    private func loadLikedFromFirebase(loggedUser:User?){//
        if loggedUser == nil{
            print("oturum açmış kullanıcı yok")
        }else{
            likedVM.downloadLikedFromFirestore(loggedUser!.email!){ liked in
                self.liked = liked
            }
        }
    }

    private func updateLiked(liked:Liked,withValues:[String:Any]){
        
        likedVM.updateLikedInFirestore(liked, withValues: withValues){ error in
            if error != nil{
                print("liked güncellenemedi")
            }else{
                print("liked güncellendi")
            }
        }
    }
    
    private func removeItemFromLiked(itemId:String){//tablevie' dataosruce'dan sildik şimdi sepet'den silcez.
        for i in 0...(liked?.itemIds.count)! {// sepetteki ürün sayısı kadar git
            print("liked beğenilen item sayısı:\(liked?.itemIds.count)")
            if itemId == liked?.itemIds[i] {//silinen item id'si ile sepetteki id'leri eşle
                liked?.itemIds.remove(at: i)//sepetteki itemi sil
                return
            }
        }
    }
    private func createRightBarButtonItem(){
        rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "heart"), style: .done, target: self, action: #selector(rightBarButtonItemPressed))
        rightBarButtonItem.tintColor = .red
        navigationItem.rightBarButtonItems![1] = rightBarButtonItem
    }
    
    private func setHeartFill(){
        self.navigationItem.rightBarButtonItems![1].image = UIImage(systemName: "heart.fill")
    }
    
    private func setHeartNoFill(){
        self.navigationItem.rightBarButtonItems![1].image = UIImage(systemName: "heart")
    }
    
    private func setHeartBarButtonItem(){
        
        if UserViewModel.currentUser() == nil{
            navigationItem.rightBarButtonItems![1].isHidden = true
        }else{
            navigationItem.rightBarButtonItems![1].isHidden = false
            setHeartNoFill()
            isItemLikedBefore = false//ürün default değenilmedi olarak sayılsın
            likedVM.checkIsItemLikedBefore(UserViewModel.currentUser()!.email!, item: item!){
                isLiked,error in
                if error != nil{
                    print("hata var sepet bulunamadı")
                }else{
                    if isLiked{
                        print("ürün beğenilmiş")
                        self.isItemLikedBefore = true
                        self.setHeartFill()
                    }else{
                        print("ürün beğenilmemeiş")
                        self.isItemLikedBefore = false
                        self.setHeartNoFill()
                    }
                }
            }
        }
    }

}
//MARK: - OBJC
extension ItemViewController {
    
    @objc func rightBarButtonItemPressed(){
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        let now = CFAbsoluteTimeGetCurrent()
        guard now >= lastTapTime + minimumTapInterval else { return }
        lastTapTime = now
        
        if Connectivity.isInternetAvailable(){
            let loggedUser = UserViewModel.currentUser()
            
            if loggedUser?.email != item?.dealerMail{
                if isItemLikedBefore{//daha önceden beğenildi ise yeniden tıklamada beğeniyi kaldır
                    setHeartNoFill()
                    isItemLikedBefore = false
                    loadLikedFromFirebase(loggedUser: loggedUser)
                    DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2)){
                        self.removeItemFromLiked(itemId: self.item!.id)//sepetten kaldır
                        self.updateLiked(liked: self.liked, withValues: [FirebaseConstants().kITEMIDS:self.liked!.itemIds])
                    }
                }else{
                    isItemLikedBefore = true
                    setHeartFill()
                    likedVM.downloadLikedFromFirestore(loggedUser!.email!){ [self] liked in
                        if liked == nil {
                            likedVM.createNewLiked(item: item!,ownerId: loggedUser!.email!)
                            setHeartFill()
                            self.isItemLikedBefore = true
                        }else {
                            liked!.itemIds.append(self.item!.id)
                            self.updateLiked(liked:liked!,withValues:[FirebaseConstants().kITEMIDS:liked!.itemIds])
                            setHeartFill()
                            self.isItemLikedBefore = true
                        }
                    }
                }
            }else{
                Alert.createAlert(title: "Bilgilendirme", message: "Satışa sunduğunuz ürününüzü beğeni listenize ekleyemezsiniz!", view: self)
            }
        }else{
            Alert.createAlert(title: Alert.noConnectionTitle, message: Alert.noConnectionMessage, view: self)
        }
        
    }
    
    @objc func dismissFullScreenImage(_ sender: UITapGestureRecognizer) {
        if let fullScreenImageView = sender.view {
            UIView.animate(withDuration: 0.3, animations: {
                fullScreenImageView.alpha = 0
            }) { _ in
                fullScreenImageView.removeFromSuperview()
            }
        }
    }
    
    @objc func turnBackToPage(){
        self.navigationController?.popViewController(animated: true)
    }
}
//MARK: - Reviews
extension ItemViewController{
    
    func setReview(){
        
        var totalPoint = 0
        for review in reviewContent{
            totalPoint += Int(review.point!)!
            
        }
        
        if reviewContent.count != 0 {
            itemPoint.text = String(format: "%.1f", Double(totalPoint) / Double(reviewContent.count))
            itemPointProgressView.setProgress(Float(Double(totalPoint) / Double(reviewContent.count))/5, animated: true)
            
        }else{
            itemPoint.text = "0.0"
            itemPointProgressView.setProgress(0.0, animated: true)
            
        }
       

    }
}

