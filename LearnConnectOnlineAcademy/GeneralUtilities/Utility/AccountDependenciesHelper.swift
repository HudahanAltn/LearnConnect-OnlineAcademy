//
//  AccountDependenciesHelper.swift
//  LearnConnectOnlineAcademy
//
//  Created by Hüdahan Altun on 24.11.2024.
//


import Foundation
import UIKit


class AccountDependenciesHelper{
    
    func checkEmailDependencies(email:UITextField)->Bool{
        let mailTextCount = email.text!.count
        if mailTextCount > 11 && mailTextCount < 40 {
            print("mail 11 haneden büyük 40 dan küçük istenen aralıkta")
            return true
        }else if mailTextCount == 0 {
            return false
        }else {
            return false
        }
    }
    
    func checkPasswordDependencies(password:UITextField)->Bool{
        let passtextcount = password.text!.count
        if passtextcount > 8 && passtextcount < 15 {
            print("sifre 8-30 aralıgında")
            return true
        }else if passtextcount == 0 {
            return false
        }else {
            return false
        }
    }
    
}
