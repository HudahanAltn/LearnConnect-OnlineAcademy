//
//  WelcomeViewController.swift
//  LearnConnectOnlineAcademy
//
//  Created by Hüdahan Altun on 24.11.2024.
//

import UIKit

class WelcomeViewController: UIViewController {

    @IBOutlet weak var appNameLabel: UILabel!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var showPasswordButton: UIButton!
    @IBOutlet weak var passwordForgetButton: UIButton!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var registerButton: UIButton!
    @IBOutlet weak var loginActivityIndicator: UIActivityIndicatorView!
    
    var welcomeHelper = WelcomeHelper()
    var accountDependency = AccountDependenciesHelper()
    var textFieldHelper = UITextFieldHelper()
    var isPasswordOpen = false

    private let minimumTapInterval = CFTimeInterval(5)
    private var lastTapTime = CFAbsoluteTime(0)
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.hidesBackButton = false
        tabBarItem.isAccessibilityElement = false
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "chevron.backward"), style: .plain, target: self, action: #selector(self.turnBackToPage))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureTextFields()
        setUpUI()
        tabBarController?.tabBar.isHidden = true
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tabBarController?.tabBar.isHidden = false
    }

    @IBAction func showPasswordButtonPressed(_ sender: Any) {
    
        if isPasswordOpen{
            passwordTextField.isSecureTextEntry = true
            showPasswordButton.setImage(UIImage(systemName: "eye.slash"), for: .normal)
            isPasswordOpen = false
        }else{
            passwordTextField.isSecureTextEntry = false
            showPasswordButton.setImage(UIImage(systemName: "eye"), for: .normal)
            isPasswordOpen = true
        }
    }
    
    
    @IBAction func passwordForgetButtonPressed(_ sender: Any) {
        if Connectivity.isInternetAvailable(){
            if accountDependency.checkEmailDependencies(email: emailTextField){//maili güvenli şekilde al
                loginActivityIndicator.startAnimating()
                UserViewModel.resetPassword(email: self.emailTextField.text!){//şifre sıfılrama mailini gönder
                    error  in
                    
                    if error == nil{//kayıtlı hesap var doğrulanmış veya doğrulanmamış olması çok önemli değil.
                        //şifre yenileme bağlantısı gönderildi.
                        Alert.createAlert(title: "Başarılı", message: "Parola sıfırlama bağlantısı gönderildi. Lütfen gelen kutunuzu kontrol ediniz. Ardından giriş yapınız", view: self)
                    }else{//kullanıcının girdiği hesap kayıtlı değil
                        Alert.createAlert(title: "Hata", message: "Kayıtlı hesap bulunamadı. Lütfen geçerli bir mail adresi giriniz.", view: self)
                    }
                    self.loginActivityIndicator.stopAnimating()
                }
            }else{
                Alert.createAlert(title: "Hatırlatma", message: "Lütfen mail adres kısmını doldurunuz!", view: self)
            }
        }else{
            Alert.createAlert(title: Alert.noConnectionTitle, message: Alert.noConnectionMessage, view: self)
        }
    }
    
    @IBAction func registerButtonPressed(_ sender: Any) {
        if Connectivity.isInternetAvailable(){
            let personalInfoVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "personalInfoVC") as! PersonalInfoViewController
            navigationController?.pushViewController(personalInfoVC, animated: true)
        }else{
            Alert.createAlert(title: Alert.noConnectionTitle, message: Alert.noConnectionMessage, view: self)

        }
       
    }
    
    @IBAction func loginButtonPressed(_ sender: Any) {
        let now = CFAbsoluteTimeGetCurrent()
        guard now >= lastTapTime + minimumTapInterval else { return }
        lastTapTime = now
        print("giriş basıldı ")
        
        if Connectivity.isInternetAvailable(){
            if emailTextField.text != "" && passwordTextField.text != ""{
                loginActivityIndicator.startAnimating()
                
                UserViewModel.loginUserWith(email: emailTextField.text!, password: passwordTextField.text!){ [self] error,isEmailVerified in

                    if error == nil{//kayıtlı kullanıcı var
                        if isEmailVerified{//kayıtlı kullanıcı var ve hesap doğrulandı.
                            print("GİRİŞ BAŞARILI")
                            UserViewModel.downloadUserFromFirestore(email: self.emailTextField.text!)//kullanıcıya ait verileri indir.
                            Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(turnBackToPage), userInfo: nil, repeats: false)//2 sn gecikmeyle bir önceki sayfaya dö
                        }else{//kayıtlı kullanıcı var ama hesap doğrulanmadı.
                            Alert.createAlert(title: "Hatırlatma", message: "Lütfen hesabınızı doğrulayınız!", view: self)
                        }
                    }else{//Kullanıcı kayıt olmamış böyle bir kullanıcı yok
                        Alert.createAlert(title: "Hata", message: "Giriş başarısız. Lütfen tekrar deneyiniz", view: self)
                    }
                    self.loginActivityIndicator.stopAnimating()
                }
                
            }else{
                Alert.createAlert(title: "Hatırlatma", message: "Lütfen gerekli alanları doldurunuz !", view: self)
            }
        }else{
            Alert.createAlert(title: Alert.noConnectionTitle, message: Alert.noConnectionMessage, view: self)

        }
    }
}

extension WelcomeViewController{
    
    private func setUpUI(){
        
        loginActivityIndicator.hidesWhenStopped = true
        isPasswordOpen = false
        showPasswordButton.setImage(UIImage(systemName: "eye.slash"), for: .normal)
        bindTextFieldDelegate(textfields: emailTextField,passwordTextField)//delegate bağla
        welcomeHelper.setButtonCornerRadius(value: 10, views: loginButton,showPasswordButton,registerButton,passwordForgetButton)
        welcomeHelper.setAlphaValue(value: 1, views: passwordForgetButton,registerButton,emailTextField,passwordTextField,loginButton,showPasswordButton)
        welcomeHelper.runAppNameAnimation(label: appNameLabel, textName: "Learn Connect")
        welcomeHelper.runIndroductionAnimation(loginButton: loginButton, passwordForgetButton: passwordForgetButton, emailTextField: emailTextField, passwordTextField: passwordTextField, showPasswordButton: showPasswordButton)
    }
    
    private func bindTextFieldDelegate(textfields:UITextField...){//textfield delegate'lerini bağla.
        for textfield in textfields{
            textfield.delegate = self
        }
    }
    
    private func configureTextFields(){
        passwordTextField.isSecureTextEntry = true
        textFieldHelper.setTextFieldAutoCorrectionType(type: .no, textFields: emailTextField,passwordTextField)
        textFieldHelper.setTextFieldAutoCapitalizationtType(type: .none, textFields: emailTextField,passwordTextField)
        textFieldHelper.setTextFieldKeyboardType(type: .default,returnType: .done,textFields: emailTextField,passwordTextField)
        emailTextField.setIconAtLeft(UIImage(systemName: "person.circle")!,color: .systemGreen)
        passwordTextField.setIconAtLeft(UIImage(systemName: "lock.circle")!,color: .systemGreen)
    }
}

//MARK: - UITextFieldDelegate
extension WelcomeViewController:UITextFieldDelegate{
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {

        if textField == emailTextField{
            if textFieldHelper.characterLimit(textField: textField, range: range, string: string, topLimit: 40, bottomLimit: 0){
                return true
            }else{
                textFieldHelper.textFieldFailAnimation(textField: textField)
                return false
            }
        }else if textField == passwordTextField{
            if textFieldHelper.characterLimit(textField: textField, range: range, string: string, topLimit: 15, bottomLimit: 0){
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
            textFieldHelper.textFieldIsEditing(textField: textField,borderColor: .systemGreen,borderWidth: 1.0,cornerRadius: 3.0)
        }else if textField == passwordTextField{
            textFieldHelper.textFieldIsEditing(textField: textField,borderColor: .systemGreen,borderWidth: 1.0,cornerRadius: 3.0)
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
extension WelcomeViewController{
    
    @objc func turnBackToPage(){
        self.navigationController?.popViewController(animated: true)
    }
    
}
