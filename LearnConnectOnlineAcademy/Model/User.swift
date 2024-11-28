//
//  User.swift
//  LearnConnectOnlineAcademy
//
//  Created by Hüdahan Altun on 24.11.2024.
//

import Foundation


class User{
    
    var email:String?//kullanıcı mail aynı zamanda unique ıd
    var firstName:String//kullanıcı ad
    var lastName:String//kullanıcı soyad
    var fullName:String//kullanıcı tam isim ad + soyad
    var fullAdress:String//kullanıcının adresi
    var purchasedItemIds:[String]//satın alınan ürünler id'lerini tutacak olan array
    var onBoard:Bool //?
    
    var turkishCitizenshipId:String//kullanıcı tc no
    var phoneNumber:String//kullanıcı telefon no
    var dateOfBirth:String//kullanıcı dogum tarih
    var profilePicture:String?//kullanıcı profil resmi imagelink şeklinde tutulacak
    

    init(email: String?, firstName: String, lastName: String,fullAdres:String,turkishCitizenshipId: String, phoneNumber: String,profilePicture:String?, dateOfBirth: String) {
        self.email = email
        self.firstName = firstName
        self.lastName = lastName
        self.fullName = firstName + " " + lastName
        self.fullAdress = fullAdres//adres boş olsun
        self.onBoard = false
        self.purchasedItemIds = []//satın alınan ürün yok
        
        self.turkishCitizenshipId = turkishCitizenshipId
        self.phoneNumber = phoneNumber
        self.dateOfBirth = dateOfBirth
        self.profilePicture = profilePicture
        
    }
    
    init(_dictionary:NSDictionary){
        
        if let mail = _dictionary[FirebaseConstants().kEMAIL]{
            
            email = mail as! String
        }else{
            email = ""
        }
        
        if let fname = _dictionary[FirebaseConstants().kFIRSTNAME]{
            
            firstName = fname as! String
        }else{
            firstName = ""
        }
        
        if let lname = _dictionary[FirebaseConstants().kLASTNAME]{
            
            lastName = lname as! String
        }else{
            lastName = ""
        }
        
        fullName = firstName + " " + lastName
        
        if let fAdress = _dictionary[FirebaseConstants().kFULLADRESS]{
            
            fullAdress = fAdress as! String
        }else{
            fullAdress = ""
        }
        
        if let onB = _dictionary[FirebaseConstants().kONBOARD]{
            
            onBoard = onB as! Bool
        }else{
            onBoard = false
        }
        if let pIds = _dictionary[FirebaseConstants().kPURCHASEDITEMIDS]{
            
            purchasedItemIds = pIds as! [String]
        }else{
            purchasedItemIds = []
        }
        
        if let citizien = _dictionary[FirebaseConstants().kCITIZIEN]{
            
            turkishCitizenshipId = citizien as! String
        }else{
            turkishCitizenshipId = ""
        }
        if let birth = _dictionary[FirebaseConstants().kDATEOFBIRTH]{
            
            dateOfBirth = birth as! String
        }else{
            dateOfBirth = ""
        }
        if let phone = _dictionary[FirebaseConstants().kPHONE]{
            
            phoneNumber = phone as! String
        }else{
            phoneNumber = ""
        }
        if let picture = _dictionary[FirebaseConstants().kIMAGENAME]{
            
            profilePicture = picture as! String
        }else{
            profilePicture = ""
        }
    }

}
