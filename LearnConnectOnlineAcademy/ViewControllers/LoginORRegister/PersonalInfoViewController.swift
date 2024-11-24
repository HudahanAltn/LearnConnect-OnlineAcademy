//
//  PersonalInfoViewController.swift
//  LearnConnectOnlineAcademy
//
//  Created by Hüdahan Altun on 24.11.2024.
//

import UIKit

class PersonalInfoViewController: UIViewController {

    
    @IBOutlet weak var personalInfoProgressView: UIProgressView!
    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var userLastNameTextField: UITextField!
    @IBOutlet weak var userCitizienTextField: UITextField!
    @IBOutlet weak var userPhoneNumTextField: UITextField!
    @IBOutlet weak var userDateOfBirthTextField: UITextField!
    @IBOutlet weak var userAdressTextField: UITextField!
    @IBOutlet weak var toAccountInfoButton: UIButton!
    
    
    
    var textFieldHelper = UITextFieldHelper()
    var birthDatePicker = UIDatePicker()
    
    var nameCheck:Bool = false
    var lastNameCheck:Bool = false
    var citizienCheck:Bool = false
    var phoneCheck:Bool = false
    var birthCheck:Bool = false
    var adressCheck:Bool = false
    
    var toolbar = UIToolbar()
    
    private let minimumTapInterval = CFTimeInterval(3)
    private var lastTapTime = CFAbsoluteTime(0)
//MARK: - LifeCycles
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.hidesBackButton = false
        tabBarItem.isAccessibilityElement = false
        navigationItem.title = "Kişisel Bilgiler"
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "chevron.backward"), style: .plain, target: self, action: #selector(self.turnBackToPage))
        
        setupUI()
 
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
          
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = true
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tabBarController?.tabBar.isHidden = false
    }
    
//MARK: - Actions
  
    @IBAction func toAccountInfoButtonPressed(_ sender: Any) {
        
        let now = CFAbsoluteTimeGetCurrent()
        guard now >= lastTapTime + minimumTapInterval else { return }
        lastTapTime = now
        
        if nameCheck && lastNameCheck && citizienCheck && phoneCheck && birthCheck && adressCheck{//ilgili alanlar dolduruldu
            //geçici kişi yarat
            let user = User(email: nil,
                            firstName: userNameTextField.text!,
                            lastName: userLastNameTextField.text!,
                            fullAdres: userAdressTextField.text!,
                            turkishCitizenshipId: userCitizienTextField.text!,
                            phoneNumber: userPhoneNumTextField.text!,
                            profilePicture: nil,
                            dateOfBirth: userDateOfBirthTextField.text!)
           
            //bir sonraki sayfaya nesneyi aktar ve geçiş yap
            let accountInfoVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "AccountInfoVC") as! AccountInfoViewController
            accountInfoVC.user = user
            navigationController?.pushViewController(accountInfoVC, animated: true)
            
        }else{
            Alert.createAlert(title: "Hatırlatma", message: "Lütfen Gerekli Alanları Doldurunuz !", view: self)
        }
    }
    
}

//MARK: - Helper Functions
extension PersonalInfoViewController{
    
    func setupProgress(progressView:UIProgressView){//uı setle
        progressView.progress = 0 //progres view başlangıç 0
        UIView.animate(withDuration: 2){
            progressView.setProgress(0.5, animated: true)
        }
    }
    private func setupUI(){
        toAccountInfoButton.layer.cornerRadius = 10
        bindTextFieldDelegate(textfields: userNameTextField,userLastNameTextField,userCitizienTextField,userPhoneNumTextField,userDateOfBirthTextField,userAdressTextField)//delegate'leri bağla
        setupProgress(progressView:personalInfoProgressView)
        defaultConfigureTextFields()//textfield configure ayarlarını yapılandır
        loadBirthPicker()//doğum günü picker'ı yükl
        setupToolbar(toolbar: toolbar)//phone, citizienId ve dateofBirth için toolbar.
    }
    
    private func bindTextFieldDelegate(textfields:UITextField...){//textfield delegate'lerini bağla.
        for textfield in textfields{
            textfield.delegate = self
        }
    }

    func defaultConfigureTextFields(){
        textFieldHelper.setTextFieldsDefaultImageViewAtRight(defaultImage: UIImage(systemName: "pencil.circle")!, color: .black, textFields: userNameTextField,userLastNameTextField,userCitizienTextField,userPhoneNumTextField,userDateOfBirthTextField,userAdressTextField)
        textFieldHelper.setTextFieldAutoCorrectionType(type: .no, textFields: userNameTextField,userLastNameTextField,userCitizienTextField,userPhoneNumTextField,userDateOfBirthTextField,userAdressTextField)
        textFieldHelper.setTextFieldAutoCapitalizationtType(type:.none ,textFields: userNameTextField,userLastNameTextField,userCitizienTextField,userPhoneNumTextField,userDateOfBirthTextField,userAdressTextField)
        textFieldHelper.setTextFieldKeyboardType(type: .default,returnType: .done, textFields: userNameTextField,userLastNameTextField,userAdressTextField)
        textFieldHelper.setTextFieldKeyboardType(type: .numberPad,returnType: .done, textFields: userCitizienTextField,userPhoneNumTextField)
    }
    
    func loadBirthPicker(){
        let date = Date()
        let calendar = Calendar.current
      
        let currentDay = calendar.component(.day, from: date)
        let currentMonth = calendar.component(.month, from: date)
        let currentYear = calendar.component(.year, from: date)

        var minDateComponent = calendar.dateComponents([.day,.month,.year], from: Date())
        minDateComponent.day = 0 + currentDay
        minDateComponent.month = currentMonth - 00
        minDateComponent.year = currentYear - 65
        let minDate = calendar.date(from: minDateComponent)

        var maxDateComponent = calendar.dateComponents([.day,.month,.year], from: Date())
        maxDateComponent.day = 0 + currentDay
        maxDateComponent.month =  currentMonth - 00
        maxDateComponent.year = currentYear - 18
        let maxDate = calendar.date(from: maxDateComponent)
    
        birthDatePicker.minimumDate = minDate! as Date
        birthDatePicker.maximumDate =  maxDate! as Date
      
        if #available(iOS 13.4,*){
            birthDatePicker.preferredDatePickerStyle = .wheels
        }
        
        birthDatePicker.datePickerMode = .date
        userDateOfBirthTextField.inputView = birthDatePicker
        birthDatePicker.addTarget(self, action: #selector(self.showDate(date:)),for: .valueChanged)
    }

    func setupToolbar(toolbar:UIToolbar){
        toolbar.tintColor = .black
        toolbar.sizeToFit()
        toolbar.isTranslucent = true
        toolbar.isOpaque = true
        let OKButton = UIBarButtonItem(title: "Tamam", style: .plain, target: self, action: #selector(self.dismissKeyboard))
        let space = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        toolbar.setItems([space,OKButton], animated: true)
        userDateOfBirthTextField.inputAccessoryView = toolbar
        userCitizienTextField.inputAccessoryView = toolbar
        userPhoneNumTextField.inputAccessoryView = toolbar
    }
 
}

//MARK: - UITextFieldDelegate
extension PersonalInfoViewController:UITextFieldDelegate{
    
    func textFieldDidBeginEditing(_ textField: UITextField) {//düzenleme başladı
        if textField == userNameTextField{
            textFieldHelper.textFieldIsEditing(textField: textField,borderColor: .systemGreen,borderWidth: 1.0,cornerRadius: 5.0)
        }else if textField == userLastNameTextField{
            textFieldHelper.textFieldIsEditing(textField: textField,borderColor: .systemGreen,borderWidth: 1.0,cornerRadius: 5.0)
        }else if textField == userCitizienTextField{
            textFieldHelper.textFieldIsEditing(textField: textField,borderColor: .systemGreen,borderWidth: 1.0,cornerRadius: 5.0)
        }else if textField == userPhoneNumTextField{
            textFieldHelper.textFieldIsEditing(textField: textField,borderColor: .systemGreen,borderWidth: 1.0,cornerRadius: 5.0)
        }else if textField == userDateOfBirthTextField{
            textFieldHelper.textFieldIsEditing(textField: textField,borderColor: .systemGreen,borderWidth: 1.0,cornerRadius: 5.0)
        }else if textField == userAdressTextField{
            textFieldHelper.textFieldIsEditing(textField: textField,borderColor: .systemGreen,borderWidth: 1.0,cornerRadius: 5.0)
        }
    }
    
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool { //düzenleme sırası

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
        }else if textField == userPhoneNumTextField{
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
        }else if textField == userCitizienTextField{
            if textFieldHelper.checkCharacterTypeInTextField(textField: textField, range: range, string: string, type: .decimalDigits){
                if textFieldHelper.characterLimit(textField: textField, range: range, string: string, topLimit: 11, bottomLimit: 0){
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

    
   //düzenleme bitti
    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextField.DidEndEditingReason) {
        if textField == userNameTextField{
            textFieldHelper.textFieldHasEdited(textField: textField)
            nameCheck =  textFieldHelper.checkTextFieldDependencies(textfield: textField,topLimit:30,bottomLimit: 3,placeholderName: "Adınız" )
        }else if textField == userLastNameTextField{
            textFieldHelper.textFieldHasEdited(textField: textField)
            lastNameCheck =  textFieldHelper.checkTextFieldDependencies(textfield: textField,topLimit:20,bottomLimit: 3,placeholderName: "Soyadınız" )
        }else if textField == userPhoneNumTextField{
            textFieldHelper.textFieldHasEdited(textField: textField)
            phoneCheck =  textFieldHelper.checkTextFieldDependencies(textfield: textField, equal: 10, placeholderName: "Telefon Numaranız")
        }else if textField == userCitizienTextField{
            textFieldHelper.textFieldHasEdited(textField: textField)
            citizienCheck = textFieldHelper.checkTextFieldDependencies(textfield: textField, equal: 11, placeholderName: "TC")
        }else if textField == userDateOfBirthTextField{
            textFieldHelper.textFieldHasEdited(textField: textField)
            if  userDateOfBirthTextField.text != ""{
                birthCheck = true
            }else{
                birthCheck = false
                textFieldHelper.textFieldFailAnimation(textField: textField)
            }
        }else if textField == userAdressTextField{
            textFieldHelper.textFieldHasEdited(textField: textField)
            adressCheck =  textFieldHelper.checkTextFieldDependencies(textfield: textField,topLimit:60,bottomLimit:20,placeholderName: "Adres")
        }
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {//return tuşuna basınca çağrılır.
        textField.resignFirstResponder()
        return true
    }
    
}

//MARK: - OBJC Helper Functions
extension PersonalInfoViewController{
    
    @objc func showDate(date:UIDatePicker){
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        let receivedDate = dateFormatter.string(from: self.birthDatePicker.date)
        userDateOfBirthTextField.text = receivedDate
        userDateOfBirthTextField.setIconAtRight(UIImage(systemName: "checkmark.circle")!, color: .systemGreen)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc func turnBackToPage(){
        self.navigationController?.popViewController(animated: true)
    }
}
