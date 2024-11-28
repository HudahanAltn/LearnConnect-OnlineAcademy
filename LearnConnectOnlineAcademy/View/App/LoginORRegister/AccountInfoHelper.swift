//
//  AccountInfoHelper.swift
//  LearnConnectOnlineAcademy
//
//  Created by Hüdahan Altun on 24.11.2024.
//

import Foundation
import UIKit


class AccountInfoHelper{
  
    func isGmail(mail:String)->Bool{
        let range = mail.index(mail.endIndex,offsetBy:-10) ..< mail.endIndex
        let arraySlicer = mail[range]
        let newArray = Array(arraySlicer)
        if newArray == FirebaseConstants.gmailCheck{
            return true
        }else{
            return false
        }
    }
    
    func isPasswordSecure(sifre:String)->Bool{
        let password = NSPredicate(format: "SELF MATCHES %@ ", "^(?=.*[a-z])(?=.*[.,$@$#!%*?&])(?=.*[0-9])(?=.*[A-Z]).{8,}$")
        return password.evaluate(with: sifre)
    }
    
    func setUserLabels(tempUser:User,userNameLabel:UILabel,userPhoneLabel:UILabel){
        userNameLabel.text = tempUser.firstName
        userPhoneLabel.text = tempUser.phoneNumber
    }

}
