//
//  ProfileViewController.swift
//  LearnConnectOnlineAcademy
//
//  Created by Hüdahan Altun on 22.11.2024.
//

import UIKit

class ProfileViewController: UIViewController {

    @IBOutlet weak var welcomeLabel: UILabel!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var userProfilePictureImageView: UIImageView!
    @IBOutlet weak var profileActivityIndicator: UIActivityIndicatorView!
    
    
    @IBOutlet weak var settingsView: UIView!
    @IBOutlet weak var purchasedHistory: UIButton!
    @IBOutlet weak var addItemButton: UIButton!
    @IBOutlet weak var likedItemsButton: UIButton!
    @IBOutlet weak var onSaleButton: UIButton!
    @IBOutlet weak var notificationsButton: UIButton!
    @IBOutlet weak var contactUsButton: UIButton!
    @IBOutlet weak var settingsButton: UIButton!
    @IBOutlet weak var logoutButton: UIButton!
    
    var rightBarButtomItem:UIBarButtonItem!
    var profileHelper = ProfileHelper()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        userProfilePictureImageView.setImageViewFrame(cornerRadius: userProfilePictureImageView.frame.size.width/2)
        profileActivityIndicator.hidesWhenStopped = true
        profileHelper.setButtonCornerRadius(value: 8.0, views: purchasedHistory,onSaleButton,likedItemsButton,notificationsButton,contactUsButton,settingsButton,addItemButton,logoutButton)
        profileHelper.setButtonBackgroundColorColor(value: 0.7, color: .white, buttons: purchasedHistory,onSaleButton,likedItemsButton,notificationsButton,contactUsButton,settingsButton,addItemButton,logoutButton)
    }
    
   

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
      
        if traitCollection.userInterfaceStyle == .dark {
            profileHelper.setButtonBorderColor(value: 1.0, color: .white, buttons: purchasedHistory,onSaleButton,likedItemsButton,notificationsButton,contactUsButton,settingsButton,addItemButton,logoutButton)
        } else {
            profileHelper.setButtonBackgroundColorColor(value: 0.7, color: .white, buttons: purchasedHistory,onSaleButton,likedItemsButton,notificationsButton,contactUsButton,settingsButton,addItemButton,logoutButton)
        }
        checkLoginStatus()
        //kullanıcı login durumunu check et böylece bu sayfadaki görsenl nesleer görünür olcak veya olmayacak
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            if traitCollection.userInterfaceStyle == .dark {
                profileHelper.setButtonBorderColor(value: 1.0, color: .white, buttons: purchasedHistory,onSaleButton,likedItemsButton,notificationsButton,contactUsButton,settingsButton,addItemButton,logoutButton)
            } else {
                profileHelper.setButtonBackgroundColorColor(value: 0.7, color: .systemGreen, buttons: purchasedHistory,onSaleButton,likedItemsButton,notificationsButton,contactUsButton,settingsButton,addItemButton,logoutButton)
            }
        }
    }

 
    @IBAction func ProfileButtonsPressed(_ sender: UIButton) {

        if Connectivity.isInternetAvailable(){
            switch sender.titleLabel?.text! {
            case "    İndirilenler":
                performSegue(withIdentifier: "profileToDownloaded", sender: nil)
            case "    Ürün Ekle":
                performSegue(withIdentifier: "profileToAddItem", sender: nil)
            case "    Beğeni Listem":
                performSegue(withIdentifier: "profileToLiked", sender: nil)
            case "    Satılığa Çıkarılanlar":
                performSegue(withIdentifier: "profileToOnSale", sender: nil)
            case "    Bildirimler":
                UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
            case "    Bize Ulaşın":
                print("bize ulaşın")
            case "   Çıkış Yap":
                createLogOutAction(title: "Oturumu Kapat", message: "Çıkış yapmak istiyor musunuz?", view: self)
                print("çıkışa basıldı")
            default:
                print("ayarlar basıldı")
            }
        }else{
            Alert.createAlert(title: "Hata", message: "İnternet Bağlantınızı Kontrol Ediniz!", view: self)
        }
    }
    
}


//MARK: - Login/Logut Helper
extension ProfileViewController{
    
    private func checkLoginStatus(){
        if UserViewModel.currentUser() == nil {//login olmuş kullanıcı yok
            configureUIForNotLoggedUser()
        }else {//Login olmuş kullanıcı var.
            configureUIForLoggedUser()
        }
    }
    
    private func configureUIForNotLoggedUser() {
        //login butonu çıkması lazım
        createRightBarButtonItem(title: "Login")
        profileHelper.setAlphaValue(value: 0, views: purchasedHistory,onSaleButton,likedItemsButton,notificationsButton,contactUsButton,settingsButton,addItemButton,logoutButton)
        userNameLabel.text = "Lütfen Giriş Yapınız"
        settingsView.backgroundColor = .clear
        userProfilePictureImageView.tintColor = .black
        
        
    }
    private func configureUIForLoggedUser(){
        
        let loggedUser = UserViewModel.currentUser()//login olmuş kullanıcıyı al
        createRightBarButtonItem(title: "Düzenle")
        profileHelper.setAlphaValue(value: 1, views: purchasedHistory,onSaleButton,likedItemsButton,notificationsButton,contactUsButton,settingsButton,addItemButton,logoutButton)
        
        userProfilePictureImageView.image = nil
        userNameLabel.text = loggedUser?.fullName
        welcomeLabel.text = "Merhaba"
        settingsView.backgroundColor = UIColor.white.withAlphaComponent(0.3)
        profileActivityIndicator.startAnimating()//resim için animasyon başlat
        StorageManager().downloadImage(imageUrl: loggedUser!.profilePicture!){//resmi firebase'den getir.
            image in
            
            DispatchQueue.main.async {
                self.userProfilePictureImageView.image = image
                self.profileActivityIndicator.stopAnimating()
            }
            
        }
        
    }

}

//MARK: - Logout Helper Functions
extension ProfileViewController{
    
    private func logOutUser(){
        UserViewModel.logoutUserWith{ error in
            if error == nil {//çıkış başarılı
                UserDefaults.standard.removeObject(forKey: "LastPlaybackTime")
                self.userProfilePictureImageView.image = UIImage(systemName: "person.circle")//image'i setle
                if let tabBarController = self.tabBarController {//Tabbar ilk sayfaya geç
                    tabBarController.selectedIndex = 0
                    tabBarController.tabBar.items![1].badgeValue = ""
                    tabBarController.tabBar.items![1].badgeColor = .clear
                }
            }else{//çıkış başarısız.
                Alert.createAlert(title: "Hata", message: "Oturum kapatma işlemi başarısız. Lütfen Tekrar deneyiniz.", view: self)
            }
        }
            
    }

     func createLogOutAction(title:String,message:String,view:UIViewController){
         if Connectivity.isInternetAvailable(){
             let alertController = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
              let OKButton = UIAlertAction(title: "Çıkış Yap", style: .destructive){  _ in
                  
                  self.clearSavedVideos()
                  self.logOutUser()
              }
              let cancelButton = UIAlertAction(title: "İptal", style: .cancel){ _ in
                  print("iptal basıldı")
              }
             alertController.addAction(OKButton)
             alertController.addAction(cancelButton)
             view.present(alertController, animated: true)
         }else{
             Alert.createAlert(title: Alert.noConnectionTitle, message: "Çıkış yapabilmek için internet bağlantısı gerekmektedir!", view: self)
         }
        
    }
    
    func clearSavedVideos(){
        let context = appDelegate.persistentContainer.viewContext

        var downloadedVideoList:[Video] = [Video]()
        
        do{
            downloadedVideoList = try context.fetch(Video.fetchRequest())
        }catch{
            print("getirme hatası!")
        }
        
        for downloadedVideo in downloadedVideoList{
            context.delete(downloadedVideo)
        }
        appDelegate.saveContext()
    }
}

//MARK: - UI Helper
extension ProfileViewController{

    private func createRightBarButtonItem(title:String){
        rightBarButtomItem = UIBarButtonItem(title: title, style: .done, target: self, action: #selector(rightBarButtonItemPressed))
        rightBarButtomItem.tintColor = .label
        navigationItem.rightBarButtonItem = rightBarButtomItem
    }
    
    @objc func rightBarButtonItemPressed(){
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        if rightBarButtomItem.title == "Login" {
            if Connectivity.isInternetAvailable(){
                let welcomeVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "loginVC") as! WelcomeViewController
                self.navigationController?.pushViewController(welcomeVC, animated: true)
            }else{
                Alert.createAlert(title: "Hata", message: "İnternet Bağlantınızı Kontrol Ediniz!", view: self)
            }
        }else {
            if Connectivity.isInternetAvailable(){
                let editProfileVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "editProfileVC") as! EditProfileViewController
                self.navigationController?.pushViewController(editProfileVC, animated: true)
            }else{
                Alert.createAlert(title: "Hata", message: "İnternet Bağlantınızı Kontrol Ediniz!", view: self)
            }
            
        }
    }

}


