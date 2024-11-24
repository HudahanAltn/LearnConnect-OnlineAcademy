//
//  Alert.swift
//  LearnConnectOnlineAcademy
//
//  Created by Hüdahan Altun on 21.11.2024.
//

import Foundation
import UIKit

class Alert{

    static let hesapGuv:String = "Mail adresiniz \"@gmail.com\" uzantılı olmalıdır.\nŞifreniz 8-15 karakter aralığında olmalıdır.Ayrıca sifreniz en az bir büyük harf, küçük harf, sayı ve .,$@$#!%*?& içermelidir"
    
    static let noConnectionMessage = "İnternet Bağlantınızı Kontrol Ediniz!"
    static let noConnectionTitle = "Bilgilendirme"
    
    static func createAlert(title:String,message:String,view:UIViewController){
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let OKButton = UIAlertAction(title: "Tamam", style: .cancel)
        alertController.addAction(OKButton)
        view.present(alertController, animated: true)
    }
    
    static func createAlertWithPop(title:String,message:String,view:UIViewController){
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let OKButton = UIAlertAction(title: "Tamam", style: .cancel){ _ in
            
            view.navigationController?.popViewController(animated: true)
        }
        alertController.addAction(OKButton)
        view.present(alertController, animated: true)
    }
    
}

