//
//  PaymentViewController.swift
//  LearnConnectOnlineAcademy
//
//  Created by Hüdahan Altun on 24.11.2024.
//

import UIKit


extension Notification.Name{
    static let notificaitonName = Notification.Name("paymentBroadcast")
}

class PaymentViewController: UIViewController {

    @IBOutlet weak var welcomeLabel: UILabel!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var informationLabel: UILabel!
    @IBOutlet weak var TotalPriceInformationLabel: UILabel!
    @IBOutlet weak var totalPriceLabel: UILabel!
    @IBOutlet weak var cardNameLabel: UILabel!
    @IBOutlet weak var cardNameTextField: UITextField!
    @IBOutlet weak var cardNumberLabel: UILabel!
    @IBOutlet weak var cardNumberTextField: UITextField!
    @IBOutlet weak var mm_yyLabel: UILabel!
    @IBOutlet weak var mm_yyTextField: UITextField!
    @IBOutlet weak var ccvLabel: UILabel!
    @IBOutlet weak var ccvTextField: UITextField!
    @IBOutlet weak var applePayImageView: UIImageView!
    @IBOutlet weak var mastercardImageView: UIImageView!
    @IBOutlet weak var paypalImageView: UIImageView!
    @IBOutlet weak var visaImageView: UIImageView!
    @IBOutlet weak var termsSwitch: UISwitch!
    @IBOutlet weak var privacySwitch: UISwitch!
    @IBOutlet weak var orderButton: UIButton!
    

    var paymentHelper = PaymentHelper()
    var textFieldHelper = UITextFieldHelper()
    var purchasedItemsIds:[String] = [String] ()
    
    var toolbar = UIToolbar()
    var mm_yyDatePicker = UIDatePicker()
    
    var cardNameCheck:Bool = false
    var cardNumberCheck:Bool = false
    var cardmmYYCheck:Bool = false
    var cardccvCheck:Bool = false
    
    var totalPrice:String!
    var isUserPaid:Bool = false
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.hidesBackButton = false
        tabBarItem.isAccessibilityElement = false
        
        cardNameTextField.delegate = self
        cardNumberTextField.delegate = self
        mm_yyTextField.delegate = self
        ccvTextField.delegate = self
        setupUI()
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "chevron.backward"), style: .plain, target: self, action: #selector(self.turnBackToPage))
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        isUserPaid = false
        tabBarController?.tabBar.isHidden = true
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tabBarController?.tabBar.isHidden = false
        NotificationCenter.default.post(name: .notificaitonName, object: nil,userInfo: ["message":isUserPaid])
    }
    
    @IBAction func termsButtonPressed(_ sender: UIButton) {
        let vc = PaymentContractsViewController()
        vc.termsLabel.text = sender.titleLabel?.text!
        self.present(vc, animated: true,completion: nil)
    }
    
    @IBAction func privacyButtonPressed(_ sender: UIButton) {
        let vc = PaymentContractsViewController()
        vc.termsLabel.text = sender.titleLabel?.text!
        self.present(vc, animated: true,completion: nil)
    }
    
    @IBAction func orderButtonPressed(_ sender: Any) {
        if Connectivity.isInternetAvailable(){
            if cardccvCheck && cardNameCheck && cardNumberCheck && cardmmYYCheck{
                if privacySwitch.isOn && termsSwitch.isOn{
                    isUserPaid = true
                    Alert.createAlertWithPop(title: "Bilgilendirme", message: "Ödeme Başarılı!", view: self)
                }else{
                    Alert.createAlert(title: "Bilgilendirme", message: "Lütfen Sözleşmeleri Okuyup Kabul Ediniz.", view: self)
                }
            }else{
                Alert.createAlert(title: "Bilgilendirme", message: "Lütfen Kart Bilgilerinin Doldurulduğundan Emin Olunuz!", view: self)
            }
        }else{
            Alert.createAlert(title: Alert.noConnectionTitle, message: Alert.noConnectionMessage, view: self)
        }
    }
}


//MARK: - PaymentVC Helper
extension PaymentViewController{
    func defaultConfigureTextFields(){
        textFieldHelper.setTextFieldsDefaultImageViewAtRight(defaultImage: UIImage(systemName: "pencil.circle")!, color: .black, textFields: cardNameTextField,cardNumberTextField,mm_yyTextField,ccvTextField)
        textFieldHelper.setTextFieldAutoCorrectionType(type: .no, textFields:cardNameTextField,cardNumberTextField,mm_yyTextField,ccvTextField)
        textFieldHelper.setTextFieldAutoCapitalizationtType(type:.none ,textFields:cardNameTextField,cardNumberTextField,mm_yyTextField,ccvTextField)
        textFieldHelper.setTextFieldKeyboardType(type: .default,returnType: .done, textFields: cardNameTextField,mm_yyTextField)
        textFieldHelper.setTextFieldKeyboardType(type: .numberPad,returnType: .done, textFields: cardNumberTextField,ccvTextField)
    }
    
    func setupUI(){
        orderButton.backgroundColor = .systemCyan
        defaultConfigureTextFields()
        totalPriceLabel.text = totalPrice!
        userNameLabel.text = UserViewModel.currentUser()?.fullName
        loadDatePicker(maxYear: 10)
        setupToolbar(toolbar: toolbar)
        
        paymentHelper.setButtonCornerRadius(value: 5, views: applePayImageView,mastercardImageView,paypalImageView,visaImageView,orderButton)
    }
}
//MARK: - UITextFieldDelegate
extension PaymentViewController:UITextFieldDelegate{
    
    func textFieldDidBeginEditing(_ textField: UITextField) {//düzenleme başladı
        
        if textField == cardNameTextField{
            textFieldHelper.textFieldIsEditing(textField: textField,borderColor: .systemCyan,borderWidth: 1.0,cornerRadius: 5.0)
        }else if textField == cardNumberTextField{
            textFieldHelper.textFieldIsEditing(textField: textField,borderColor: .systemCyan,borderWidth: 1.0,cornerRadius: 5.0)
        }else if textField == mm_yyTextField{
            textFieldHelper.textFieldIsEditing(textField: textField,borderColor:  .systemCyan,borderWidth: 1.0,cornerRadius: 5.0)
        }else if textField == ccvTextField{
            textFieldHelper.textFieldIsEditing(textField: textField,borderColor:  .systemCyan,borderWidth: 1.0,cornerRadius: 5.0)
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool { //düzenleme sırası

        if textField == cardNameTextField{
            if textFieldHelper.checkCharacterTypeInNameTextField(textField: textField, range: range, string: string){
                if textFieldHelper.characterLimit(textField: textField, range: range, string: string, topLimit: 50, bottomLimit: 0){
                    return true
                }else{
                    textFieldHelper.textFieldFailAnimation(textField: textField)
                    return false
                }
            }else{
                textFieldHelper.textFieldFailAnimation(textField: textField)
                return false
            }
        }else if textField == cardNumberTextField{
            if textFieldHelper.checkCharacterTypeInTextField(textField: textField, range: range, string: string, type:.decimalDigits){
                if textFieldHelper.characterLimit(textField: textField, range: range, string: string, topLimit: 16, bottomLimit: 0){
                    return true
                }else{
                    textFieldHelper.textFieldFailAnimation(textField: textField)
                    return false
                }
            }else{
                textFieldHelper.textFieldFailAnimation(textField: textField)

                return false
            }
        }else if textField == mm_yyTextField{
            if textFieldHelper.checkCharacterTypeInDateTextField(textField: textField, range: range, string: string){
                if textFieldHelper.characterLimit(textField: textField, range: range, string: string, topLimit: 10, bottomLimit: 0){
                    return true
                }else{
                    textFieldHelper.textFieldFailAnimation(textField: textField)
                    return false
                }
            }else{
                textFieldHelper.textFieldFailAnimation(textField: textField)
                return false
            }
        }else if textField == ccvTextField{
            if textFieldHelper.checkCharacterTypeInTextField(textField: textField, range: range, string: string, type: .decimalDigits){
                if textFieldHelper.characterLimit(textField: textField, range: range, string: string, topLimit: 3, bottomLimit: 0){
                    return true
                }else{
                    textFieldHelper.textFieldFailAnimation(textField: textField)
                    return false
                }
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

    
   //düzenleme bitti
    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextField.DidEndEditingReason) {
        if textField == cardNameTextField{
            textFieldHelper.textFieldHasEdited(textField: textField)
            cardNameCheck =  textFieldHelper.checkTextFieldDependencies(textfield: textField,topLimit:50,bottomLimit: 2,placeholderName: "" )
        }else if textField == cardNumberTextField{
            textFieldHelper.textFieldHasEdited(textField: textField)
            cardNumberCheck =  textFieldHelper.checkTextFieldDependencies(textfield: textField,equal:16,placeholderName: "" )
        }else if textField == mm_yyTextField{
            textFieldHelper.textFieldHasEdited(textField: textField)
            cardmmYYCheck =  textFieldHelper.checkTextFieldDependencies(textfield: textField, equal: 10, placeholderName: "")
        }else if textField == ccvTextField{
            textFieldHelper.textFieldHasEdited(textField: textField)
            cardccvCheck = textFieldHelper.checkTextFieldDependencies(textfield: textField, equal: 3, placeholderName: "")
        }
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {//return tuşuna basınca çağrılır.
        textField.resignFirstResponder()
        return true
    }
    
}
//MARK: - Objective-C functions
extension PaymentViewController {
    
    @objc func turnBackToPage(){
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc func showDate(date:UIDatePicker){
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        let receivedDate = dateFormatter.string(from: self.mm_yyDatePicker.date)
        mm_yyTextField.text = receivedDate
        mm_yyTextField.setIconAtRight(UIImage(systemName: "checkmark.circle")!, color: .systemGreen)
    }
    
}
//MARK: - Picker
extension PaymentViewController {
    func loadDatePicker(minDay:Int = 0,minMonth:Int = 0, minYear:Int = 0, maxDay:Int = 0, maxMonth:Int = 0, maxYear:Int = 0){
        let date = Date()
        let calendar = Calendar.current
      
        let currentDay = calendar.component(.day, from: date)
        let currentMonth = calendar.component(.month, from: date)
        let currentYear = calendar.component(.year, from: date)

        var minDateComponent = calendar.dateComponents([.day,.month,.year], from: Date())
        minDateComponent.day = minDay + currentDay
        minDateComponent.month = currentMonth - minMonth
        minDateComponent.year = currentYear - minYear
        let minDate = calendar.date(from: minDateComponent)

        var maxDateComponent = calendar.dateComponents([.day,.month,.year], from: Date())
        maxDateComponent.day = maxDay + currentDay
        maxDateComponent.month =  currentMonth - maxMonth
        maxDateComponent.year = currentYear + maxYear
        let maxDate = calendar.date(from: maxDateComponent)
    
        mm_yyDatePicker.minimumDate = minDate! as Date
        mm_yyDatePicker.maximumDate =  maxDate! as Date
      
        if #available(iOS 13.4,*){
            mm_yyDatePicker.preferredDatePickerStyle = .wheels
        }
        
        mm_yyDatePicker.datePickerMode = .date
        mm_yyTextField.inputView = mm_yyDatePicker
        mm_yyDatePicker.addTarget(self, action: #selector(self.showDate(date:)),for: .valueChanged)
    }

    func setupToolbar(toolbar:UIToolbar){
        toolbar.tintColor = .black
        toolbar.sizeToFit()
        toolbar.isTranslucent = true
        toolbar.isOpaque = true
        let OKButton = UIBarButtonItem(title: "Tamam", style: .plain, target: self, action: #selector(self.dismissKeyboard))
        let space = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        toolbar.setItems([space,OKButton], animated: true)
        mm_yyTextField.inputAccessoryView = toolbar
        
    }
}
