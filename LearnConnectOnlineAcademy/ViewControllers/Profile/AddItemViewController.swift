//
//  AddItemViewController.swift
//  LearnConnectOnlineAcademy
//
//  Created by Hüdahan Altun on 22.11.2024.
//

import UIKit
import Combine
import PhotosUI

class AddItemViewController: UIViewController {

    @IBOutlet weak var doneBarButton: UIBarButtonItem!
    @IBOutlet weak var uploadFirebaseProgressView: UIProgressView!
    @IBOutlet weak var uploadActivityİndicator: UIActivityIndicatorView!
    @IBOutlet weak var itemNameTextField: UITextField!
    @IBOutlet weak var itemPriceTextField: UITextField!
    @IBOutlet weak var itemCategoryTextField: UITextField!
    @IBOutlet weak var itemSubcategoryTextField: UITextField!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var descriptionViewTextCountLabel: UILabel!
    
    @IBOutlet weak var itemImageView: UIImageView!
    @IBOutlet weak var galleryButton: UIButton!
    @IBOutlet weak var addVideoButton: UIButton!
    @IBOutlet weak var videosTableView: UITableView!
    
    var catVM = CategoryViewModel()//kategori isimlerini alıyoruz
    var subcatVM = SubcategoryViewModel()//kategori ismine göre alt kategori getiriyoruz.
    var onSaleVM = OnSaleViewModel()
    private var cancellablecat:Set<AnyCancellable> = []
    private var cancellableSubcat:Set<AnyCancellable> = []
    
    var categories:[Category] = [Category]()
    var subcategories:[SubCategory] = [SubCategory]()
    
    var selectedCategoryId:String?
    var selectedSubcategoryId:String?
    
    var CategoryPickerView = UIPickerView()
    var subCategoryPickerView = UIPickerView()
    
    var itemVM = ItemViewModel()
    var addItemView = AddItemView()
    var textFieldHelper = UITextFieldHelper()
    var textViewsHelper = UITextViewHelper()
    
    var videoLinkForTableView:[String] = [String] ()
    var videoURLs:[URL] = [URL] ()
    var itemImage:UIImage?
    var imageLink:String = ""
    var videoLinks:[String] = [String]()
    let toolbar:UIToolbar = UIToolbar()
    
    var isFirstClickOnTextView = true
    
    var itemNameCheck:Bool = false
    var itemPriceCheck:Bool = false
    var itemDescriptionCheck:Bool = false
    var imagesToSelect = 0
    
    var imagePicker:UIImagePickerController?
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        catVM.downloadCategoriesFromFirebase()
        setUpCategoriesVMBinders()
        setUpSubcategoriesVMBinders()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.videoUploadRemaining(notification:)), name:.uploadInfo, object: nil)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
        let imageViewTapGesture = UITapGestureRecognizer(target: self, action: #selector(imageViewTapped))
        itemImageView.isUserInteractionEnabled = true
        itemImageView.addGestureRecognizer(imageViewTapGesture)
        view.addGestureRecognizer(tapGesture)
    }
    
    //MARK: - Binders
    func setUpCategoriesVMBinders(){
        catVM.$categories.sink{ [weak self]  categories in
            if  categories.count > 0 {
                self?.categories = categories
            }
        }.store(in: &cancellablecat)
    }
    
    func setUpSubcategoriesVMBinders(){
        subcatVM.$subCategories.sink{ [weak self]  subcategories in
            if  subcategories.count > 0 {
                self?.subcategories = subcategories
            }
        }.store(in: &cancellableSubcat)
    }
    
    @IBAction func doneButtonPressed(_ sender: Any) {
        
        if Connectivity.isInternetAvailable(){
            if fieldsAreCompleted() {
                if isPictureAdded() {
                    
                    saveToFirebase()
                }else {
                    Alert.createAlert(title: "Hatırlatma", message: "Lütfen en az 1 resim ekleyiniz.", view: self)
                }
            }else{
                Alert.createAlert(title: "Hatırlatma", message: "Lütfen Gerekli Metin Alanlarını Doldurunuz !", view: self)
            }
        }else{
            Alert.createAlert(title: "Hata", message: "İnternet Bağlantınızı Kontrol Ediniz!", view: self)
        }
    }
    
    @IBAction func galleryButtonPressed(_ sender: Any) {
        itemImage = nil
        itemImageView.image = UIImage(systemName: "photo.fill")
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary // Galeriyi açar
        present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func addVideoButtonPressed(_ sender: Any) {
         
        var config = PHPickerConfiguration()
        config.filter = .videos
        config.selectionLimit = 1
        let photoPicker = PHPickerViewController(configuration: config)
        photoPicker.delegate = self
        present(photoPicker,animated: true)
    }
    
}
//MARK: - AddItemHelper
extension AddItemViewController{
    
    private func setupUI(){
        setupToolbar(toolbar: toolbar)
        addVideoButton.isEnabled = true
        videosTableView.delegate = self
        videosTableView.dataSource = self
        videosTableView.backgroundColor = .clear
        descriptionTextView.delegate = self
        descriptionTextView.keyboardType = .default
        descriptionTextView.returnKeyType = .done
        descriptionTextView.autocorrectionType = .no
        descriptionTextView.autocapitalizationType = .none
        itemImageView.contentMode = .scaleAspectFit
        itemImageView.image = UIImage(systemName: "photo.fill")
        itemImageView.tintColor = .label
        uploadActivityİndicator.alpha = 0.0
        uploadActivityİndicator.hidesWhenStopped = true
        uploadFirebaseProgressView.alpha = 0.0
        doneBarButton.isEnabled = true
        addItemView.setAlphaValue(value: 0, views: itemSubcategoryTextField,descriptionTextView,addVideoButton,itemImageView,galleryButton,videosTableView,descriptionViewTextCountLabel)
        addItemView.setButtonCornerRadius(value: 10, views: addVideoButton,galleryButton)
        
        bindTextFieldDelegate(textfields: itemNameTextField,itemPriceTextField,itemCategoryTextField,itemSubcategoryTextField)
        
        textFieldHelper.setTextFieldAutoCapitalizationtType(type: .none, textFields: itemNameTextField,itemPriceTextField)
        textFieldHelper.setTextFieldAutoCorrectionType(type: .no, textFields: itemNameTextField,itemPriceTextField)
        textFieldHelper.setTextFieldKeyboardType(type: .default, returnType: .done, textFields: itemNameTextField)
        textFieldHelper.setTextFieldKeyboardType(type: .numberPad, returnType: .done, textFields: itemPriceTextField)
        textFieldHelper.setTextFieldsDefaultImageViewAtRight(defaultImage: UIImage(systemName: "pencil.circle")!, color: .label, textFields: itemNameTextField,itemPriceTextField)
        
        itemPriceTextField.setIconAtLeft(UIImage(systemName: "turkishlirasign.circle")!, color: .label)
        
        addItemView.configureCategory(pickerview: CategoryPickerView, textfield: itemCategoryTextField, view: self)
        addItemView.configureSubCategory(pickerview: subCategoryPickerView, textfield: itemSubcategoryTextField, view: self)
    }
    
    private func bindTextFieldDelegate(textfields:UITextField...){
        for textfield in textfields{
            textfield.delegate = self
        }
    }
    
    func setupToolbar(toolbar:UIToolbar){
        toolbar.tintColor = .black
        toolbar.sizeToFit()
        toolbar.isTranslucent = true
        toolbar.isOpaque = true
        
        let OKButton = UIBarButtonItem(title: "Tamam", style: .plain, target: self, action: #selector(self.dismissKeyboard))
        let space = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        toolbar.setItems([space,OKButton], animated: true)
        
        itemCategoryTextField.inputAccessoryView = toolbar
        itemSubcategoryTextField.inputAccessoryView = toolbar
        itemPriceTextField.inputAccessoryView = toolbar
    }
    
    private func showFullScreenImage(image: UIImage?) {
        guard let image = image else { return }
        let fullScreenImageView = UIImageView(image: image)
        fullScreenImageView.frame = self.view.frame
        fullScreenImageView.tintColor = .systemGreen
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
    
    private func fieldsAreCompleted() -> Bool{//Tf'lerin doluluğunu kontrol edecek.
        return (itemNameCheck && itemPriceCheck && itemDescriptionCheck && itemCategoryTextField.text != "" && itemSubcategoryTextField.text != "" && descriptionTextView.text != "" && descriptionTextView.text != "Lütfen Açıklama Giriniz ..." )
    }
    
    private func isPictureAdded()->Bool{
        return itemImage != nil ? true : false
    }
    
    private func saveToFirebase(){
        doneBarButton.isEnabled = false
        let item = Item() //ürün
        item.id = UUID().uuidString//ürüne unique id ata.
        item.name = itemNameTextField.text!
        item.categoryId = selectedCategoryId
        item.subCategoryId = selectedSubcategoryId
        item.description = descriptionTextView.text
        item.price = Double(itemPriceTextField.text!)
        item.dealerMail = UserViewModel.currentUser()!.email
        
        StorageManager().uploadImages(images: [itemImage], itemId: item.id){  imageLinkArray in
            item.imageLink = imageLinkArray[0]
        }
        
        StorageManager().uploadVideos(videoURLs: videoURLs, itemId: item.id){
            videoLinkArray in
            item.videoLinks = videoLinkArray
            
            self.itemVM.saveItemToFirestore(item)//itemi kayıt et.
            self.itemVM.saveItemToAlgolia(item: item)
            Alert.createAlertWithPop(title: "Tebrikler", message: "Kursunuz artık yayında!", view: self)
            self.doneBarButton.isEnabled = true
        }
        addOnSale(item: item)
    }
}
//MARK: - PHPickerController
extension AddItemViewController:PHPickerViewControllerDelegate{
    
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        
        picker.dismiss(animated: true)
        uploadActivityİndicator.alpha = 1.0
        addVideoButton.isEnabled = false
        uploadActivityİndicator.startAnimating()
        guard let provider = results.first?.itemProvider else { return }
        if provider.hasItemConformingToTypeIdentifier(UTType.movie.identifier){
            
            provider.loadFileRepresentation(forTypeIdentifier: UTType.movie.identifier){
                fileUrl, error in
                
                guard let fileURL = fileUrl, error == nil else { return}
                
                // Geçici URL'den kalıcı bir konuma taşıyoruz
                let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                let destinationURL = documentsDirectory.appendingPathComponent(fileURL.lastPathComponent)
                
                do {
                    if FileManager.default.fileExists(atPath: destinationURL.path) {
                        try FileManager.default.removeItem(at: destinationURL) // Eğer varsa önce sil
                    }
                    try FileManager.default.copyItem(at: fileURL, to: destinationURL)
                    print("File moved to: \(destinationURL)")
                    
                    // Kalıcı URL'yi kullanarak yükleme yap
                    print("video url : \(fileURL)")
                    self.videoURLs.append(destinationURL)
                    print("dizideki : \(self.videoURLs[0])")
                    self.videoLinkForTableView.append(destinationURL.lastPathComponent)
                    
                    DispatchQueue.main.async{
                        self.videosTableView.reloadData()
                        self.uploadActivityİndicator.stopAnimating()
                        self.addVideoButton.isEnabled = true

                    }
                } catch {
                    print("Error moving file: \(error)")
                }
            }
        }
    }
    

}
//MARK: - UIImagePickerControllerDelegate
extension AddItemViewController:UIImagePickerControllerDelegate,UINavigationControllerDelegate{

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let selectedImage = info[.originalImage] as? UIImage {
            let fixedImage = selectedImage.fixedOrientation()
            self.itemImage = fixedImage
            self.itemImageView.image = fixedImage
        }
        picker.dismiss(animated: true, completion: nil)
    }
    

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        itemImage = nil
        itemImageView.image = UIImage(systemName: "photo.fill")
        picker.dismiss(animated: true, completion: nil)
    }
    
}
//MARK: - pickerView for Textfields
extension AddItemViewController:UIPickerViewDelegate,UIPickerViewDataSource{
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == CategoryPickerView {
            return categories.count
        }else{
            return subcategories.count
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView == CategoryPickerView {
            return categories[row].name
        }else{
            return subcategories[row].name
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == CategoryPickerView {//kategori seçilsin
            selectedCategoryId = ""
            itemCategoryTextField.text = categories[row].name
            selectedCategoryId = categories[row].id
            subcatVM.downloadSubCategoriesFromFirebase(withSubCategoryId: categories[row].id)
            itemSubcategoryTextField.alpha = 1
            itemSubcategoryTextField.text = ""
            descriptionTextView.text = ""
            
        }else if pickerView == subCategoryPickerView {//altkategori seçilince ekranın geri kalanı gelsin.
            selectedSubcategoryId = ""
            descriptionTextView.text = "Lütfen Açıklama Giriniz ..."
            itemSubcategoryTextField.text = subcategories[row].name
            selectedSubcategoryId = subcategories[row].id
            addItemView.runAnimate(views: descriptionTextView,itemImageView,addVideoButton,galleryButton,videosTableView)
        }
    }
    
}
//MARK: - TextViewProtocol
extension AddItemViewController:UITextViewDelegate{
    
    func textViewDidBeginEditing(_ textView: UITextView) {// UITextView tek tıkla içerik temizle
        
        if isFirstClickOnTextView{//ilk tıklama ise
            descriptionTextView.text = ""//sil
            isFirstClickOnTextView = false
        }
        descriptionViewTextCountLabel.alpha = 1
        textView.layer.borderWidth = 1.0
        textView.layer.borderColor = UIColor.systemGreen.cgColor
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        itemDescriptionCheck = descriptionTextView.text.count > 2
        textView.layer.borderColor = UIColor.clear.cgColor
    }
    
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        if textViewsHelper.checkCharacterTypeInNameTextView(textView: textView, range: range, string: text) && (descriptionTextView.text.count <= 300){
            descriptionViewTextCountLabel.text = "\(descriptionTextView.text.count + 1)/300"
            print("\(descriptionTextView.text.count)")
            return true
        }else{
            textViewsHelper.textViewdFailAnimation(textView: descriptionTextView)
            return false
        }
    }
    
}
//MARK: - UITextFieldDelegate
extension AddItemViewController:UITextFieldDelegate{
    
    func textFieldDidBeginEditing(_ textField: UITextField) {//tf düzenlenmeye başlayınca tetiklenir.
        if textField == itemNameTextField{
            textFieldHelper.textFieldIsEditing(textField: textField,borderColor: .systemGreen,borderWidth: 1.0,cornerRadius: 5.0)
        }else if textField == itemPriceTextField{
            textFieldHelper.textFieldIsEditing(textField: textField,borderColor: .systemGreen,borderWidth: 1.0,cornerRadius: 5.0)
        }else if textField == itemCategoryTextField{
            textFieldHelper.textFieldIsEditing(textField: textField,borderColor: .systemGreen,borderWidth: 1.0,cornerRadius: 5.0)
        }else if textField == itemSubcategoryTextField{
            textFieldHelper.textFieldIsEditing(textField: textField,borderColor: .systemGreen,borderWidth: 1.0,cornerRadius: 5.0)
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        //düzenleniyor
        if textField == itemNameTextField{
            
            if textFieldHelper.checkCharacterTypeInTextField(textField: textField, range: range, string: string){
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
        }else if textField == itemPriceTextField{
            if textFieldHelper.checkCharacterTypeInTextField(textField: textField, range: range, string: string, type:.decimalDigits){
                if textFieldHelper.characterLimit(textField: textField, range: range, string: string, topLimit: 6, bottomLimit: 0){
                    return true
                }else{
                    textFieldHelper.textFieldFailAnimation(textField: textField)
                    return false
                }
            }else{
                return false
            }
        }else{
            textFieldHelper.textFieldFailAnimation(textField: textField)
            return false
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextField.DidEndEditingReason) {
        if textField == itemNameTextField{
            textFieldHelper.textFieldHasEdited(textField: textField)//TF eski haline döner
            itemNameCheck =  textFieldHelper.checkTextFieldDependencies(textfield: textField,topLimit:50,bottomLimit: 5,placeholderName: "Ürün İsmi" )// Gerekli şartların kontrolü
        }else if textField == itemPriceTextField{
            textFieldHelper.textFieldHasEdited(textField: textField)
            itemPriceCheck =  textFieldHelper.checkTextFieldDependencies(textfield: textField,topLimit:6,bottomLimit: 2,placeholderName: "Ürün Fiyat" )
        }else if textField == itemCategoryTextField{
            textFieldHelper.textFieldHasEdited(textField: textField)
        }else if textField == itemSubcategoryTextField{
            textFieldHelper.textFieldHasEdited(textField: textField)
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {// return tuşuna basınca çalışır
        textField.resignFirstResponder()
        return true
    }
    
}
//MARK: - UITableViewDelegate
extension AddItemViewController: UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        videoLinkForTableView.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "addItemCell", for: indexPath) as! AddItemTableViewCell
        cell.videoLabel.text = videoLinkForTableView[indexPath.row]
        return cell
    }
    
    
}
//MARK: - UITableViewDatasource
extension AddItemViewController:UITableViewDelegate{
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return DeviceHelper.getSafeAreaSize()!.height/12
    }
    
}
//MARK: - OBJC Functions
extension AddItemViewController{
    
    @objc func videoUploadRemaining(notification:Notification){
        if let newData = notification.userInfo?["uploadRemainTime"] as? Float {
            uploadFirebaseProgressView.alpha = 1.0
            uploadFirebaseProgressView.setProgress(newData, animated:true)
            if newData == 1.0{
                uploadFirebaseProgressView.alpha = 0.0
                uploadFirebaseProgressView.setProgress(0.0,animated: true)
            }
        }else{
            print("hata")
        }
    }

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
        showFullScreenImage(image: itemImageView.image)

    }
    
}
//MARK: - AddOnSale
extension AddItemViewController{
    
    private func addOnSale(item:Item){
        let loggedUser = UserViewModel.currentUser()
        
        onSaleVM.downloadOnSaleFromFirestore(loggedUser!.email!)
        { onSale in
            
            if onSale == nil{
                self.onSaleVM.createNewOnSale(item: item, ownerId: loggedUser!.email!)
            }else{
                
                onSale?.itemIds.append(item.id)
                self.updateOnSale(onSale: onSale!, withValues: [FirebaseConstants().kITEMIDS:onSale!.itemIds])
            }
        }
    }
    
    private func updateOnSale(onSale:OnSale,withValues:[String:Any]){
        
        onSaleVM.updateOnSaleInFirestore(onSale, withValues: withValues){ error in
            
            if error != nil{
                print("hata ürün satışa çıkanlara eklenemedi")
            }else{
                print("başarılı ürün satışa çıkarılanlara eklendi")
            }
        }
    }

}

