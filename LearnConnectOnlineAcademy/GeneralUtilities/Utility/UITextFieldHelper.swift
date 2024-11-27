//
//  UITextFieldHelper.swift
//  LearnConnectOnlineAcademy
//
//  Created by Hüdahan Altun on 22.11.2024.
//

import Foundation
import UIKit

class UITextFieldHelper{

//MARK: - MultiUITextField on same view
    func setTextFieldAutoCorrectionType(type:UITextAutocorrectionType,textFields:UITextField...){
        for textfield in textFields{
            textfield.autocorrectionType = type
        }
    }
    
    func setTextFieldAutoCapitalizationtType(type:UITextAutocapitalizationType,textFields:UITextField...){
        for textfield in textFields{
            textfield.autocapitalizationType = type
        }
    }
    
    func setTextFieldKeyboardType(type:UIKeyboardType,returnType:UIReturnKeyType,textFields:UITextField...){
        for textfield in textFields{
            textfield.keyboardType = type
            textfield.returnKeyType = returnType
        }
    }
    
    
//MARK: -  UITextField Image
    func setTextFieldsDefaultImageViewAtRight(defaultImage:UIImage,color:UIColor,textFields:UITextField...){
        for textfield in textFields{
            textfield.setIconAtRight(defaultImage,color: color)
        }
    }
    
    func setTextFieldsDefaultImageViewAtLeft(defaultImage:UIImage,color:UIColor,textFields:UITextField...){
        for textfield in textFields{
            textfield.setIconAtLeft(defaultImage,color: color)
        }
    }
    
//MARK: - UITextField Allowed Character Types (all textfield)
    
    func checkCharacterTypeInTextField(textField:UITextField,range:NSRange,string:String,type:CharacterSet) -> Bool{
        let allowedCharacterSet = type
        if let text = textField.text,let textRange = Range(range, in: text) {
            let updatedText = text.replacingCharacters(in: textRange, with: string)
            return updatedText.rangeOfCharacter(from: allowedCharacterSet.inverted) == nil
        }
        return true
    }
    func checkCharacterTypeInNameTextField(textField:UITextField,range:NSRange,string:String) -> Bool{
        let allowedCharacterSet = CharacterSet(charactersIn: "abcçdefgğhıijklmnoöpqrsştuüvwxyzABCÇDEFGĞHIİJKLMNOÖPQRSŞTUÜVWXYZ ")
        if let text = textField.text,let textRange = Range(range, in: text) {
            let updatedText = text.replacingCharacters(in: textRange, with: string)
            return updatedText.rangeOfCharacter(from: allowedCharacterSet.inverted) == nil
        }
        return true
    }
    
    func checkCharacterTypeInAdressTextField(textField:UITextField,range:NSRange,string:String) -> Bool{
        let allowedCharacterSet = CharacterSet(charactersIn: "abcçdefgğhıijklmnoöpqrsştuüvwxyzABCÇDEFGĞHIİJKLMNOÖPQRSŞTUÜVWXYZ/")
        if let text = textField.text,let textRange = Range(range, in: text) {
            let updatedText = text.replacingCharacters(in: textRange, with: string)
            return updatedText.rangeOfCharacter(from: allowedCharacterSet.inverted) == nil
        }
        return true
    }
    
    func checkCharacterTypeInEmailTextField(textField:UITextField,range:NSRange,string:String) -> Bool{
        let allowedCharacterSet = CharacterSet(charactersIn: "abcçdefgğhıijklmnoöpqrsştuüvwxyzABCÇDEFGĞHIİJKLMNOÖPQRSŞTUÜVWXYZ@._0987654321")
        if let text = textField.text,let textRange = Range(range, in: text) {
            let updatedText = text.replacingCharacters(in: textRange, with: string)
            return updatedText.rangeOfCharacter(from: allowedCharacterSet.inverted) == nil
        }
        return true
    }
    
    func checkCharacterTypeInTextField(textField:UITextField,range:NSRange,string:String) -> Bool{
        let allowedCharacterSet = CharacterSet(charactersIn: "abcçdefgğhıijklmnoöpqrsştuüvwxyzABCÇDEFGĞHIİJKLMNOÖPQRSŞTUÜVWXYZ- 0987654321")
        if let text = textField.text,let textRange = Range(range, in: text) {
            let updatedText = text.replacingCharacters(in: textRange, with: string)
            return updatedText.rangeOfCharacter(from: allowedCharacterSet.inverted) == nil
        }
        return true
    }
    
    func checkCharacterTypeInDateTextField(textField:UITextField,range:NSRange,string:String) -> Bool{
        let allowedCharacterSet = CharacterSet(charactersIn: "/0987654321")
        if let text = textField.text,let textRange = Range(range, in: text) {
            let updatedText = text.replacingCharacters(in: textRange, with: string)
            return updatedText.rangeOfCharacter(from: allowedCharacterSet.inverted) == nil
        }
        return true
    }
    
    
//MARK: - UITextFiel text Dependencies
    func checkTextFieldDependencies(textfield:UITextField,equal:Int,placeholderName:String)->Bool{
        let nameTextCount = textfield.text!.count
        if (nameTextCount == equal) {
            textfield.setIconAtRight(UIImage(systemName: "checkmark.circle")!, color: .systemGreen)
            return true
        }else if nameTextCount == 0 {
            textfield.placeholder = "\(placeholderName)"
            textfield.setIconAtRight(UIImage(systemName: "pencil.circle")!, color: .black)
            textFieldFailAnimation(textField: textfield)
            return false
        }else {
            textfield.placeholder = "\(placeholderName) \(equal) haneli olmalıdır"
            textfield.text = ""
            textfield.setIconAtRight(UIImage(systemName: "pencil.circle")!, color: .black)
            textFieldFailAnimation(textField: textfield)
            return false
        }
    }
    
    func checkTextFieldDependencies(textfield:UITextField,topLimit:Int,bottomLimit:Int,placeholderName:String)->Bool{
        let nameTextCount = textfield.text!.count
        if (nameTextCount <= topLimit) && (nameTextCount > bottomLimit) {
            textfield.setIconAtRight(UIImage(systemName: "checkmark.circle")!, color: .systemGreen)
            return true
        }else if nameTextCount == 0 {
            textfield.placeholder = "\(placeholderName)"
            textfield.setIconAtRight(UIImage(systemName: "pencil.circle")!, color: .black)
            textFieldFailAnimation(textField: textfield)
            return false
        }else {
            textfield.placeholder = "\(placeholderName) \(bottomLimit)-\(topLimit) arasında olmalıdır"
            textfield.text = ""
            textfield.setIconAtRight(UIImage(systemName: "pencil.circle")!, color: .black)
            textFieldFailAnimation(textField: textfield)
            return false
        }
    }
    
//MARK: - UITextField Fail Animation
    func textFieldFailAnimation(textField:UITextField){
        UIImpactFeedbackGenerator(style: .soft).impactOccurred()

        let shakeAnimation = CABasicAnimation(keyPath: "position")
        shakeAnimation.duration = 0.1
        shakeAnimation.repeatCount = 3
        shakeAnimation.autoreverses = true
        shakeAnimation.fromValue = NSValue(cgPoint: CGPoint(x: textField.center.x - 3, y: textField.center.y))
        shakeAnimation.toValue = NSValue(cgPoint: CGPoint(x: textField.center.x + 3, y: textField.center.y))
        textField.layer.add(shakeAnimation, forKey: "shake")
        
        textField.layer.borderColor = UIColor.red.cgColor
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            textField.layer.borderColor = UIColor.clear.cgColor
        }
    }
   
//MARK: - UItextField Character Count Label
    func characterLimit(textField:UITextField,range:NSRange,string:String,topLimit:Int,bottomLimit:Int)->Bool{
        let currentText = textField.text ?? ""
        let newText = (currentText as NSString).replacingCharacters(in: range, with: string)
        let characterCount = newText.count
        textField.rightViewMode = .always
        let characterCountLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
        characterCountLabel.textColor = .darkGray
        characterCountLabel.font = UIFont.systemFont(ofSize: 15)
        textField.rightView = characterCountLabel
        
        if   bottomLimit <= characterCount && characterCount <= topLimit{
            characterCountLabel.text = "\(characterCount)/\(topLimit)"
            return true
        }else{
            characterCountLabel.text = "\(characterCount-1)/\(topLimit)"
            return false
        }
    }
    
    func textFieldIsEditing(textField:UITextField,borderColor:UIColor,borderWidth:Double,cornerRadius:Double){
        textField.layer.borderWidth = borderWidth
        textField.layer.borderColor = borderColor.cgColor
        textField.layer.cornerRadius = cornerRadius
    }

    func textFieldHasEdited(textField:UITextField){
        textField.layer.borderColor = UIColor.clear.cgColor
        textField.resignFirstResponder()
    }
    
    func setTextFieldBorderColor(borderColor:UIColor,textFields:UITextField...){
        
        for textField in textFields{
            textField.layer.borderColor = borderColor.cgColor
        }
    }
    
}
