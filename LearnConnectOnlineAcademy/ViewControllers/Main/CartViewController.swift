//
//  CartViewController.swift
//  LearnConnectOnlineAcademy
//
//  Created by Hüdahan Altun on 23.11.2024.
//

import UIKit
import EmptyDataSet_Swift
class CartViewController: UIViewController {

    @IBOutlet weak var cartTableView: UITableView!
    @IBOutlet weak var priceButton: UIButton!
    @IBOutlet weak var checkOutButton: UIButton!
    
    var rightBarButtonItem:UIBarButtonItem!
    
    var cartVM = CartViewModel()
    var cartHelper = CartHelper()
    var cart:Cart?
    var allItemsInCart:[Item] = []//Sepetteki ürünleri tutan liste
    var purchasedItemIds:[String] = []//satın alınacak ürünlerin id'lerini tutan liste

    var isDeliveryVCOpen:Bool = false
    var isUserPurchasedCourse:Bool = false
    
    private let minimumTapInterval = CFTimeInterval(4)
    private var lastTapTime = CFAbsoluteTime(0)
    
    override func viewDidLoad() {
        super.viewDidLoad()

        cartTableView.delegate = self
        cartTableView.dataSource = self
        cartTableView.emptyDataSetSource = self
        cartTableView.emptyDataSetDelegate = self
        setupUI()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        print("kurs ödemesi yapıldımı : \(isUserPurchasedCourse)")
        NotificationCenter.default.addObserver(self, selector: #selector(self.userPaid(notification:)), name: .notificaitonName, object: nil)
        cartTableView.reloadData()
        checkLoginStatusForCartVC()
        isDeliveryVCOpen = false
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "cartToPayment"{
            if let price = sender as? String{
                
                let destinationVC = segue.destination as! PaymentViewController
                destinationVC.totalPrice = price
            }
        }
    }
    
    @IBAction func priceButtonPressed(_ sender: Any) {
        
        if isDeliveryVCOpen{//kargo vc açık.o zaman vc'yi kapat
            priceButton.setImage(UIImage(systemName: "chevron.up"), for: .normal)
            isDeliveryVCOpen = false
          
        }else{//kapalı.o zaman vcyi aç
            priceButton.setImage(UIImage(systemName: "chevron.down"), for: .normal)
            isDeliveryVCOpen = true
          
        }
    }
    
    
    @IBAction func checkOutButtonPressed(_ sender: Any) {
        if Connectivity.isInternetAvailable(){
            print("cart: \(cart?.itemIds.count)")
            
            if cart?.itemIds!.count == 0 || cart == nil {
                Alert.createAlert(title: "Bilgilendirme", message: "Öncelikle Sepetinize Ürün Ekleyin", view: self)
            }else{
                performSegue(withIdentifier: "cartToPayment", sender: priceButton.titleLabel?.text)
            }
        }else{
            Alert.createAlert(title: Alert.noConnectionTitle, message: Alert.noConnectionMessage, view: self)

        }
    }
}

//MARK: - CartVC Login/LogOut
extension CartViewController{
    
    private func setupUI(){
        cartTableView.backgroundColor = .clear
        cartTableView.separatorStyle = .none
        checkOutButton.layer.cornerRadius = 10
        priceButton.setImage(UIImage(systemName: "chevron.up"), for: .normal)
        priceButton.layer.borderColor = UIColor.systemGreen.cgColor
        priceButton.layer.borderWidth = 0.5
        priceButton.layer.cornerRadius = 10
    }
    
    private func checkLoginStatusForCartVC(){//kullanıcın oturum açma durumunu kontrol et
        let loggedUser = UserViewModel.currentUser()
        
        if loggedUser == nil {//oturum açan kullanıcı yok
            allItemsInCart.removeAll()
            cartTableView.reloadData()
            updateTotalLabels(true)
            cartHelper.setAlphaValue(value: 0, views: priceButton,checkOutButton)
            navigationItem.rightBarButtonItem?.isHidden = true
        }else {//oturum açan kullanıcı var.
            if Connectivity.isInternetAvailable(){ //sepeti görüntülemek için internete bağlan
                if isUserPurchasedCourse{// kullanıcı payment ile ödeme yapmış ise
                    isUserPurchasedCourse = false
                    NotificationCenter.default.removeObserver(self, name: .notificaitonName, object: nil)
                    let price = priceButton.titleLabel?.text
                    Alert.createAlert(title: "Başarılı", message: "Kurs başarıyla satın alındı!", view: self)
                    addItemToPurchasedListFromCart()//sepetteki ürünleri satın alınanlar listesine ekle
                    addItemsToPurchasedList(self.purchasedItemIds)//sepettekileri kullanıcın satın alınanlarına ekle
                    emptyCart()//sepeti ve satın alınanlar listesini boşalt
                    self.tabBarController!.tabBar.items![2].badgeValue = "0"
                    self.tabBarController!.tabBar.items![2].badgeColor = .clear
                }else{//ödeme yapmadıysa normal sepeti getir
                    loadCartFromFirebase(loggedUser: loggedUser)//kullanıcın sepetini getir.
                    cartHelper.setAlphaValue(value: 1, views: priceButton,checkOutButton)
                    priceButton.setTitle(returnCartTotalPrice(), for: .normal)
                    createRightBarButtonItem(title: "Ödeme")
                    navigationItem.rightBarButtonItem?.isHidden = false
                }
            }else{
                allItemsInCart.removeAll()
                cartTableView.reloadData()
                priceButton.setTitle(returnCartTotalPrice(), for: .normal)
                self.navigationItem.title = "Sepetim (0 Ürün)"
                Alert.createAlert(title: Alert.noConnectionTitle, message: Alert.noConnectionMessage, view: self)
            }
        }
    }
    
    private func createRightBarButtonItem(title:String){
        rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "trash"), style: .done, target: self, action: #selector(rightBarButtonItemPressed))
        rightBarButtonItem.tintColor = .black
        navigationItem.rightBarButtonItem = rightBarButtonItem
    }
    
    
    private func updateTotalLabels(_ isEmpty:Bool){
        if isEmpty {
            self.navigationItem.title = "Sepetim (0 Ürün)"
           
        }else {
            self.navigationItem.title = "Sepetim (\(allItemsInCart.count) Ürün)"
            
            priceButton.setTitle(returnCartTotalPrice(), for: .normal)
            
        }
    }
    
    private func returnCartTotalPrice()->String{// price güncelle
        var totalPrice = 0.0
        for item in allItemsInCart {
            totalPrice += item.price
        }
        return LocalCurrency().convertCurrency(totalPrice)
    }

}
//MARK: - UITableViewDelegate
extension CartViewController:UITableViewDelegate{
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        tableView.deselectRow(at: indexPath, animated: true)
        let itemVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "itemVC") as! ItemViewController
        itemVC.item = allItemsInCart[indexPath.row]
        self.navigationController?.pushViewController(itemVC, animated: true)
    }
    
   
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let delete = UIContextualAction(style: .destructive, title: "Sil"){ _,_,_ in

            let deletedItem = self.allItemsInCart.remove(at: indexPath.row)
            tableView.reloadData()
            self.removeItemFromCart(itemId: deletedItem.id)
            self.cartVM.updateCartInFirestore(self.cart!, withValues: [FirebaseConstants().kITEMIDS:self.cart!.itemIds]){ error in
                if error != nil {
                    print("günc hatası")
                }
                self.loadItemsFromCart()
            }
        }
        return UISwipeActionsConfiguration(actions: [delete])
    }
}
//MARK: - UITableViewDataSource
extension CartViewController:UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allItemsInCart.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cartCell = tableView.dequeueReusableCell(withIdentifier: "cartCell",for:indexPath) as! CartTableViewCell
        cartCell.createItemsCell(allItemsInCart[indexPath.row])
        cartCell.runCellAnimation()
        return cartCell
    }
}
//MARK: - LoadCart From Backend
extension CartViewController{
    
    private func loadCartFromFirebase(loggedUser:User?){//
        cartVM.downloadCartFromFirestore(loggedUser!.email!){ cart in// kullanıcının sepetini indir.
            self.cart = cart
            self.loadItemsFromCart()//sepetteki itemleri getir.
        }
    }
    
    private func loadItemsFromCart(){//sepetteki itemleri getir.
        if cart != nil{
            cartVM.downloadItemsForCart(cart!.itemIds){ allItems in//sepetteki itemleri getir.
                self.allItemsInCart.removeAll()
                self.allItemsInCart = allItems
                self.cartTableView.reloadData()
                self.updateTotalLabels(false)
                self.tabBarController!.tabBar.items![2].badgeValue = "\(allItems.count)"
                self.tabBarController!.tabBar.items![2].badgeColor = .red
            }
        }
    }
}
//MARK: - CartHelper
extension CartViewController{
    private func addItemToPurchasedListFromCart(){
        for item in allItemsInCart{
            purchasedItemIds.append(item.id)
        }
    }
    
    private func emptyCart(){//sepeti boşalt
        allItemsInCart.removeAll()//
        purchasedItemIds.removeAll()//
        cartTableView.reloadData()
        cart?.itemIds = []
        cartVM.updateCartInFirestore(cart!, withValues: [FirebaseConstants().kITEMIDS:cart?.itemIds]){ error in
            if error == nil{//güncelleme başarılı
                self.loadItemsFromCart()
            }else{
                print("cart güncellenirken hata oldu")
            }
        }
    }
 
    private func addItemsToPurchasedList(_ itemIds:[String]){
        let newItemIds = UserViewModel.currentUser()!.purchasedItemIds + itemIds
        UserViewModel.updateUser(withValues: [FirebaseConstants().kPURCHASEDITEMIDS:newItemIds]){ error in
            if error == nil{
                print("günc başarılı")
            }else{
                print("kullanıcı günc hataso")
            }
        }
    }
    
    private func removeItemFromCart(itemId:String){//tablevie' dataosruce'dan sildik şimdi sepet'den silcez.
        for i in 0...(cart?.itemIds.count)! {// sepetteki ürün sayısı kadar git
            if itemId == cart?.itemIds[i] {//silinen item id'si ile sepetteki id'leri eşle
                cart?.itemIds.remove(at: i)//sepetteki itemi sil
                return
            }
        }
    }
}
//MARK: - OBJC
extension CartViewController{
   
    @objc func userPaid(notification:NSNotification){
        isUserPurchasedCourse = notification.userInfo?["message"] as! Bool
    }
   
   @objc func rightBarButtonItemPressed(){
       UIImpactFeedbackGenerator(style: .medium).impactOccurred()
       
       if Connectivity.isInternetAvailable(){
           if cart?.itemIds!.count == 0 || cart == nil {
               Alert.createAlert(title: "Bilgilendirme", message: "Sepette zaten mevcut kurs yok!", view: self)
           }else{
               let alertController = UIAlertController(title: "Uyarı", message: "Sepetinizdeki tüm kurslar silinecektir!", preferredStyle: .alert)
               
               let OKButton = UIAlertAction(title: "Sil", style: .destructive){ _ in
                   self.allItemsInCart.removeAll()//data source'dan seçili itemi'i sil
                   self.cartTableView.reloadData()//reload
                   self.cart?.itemIds.removeAll()//sepetten kaldır
                   self.cartVM.updateCartInFirestore(self.cart!, withValues: [FirebaseConstants().kITEMIDS:self.cart!.itemIds]){ error in
                       if error != nil {
                           print("günc hatası")
                       }
                       self.loadItemsFromCart()
                   }
               }
               
               let cancelButton = UIAlertAction(title: "İptal", style: .cancel)
               alertController.addAction(OKButton)
               alertController.addAction(cancelButton)

               self.present(alertController, animated: true)
           }
       }else{
           Alert.createAlert(title: Alert.noConnectionTitle, message: Alert.noConnectionMessage, view: self)
       }
   }
}
//MARK: - UITableViewEmpty
extension CartViewController:EmptyDataSetSource,EmptyDataSetDelegate{
    
    func title(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
        
        if Connectivity.isInternetAvailable(){
            return NSAttributedString(string: "Sepette kurs bulunamadı!")
        }else{
            return NSAttributedString(string: "İnternet bağlantısı mevcut değil!")
        }
        
    }
    
    func image(forEmptyDataSet scrollView: UIScrollView) -> UIImage? {
        
        
        if Connectivity.isInternetAvailable(){
            return UIImage(named:"emptyCart")
        }else{
            return UIImage(named: "noWifi")
        }
        
    }
    
    func description(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
        if UserViewModel.currentUser() != nil{
            if Connectivity.isInternetAvailable(){
                return NSAttributedString(string: "Sepetenize kurs ekleyiniz.")
            }else{
                return NSAttributedString(string: "Sepeti görüntülemek için internet bağlantısı gerekmektedir!")
            }
        }else{
            if Connectivity.isInternetAvailable(){
                return NSAttributedString(string: "Sepeti görüntülemek için giriş yapılmalıdır!")
            }else{
                return NSAttributedString(string: "Sepeti görüntülemek için internet bağlantısı gerekmektedir!")
            }
        }
        
        
    }
    
 
}
