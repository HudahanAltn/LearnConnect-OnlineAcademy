//
//  AccountInfoViewController.swift
//  LearnConnectOnlineAcademy
//
//  Created by Hüdahan Altun on 24.11.2024.
//

import UIKit
import PhotosUI

class AccountInfoViewController: UIViewController {

    
    @IBOutlet weak var accountProgresView: UIProgressView!
    
    @IBOutlet weak var userNameLabel: UILabel!
    
    @IBOutlet weak var userPhoneLabel: UILabel!
    
    @IBOutlet weak var userProfileImageView: UIImageView!
    
    @IBOutlet weak var emailTextField: UITextField!
    
    
    @IBOutlet weak var passwordTextField: UITextField!
    
    
    @IBOutlet weak var showPasswordButton: UIButton!
    
    @IBOutlet weak var registerButton: UIButton!
    
    @IBOutlet weak var accountRegisterActivityIndicator: UIActivityIndicatorView!
    
    
    var user:User?
    var isPasswordOpen = true
  
    
    var accountInfoHelper = AccountInfoHelper()
    var accountDependency = AccountDependenciesHelper()
    var textFieldHelper = UITextFieldHelper()
    
    var progress: Float = 0.3
    let totalDuration: TimeInterval = 2.0 // İlerleme tamamlanma süresi (saniye)
    let updateInterval: TimeInterval = 0.01 // İlerleme güncelleme aralığı (saniye)
    var timer: Timer?
    
    private let minimumTapInterval = CFTimeInterval(4)
    private var lastTapTime = CFAbsoluteTime(0)
    override func viewDidLoad() {
        super.viewDidLoad()

        print("user: \(user?.email)- \(user?.firstName) - \(user?.lastName) - \(user?.fullName) - \(user?.fullAdress) - \(user?.purchasedItemIds) - \(user?.onBoard) - \(user?.turkishCitizenshipId) -\(user?.phoneNumber) - \(user?.dateOfBirth) - \(user?.profilePicture)")
        
        navigationItem.title = "Giriş Bilgileri"
        navigationItem.hidesBackButton = false
        tabBarItem.isAccessibilityElement = false
  
        navigationItem.rightBarButtonItems = [UIBarButtonItem(image: UIImage(systemName: "questionmark"), style: .plain, target: self, action: #selector(self.showInfo))]
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "chevron.backward"), style: .plain, target: self, action: #selector(self.turnBackToPage))
        
        timer = Timer.scheduledTimer(timeInterval: updateInterval, target: self, selector: #selector(updateProgress), userInfo: nil, repeats: true)
        setupUI()
    }
    

    @IBAction func galleryButtonPressed(_ sender: Any) {
       
        var config = PHPickerConfiguration()
        config.filter = .images
        config.selectionLimit = 1
        let photoPicker = PHPickerViewController(configuration: config)
        photoPicker.delegate = self
        self.present(photoPicker,animated: true)
    }
    
    
    @IBAction func showPasswordButtonPressed(_ sender: Any) {
        
        
        if isPasswordOpen { //şifre görünür
            passwordTextField.isSecureTextEntry = true
            showPasswordButton.setImage(UIImage(systemName: "eye.slash"), for: .normal)
            isPasswordOpen = false
        }else {//şifre görünmüyor
            passwordTextField.isSecureTextEntry = false
            showPasswordButton.setImage(UIImage(systemName: "eye"), for: .normal)
            isPasswordOpen = true
        }
    }
    @IBAction func registerButtonPressed(_ sender: Any) {
        let now = CFAbsoluteTimeGetCurrent()
        guard now >= lastTapTime + minimumTapInterval else { return }
        lastTapTime = now
        
        if userProfileImageView.image != UIImage(systemName: "person.circle") {
            if accountDependency.checkEmailDependencies(email: emailTextField){
                if accountDependency.checkPasswordDependencies(password: passwordTextField){
                        if accountInfoHelper.isGmail(mail: emailTextField.text!) {
                            if accountInfoHelper.isPasswordSecure(sifre: passwordTextField.text!) {
                            
                                accountRegisterActivityIndicator.startAnimating()
                                UserViewModel.registerUserWith(email: emailTextField.text!, password: passwordTextField.text!){
                                    createUserError,sendVerificationError in
        
                                    if createUserError == nil{
                                        if sendVerificationError == nil{
                                            //kayıt başarılı firestore'a bilgileri geç
        
                                            let user1 = User(
                                                            email: self.emailTextField!.text!,
                                                            firstName: self.user!.firstName,
                                                            lastName: self.user!.lastName,
                                                            fullAdres: self.user!.fullAdress,
                                                            turkishCitizenshipId: self.user!.turkishCitizenshipId,
                                                            phoneNumber: self.user!.phoneNumber,
                                                            profilePicture: "",
                                                            dateOfBirth: self.user!.dateOfBirth)
        
                                            StorageManager().uploadProfilePictureImages(images: [self.userProfileImageView.image], userId: user1.email!){
                                                imageLinks in
        
                                                user1.profilePicture = imageLinks[0]
        
                                                UserViewModel.saveUserToFirestore(user: user1)//firestore kayıt et
                                                self.accountRegisterActivityIndicator.stopAnimating()
                                                self.successRegistter()
                                            }
                                        }else{
                                            Alert.createAlert(title: "Hata", message: "Kullanıcı kaydı başarılı fakat doğrulama maili gönderilmesi başarısız!", view: self)
                                        }
                                    }else{
                                        Alert.createAlert(title: "Hata", message: "Kullanıcı kaydı başarısız!", view: self)
                                    }
                                }//UserVMSOn
                            }else{
                                Alert.createAlert(title: "Hata", message: "Girilen şifre geçerli güvenlik önlemlerini karşılamıyor!", view: self)
                            }
                        }else{
                            Alert.createAlert(title: "Hata", message: "Girilen mail hesabı bir gmail değildir!", view: self)
                        }
                }else{
                    Alert.createAlert(title: "Hatırlatma", message: "Lütfen en az 8 haneli şifre belirleyiniz!", view: self)
                }
            }else{
                Alert.createAlert(title: "Hatırlatma", message: "Lütfen mail adresinizi giriniz!", view: self)
            }
        }else{
            Alert.createAlert(title: "Hatırlatma", message: "Lütfen bir resim ekleyiniz!", view: self)
        }
    }
    
  

}
//MARK: - Helper Functions
extension AccountInfoViewController{

    private func goWelcomeVC(){
        if let viewControllerToPopTo = navigationController?.viewControllers.first(where: { $0 is WelcomeViewController }) {
            navigationController!.popToViewController(viewControllerToPopTo, animated: true)
        }
    }
    
    private func successRegistter(){
        let alertController = UIAlertController(title: "Kayıt Başarılı", message: "Doğrulama linki mail adresinize gönderildi. Lütfen gelen kutunuzu kontrol edin. Ardından tekrar giriş yapınız.", preferredStyle: .alert)
        let OKButton = UIAlertAction(title: "Tamam", style: .cancel){ _ in
            self.goWelcomeVC()
        }
        alertController.addAction(OKButton)
        self.present(alertController, animated: true)
    }
    
    private func setupUI(){
        accountRegisterActivityIndicator.hidesWhenStopped = true
        userProfileImageView.setImageViewFrame(cornerRadius: userProfileImageView.frame.size.width / 2)
        showPasswordButton.setImage(UIImage(systemName: "eye"), for: .normal)
        registerButton.layer.cornerRadius = 10
        
        Alert.createAlert(title:"Bilgilendirme", message: Alert.hesapGuv, view: self)
        
        bindTextFieldDelegate(textfields: emailTextField,passwordTextField)
        configureTextFields()
        accountInfoHelper.setUserLabels(tempUser: user!, userNameLabel: userNameLabel, userPhoneLabel: userPhoneLabel)
    }
    
    private func bindTextFieldDelegate(textfields:UITextField...){//textfield delegate'lerini bağla.
        for textfield in textfields{
            textfield.delegate = self
        }
    }
    
    private func configureTextFields(){
        textFieldHelper.setTextFieldAutoCapitalizationtType(type: .none, textFields: emailTextField,passwordTextField)
        textFieldHelper.setTextFieldAutoCorrectionType(type: .no, textFields: emailTextField,passwordTextField)
        textFieldHelper.setTextFieldKeyboardType(type: .default, returnType: .done, textFields: emailTextField,passwordTextField)
    }
  
}

//MARK: PHPickerViewControllerDelegate
extension AccountInfoViewController:PHPickerViewControllerDelegate{
    
    //alınan resimler tamamlanınca bu delegate fonks tetiklenir.
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true,completion: nil)//picker kapatılır
        results.forEach{ result in
            result.itemProvider.loadObject(ofClass: UIImage.self){ [weak self] reading,error in
                guard let image = reading as? UIImage, error == nil else{
                    return
                }
                DispatchQueue.main.async {
                    self?.userProfileImageView.image = image
                }
            }
        }
    }
    
}
//MARK: - UITextFieldDelegate
extension AccountInfoViewController:UITextFieldDelegate{
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {

        if textField == emailTextField{
            if textFieldHelper.checkCharacterTypeInEmailTextField(textField: textField, range: range, string: string){
                if textFieldHelper.characterLimit(textField: textField, range: range, string: string, topLimit: 40, bottomLimit: 0){
                    return true
                }else{
                    textFieldHelper.textFieldFailAnimation(textField: textField)
                    return false
                }
            }else{
                return false
            }
        }else if textField == passwordTextField{
            if textFieldHelper.characterLimit(textField: textField, range: range, string: string, topLimit: 20, bottomLimit: 0){
                return true
            }else{
                textFieldHelper.textFieldFailAnimation(textField: textField)
                return false
            }
        }
        else{
            textFieldHelper.textFieldFailAnimation(textField: textField)
            return false
        }
    
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == emailTextField{
            textFieldHelper.textFieldIsEditing(textField: textField,borderColor: .systemGreen,borderWidth: 1.0,cornerRadius: 5.0)
        }else if textField == passwordTextField{
            textFieldHelper.textFieldIsEditing(textField: textField,borderColor: .systemGreen,borderWidth: 1.0,cornerRadius: 5.0)
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextField.DidEndEditingReason) {
        if textField == emailTextField{
            textFieldHelper.textFieldHasEdited(textField: textField)
        }else if textField == passwordTextField{
            textFieldHelper.textFieldHasEdited(textField: textField)
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {//TF editingleri bitince keyboard kapansın
        textField.resignFirstResponder()
        return true
    }
    
}
//MARK: - OBJC Helper Functions
extension AccountInfoViewController{
    
    @objc func turnBackToPage(){
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func showInfo(){
        Alert.createAlert(title:"Bilgilendirme", message: Alert.hesapGuv, view: self)
    }
    
    @objc func updateProgress() {
            // İlerleme değerini güncelle
            progress += Float(updateInterval / totalDuration)
            // İlerleme tamamlandığında timer'ı durdur
            if progress == 1.0 {
                timer?.invalidate()
                timer = nil
            }
            // UIProgressView'ı güncelle
            accountProgresView.setProgress(progress, animated: true)
        }
    
}



