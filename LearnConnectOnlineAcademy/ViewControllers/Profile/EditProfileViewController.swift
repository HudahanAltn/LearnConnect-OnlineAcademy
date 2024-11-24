//
//  EditProfileViewController.swift
//  LearnConnectOnlineAcademy
//
//  Created by Hüdahan Altun on 24.11.2024.
//

import UIKit
import PhotosUI

class EditProfileViewController: UIViewController {

    
    @IBOutlet weak var userProfilePictureImageView: UIImageView!
    @IBOutlet weak var editProfilePictureButton: UIButton!
    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var userLastNameTextField: UITextField!
    @IBOutlet weak var userPhoneNumberTextField: UITextField!
    @IBOutlet weak var userAdressTextField: UITextField!
    @IBOutlet weak var userActivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var saveChangesButton: UIButton!
    
    
    var textFieldHelper = UITextFieldHelper()
  
    
    var nameCheck:Bool = false
    var lastNameCheck:Bool = false
    var phoneCheck:Bool = false
    var adressCheck:Bool = false
    
    var toolbar = UIToolbar()
    
    private let minimumTapInterval = CFTimeInterval(4)
    private var lastTapTime = CFAbsoluteTime(0)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        let imageViewTapGesture = UITapGestureRecognizer(target: self, action: #selector(imageViewTapped))
                
                // Gesture'ı imageView'a ekle
        userProfilePictureImageView.addGestureRecognizer(imageViewTapGesture)
        view.addGestureRecognizer(tapGesture)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        showCurrentUserDataOnTextFields()
        
    }

    @IBAction func editProfilePictureButtonPressed(_ sender: Any) {
        
        var config = PHPickerConfiguration(photoLibrary: .shared())
        config.selectionLimit = 1//1 adet görüntü seçimi
        config.filter = PHPickerFilter.images// sadece image istiyorum
        
        let vc  = PHPickerViewController(configuration: config)
        vc.delegate = self
        self.present(vc,animated:true)
    }
    
    @IBAction func saveChangesButtonPressed(_ sender: Any) {
        let now = CFAbsoluteTimeGetCurrent()
        guard now >= lastTapTime + minimumTapInterval else { return }
        lastTapTime = now
        if userProfilePictureImageView.image != UIImage(systemName: "person.circle"){//proile fotoğrafının koyulduğundan emin ol
            if nameCheck && lastNameCheck && phoneCheck && adressCheck{//alanları kontrol et
                userActivityIndicator.startAnimating()
    
                StorageManager().deleteProfileImage(imageUrl: "ProfilePicturesImages/\(UserViewModel.currentUser()!.email!)/0.jpg"){ error in
                    if error == nil {
                        self.updateUser()//kullanıcıyı komple güncelle

                    }else {
                        print("resim silme başarısız")
                    }
                    self.userActivityIndicator.stopAnimating()
                }
            }else {
                Alert.createAlert(title: "Hatırlatma", message: "Lütfen ilgili alanları kontrol ediniz.", view: self)
            }
        }else {
            Alert.createAlert(title: "Hatırlatma", message: "Lütfen profil resmi ekleyiniz.", view: self)
        }
    }
    
}


//MARK: - Update Profile
extension EditProfileViewController{
    
    func updateUser(){//kullanıcının yeni fotoğrafını storage'e yükle
        StorageManager().uploadProfilePictureImages(images: [self.userProfilePictureImageView.image], userId: UserViewModel.currentUser()!.email!){
            imageLink in
            //kullanıcın güncelleyeceği değerleri al
            let withValues = [FirebaseConstants().kFIRSTNAME:self.userNameTextField.text,
                              FirebaseConstants().kLASTNAME:self.userLastNameTextField.text,
                              FirebaseConstants().kPHONE:self.userPhoneNumberTextField.text,
                              FirebaseConstants().kFULLADRESS:self.userAdressTextField.text,
                              FirebaseConstants().kIMAGENAME:imageLink[0]] as [String:Any]
            
            UserViewModel.updateUser(withValues: withValues){ error in //kullanıcıyı güncelle
                if error == nil {//güncelleme başarılı
                    Alert.createAlertWithPop(title: "Başarılı", message: "Profil bilgileriniz güncellenmiştir.", view: self)
                }else {//güncelleme başarısız
                    Alert.createAlert(title: "Hata", message: "Profil bilgileri güncellenirken hata oluştu.Lütfen daha sonra tekrar deneyiniz.", view: self)
                }
                self.userActivityIndicator.stopAnimating()
            }
        }
    }
    
}
//MARK: - UI Helper
extension EditProfileViewController{
    
    private func showCurrentUserDataOnTextFields(){
        userNameTextField.text = UserViewModel.currentUser()!.firstName
        userLastNameTextField.text = UserViewModel.currentUser()!.lastName
        userPhoneNumberTextField.text = UserViewModel.currentUser()!.phoneNumber
        userAdressTextField.text = UserViewModel.currentUser()!.fullAdress
        StorageManager().downloadImage(imageUrl: UserViewModel.currentUser()!.profilePicture!){
            image in
            self.userProfilePictureImageView.image = image
        }
    }
    
    private func setupUI(){
        bindTextFieldDelegate(textfields: userNameTextField,userLastNameTextField,userPhoneNumberTextField,userAdressTextField)
        userProfilePictureImageView.setImageViewFrame(cornerRadius: userProfilePictureImageView.frame.size.width / 2)
        userProfilePictureImageView.isUserInteractionEnabled = true
        defaultConfigureTextFields()
        setupToolbar(toolbar: toolbar)
        self.navigationItem.title = UserViewModel.currentUser()!.fullName
        saveChangesButton.layer.cornerRadius = 5.0
        saveChangesButton.backgroundColor = .systemGreen
        saveChangesButton.layer.borderColor = UIColor.black.cgColor
        saveChangesButton.layer.borderWidth = 1.0
    }
    
    private func bindTextFieldDelegate(textfields:UITextField...){//textfield delegate'lerini bağla.
        for textfield in textfields{
            textfield.delegate = self
        }
    }
    
    
    func defaultConfigureTextFields(){
        textFieldHelper.setTextFieldsDefaultImageViewAtRight(defaultImage: UIImage(systemName: "pencil.circle")!, color: .black, textFields: userNameTextField,userLastNameTextField,userPhoneNumberTextField,userAdressTextField)
        textFieldHelper.setTextFieldAutoCorrectionType(type: .no, textFields: userNameTextField,userLastNameTextField,userPhoneNumberTextField,userAdressTextField)
        textFieldHelper.setTextFieldAutoCapitalizationtType(type:.none ,textFields: userNameTextField,userLastNameTextField,userPhoneNumberTextField,userAdressTextField)
        textFieldHelper.setTextFieldKeyboardType(type: .default,returnType: .done, textFields: userNameTextField,userLastNameTextField,userAdressTextField)
        textFieldHelper.setTextFieldKeyboardType(type: .numberPad,returnType: .done, textFields: userPhoneNumberTextField)
      
    }
    
    func setupToolbar(toolbar:UIToolbar){
        toolbar.tintColor = .black
        toolbar.sizeToFit()
        toolbar.isTranslucent = true
        toolbar.isOpaque = true
        let OKButton = UIBarButtonItem(title: "Tamam", style: .plain, target: self, action: #selector(self.dismissKeyboard))
        let space = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        toolbar.setItems([space,OKButton], animated: true)
        userPhoneNumberTextField.inputAccessoryView = toolbar
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

//MARK: - UITextfield Delegate
extension EditProfileViewController:UITextFieldDelegate{
 
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {

        if textField == userNameTextField{
            if textFieldHelper.checkCharacterTypeInTextField(textField: textField, range: range, string: string,type:.letters){
                if textFieldHelper.characterLimit(textField: textField, range: range, string: string, topLimit: 30, bottomLimit: 0){
                    return true
                }else{
                    textFieldHelper.textFieldFailAnimation(textField: textField)
                    return false
                }
            }else{
                return false
            }
        }else if textField == userLastNameTextField{
            if textFieldHelper.checkCharacterTypeInTextField(textField: textField, range: range, string: string, type:.letters){
                if textFieldHelper.characterLimit(textField: textField, range: range, string: string, topLimit: 20, bottomLimit: 0){
                    return true
                }else{
                    textFieldHelper.textFieldFailAnimation(textField: textField)
                    return false
                }
            }else{
                return false
            }
        }else if textField == userPhoneNumberTextField{
            if textFieldHelper.checkCharacterTypeInTextField(textField: textField, range: range, string: string, type: .decimalDigits){
                if textFieldHelper.characterLimit(textField: textField, range: range, string: string, topLimit: 10, bottomLimit: 0){
                    return true
                }else{
                    textFieldHelper.textFieldFailAnimation(textField: textField)
                    return false
                }
            }else{
                return false
            }
        }else if textField == userAdressTextField{
            if textFieldHelper.checkCharacterTypeInAdressTextField(textField: textField, range: range, string: string){
                if textFieldHelper.characterLimit(textField: textField, range: range, string: string, topLimit: 60, bottomLimit: 0){
                    return true
                }else{
                    textFieldHelper.textFieldFailAnimation(textField: textField)
                    return false
                }
            }else{
                return false
            }
        }
        else{
            textFieldHelper.textFieldFailAnimation(textField: textField)
            return false
        }
        
        
    }
    
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == userNameTextField{
            textFieldHelper.textFieldIsEditing(textField: textField,borderColor: .systemGreen,borderWidth: 1.0,cornerRadius: 5.0)
        }else if textField == userLastNameTextField{
            textFieldHelper.textFieldIsEditing(textField: textField,borderColor: .systemGreen,borderWidth: 1.0,cornerRadius: 5.0)
        }else if textField == userPhoneNumberTextField{
            textFieldHelper.textFieldIsEditing(textField: textField,borderColor: .systemGreen,borderWidth: 1.0,cornerRadius: 5.0)
        }else if textField == userAdressTextField{
            textFieldHelper.textFieldIsEditing(textField: textField,borderColor: .systemGreen,borderWidth: 1.0,cornerRadius: 5.0)
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextField.DidEndEditingReason) {
        if textField == userNameTextField{
            textFieldHelper.textFieldHasEdited(textField: textField)
            nameCheck =  textFieldHelper.checkTextFieldDependencies(textfield: textField,topLimit:30,bottomLimit: 3,placeholderName: "Adınız" )
        }else if textField == userLastNameTextField{
            textFieldHelper.textFieldHasEdited(textField: textField)
            lastNameCheck =  textFieldHelper.checkTextFieldDependencies(textfield: textField,topLimit:20,bottomLimit: 3,placeholderName: "Soyadınız" )
            
        }else if textField == userPhoneNumberTextField{
            textFieldHelper.textFieldHasEdited(textField: textField)
            phoneCheck =  textFieldHelper.checkTextFieldDependencies(textfield: textField, equal: 10, placeholderName: "Telefon Numaranız")
        }else if textField == userAdressTextField{
            textFieldHelper.textFieldHasEdited(textField: textField)
            adressCheck =  textFieldHelper.checkTextFieldDependencies(textfield: textField,topLimit:60,bottomLimit:20,placeholderName: "Adresiniz")
        }
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {//TF editingleri bitince keyboard kapansın
        textField.resignFirstResponder()
        return true
    }
    
}

//MARK: PHPicker Delegate
extension EditProfileViewController:PHPickerViewControllerDelegate{
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true,completion: nil)//picker kapatılır
        userProfilePictureImageView.image = UIImage(systemName: "person.circle")
        results.forEach{ result in
            result.itemProvider.loadObject(ofClass: UIImage.self){ [weak self] reading,error in
                guard let image = reading as? UIImage, error == nil else{
                    return
                }
                DispatchQueue.main.async {
                    self?.userProfilePictureImageView.image = image
                }
            }
        }
    }
    
}

//MARK: - OBJC Hepler
extension EditProfileViewController{
    
    @objc func dismissKeyboard() {
           view.endEditing(true)
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
    
    @objc func imageViewTapped(_ sender: UITapGestureRecognizer) {
        showFullScreenImage(image: userProfilePictureImageView.image)

    }
}
