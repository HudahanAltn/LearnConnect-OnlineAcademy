//
//  UITextViewHelper.swift
//  LearnConnectOnlineAcademy
//
//  Created by Hüdahan Altun on 22.11.2024.
//

import UIKit


class UITextViewHelper {
    
    //MARK: - MultiUITextField on same view
    func setTextViewAutoCorrectionType(type:UITextAutocorrectionType,textViews:UITextView...){
            for textView in textViews{
                textView.autocorrectionType = type
            }
        }
        
        func setTextViewAutoCapitalizationtType(type:UITextAutocapitalizationType,textViews:UITextView...){
            for textView in textViews{
                textView.autocapitalizationType = type
            }
        }
        
        func setTextViewKeyboardType(type:UIKeyboardType,returnType:UIReturnKeyType,textViews:UITextView...){
            for textView in textViews{
                textView.keyboardType = type
                textView.returnKeyType = returnType
            }
        }
        
   
    func checkCharacterTypeInNameTextView(textView:UITextView,range:NSRange,string:String) -> Bool{
        let allowedCharacterSet = CharacterSet(charactersIn: "abcçdefgğhıijklmnoöpqrsştuüvwxyzABCÇDEFGĞHIİJKLMNOÖPQRSŞTUÜVWXYZ., 0123456789")
        if let text = textView.text,let textRange = Range(range, in: text) {
            let updatedText = text.replacingCharacters(in: textRange, with: string)
            return updatedText.rangeOfCharacter(from: allowedCharacterSet.inverted) == nil
        }
        return true
    }
    
    func textViewdFailAnimation(textView:UITextView){
        UIImpactFeedbackGenerator(style: .soft).impactOccurred()
        let shakeAnimation = CABasicAnimation(keyPath: "position")
        shakeAnimation.duration = 0.1
        shakeAnimation.repeatCount = 3
        shakeAnimation.autoreverses = true
        shakeAnimation.fromValue = NSValue(cgPoint: CGPoint(x: textView.center.x - 3, y: textView.center.y))
        shakeAnimation.toValue = NSValue(cgPoint: CGPoint(x: textView.center.x + 3, y: textView.center.y))
        textView.layer.add(shakeAnimation, forKey: "shake")
        
        textView.layer.borderColor = UIColor.red.cgColor
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            textView.layer.borderColor = UIColor.clear.cgColor
        }
    }
    
}
