//
//  WelcomeHelper.swift
//  LearnConnectOnlineAcademy
//
//  Created by Hüdahan Altun on 24.11.2024.
//


import Foundation
import UIKit

class WelcomeHelper{
    
    func setButtonCornerRadius(value:CGFloat,views:UIButton...){//butonların corner radius setleyen fonksiyon
        for view in views{
            view.layer.cornerRadius = value
        }
    }
    
    func setAlphaValue(value:CGFloat,views:UIView...){//viewların alpha değerlerini setleyen fonksiyon
        for view in views{
            view.alpha = value
        }
    }
    
    func runAppNameAnimation(label:UILabel,textName:String){//giriş yazı animasyon fonksiyonu
        label.alpha = 1
        label.text = ""
        var charIndex = 0.0
        
        for letter in textName {
            Timer.scheduledTimer(withTimeInterval: 0.1 * charIndex, repeats: false){ timer in
                label.text?.append(letter)
            }
            charIndex += 1
        }
        UIView.animate(withDuration: 2, delay: 1, options: [.repeat,.autoreverse]){
            label.alpha = 0.1
        }
    }
    
    //welcomeVC giriş animasyonu
    func runIndroductionAnimation(loginButton:UIButton,passwordForgetButton:UIButton,emailTextField:UITextField,passwordTextField:UITextField,showPasswordButton:UIButton){
        
        UIView.animate(withDuration: 0.5){
            let move = CGAffineTransform(translationX: 0, y: -20)
            let small = CGAffineTransform (scaleX: 1.0, y: 1.0)
            let x = move.concatenating(small)
            loginButton.transform = x
            passwordForgetButton.transform = x
            self.setAlphaValue(value: 1, views: emailTextField,passwordTextField,showPasswordButton,loginButton,passwordForgetButton)
        }
    }

}
