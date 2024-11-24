//
//  FirebaseConstants.swift
//  LearnConnectOnlineAcademy
//
//  Created by Hüdahan Altun on 21.11.2024.
//

import Foundation

//bunlar firebasedeki tablo pathlerine karşılık gelir.

struct FirebaseConstants{
    
    let kFILEREFERENCE = "gs://learnconnectonlineacademy.firebasestorage.app" // firebase storage link
    
    let kUSER_PATH  = "User"
    let kCATEGORY_PATH  = "Category"
    let kSUBCATEGORY_PATH = "SubCategory"
    let kITEMS_PATH = "Items"
    let kCART_PATH  = "Cart"
    
    
    //Kategori tablosundaki satırlar firebaseden json olarak gelir.bu sabitler firebase de json keyleridir.
    let kNAME = "name"
    let kOBJECTID = "objectId"

    //AltKategoritablosu
    let kCATEGORYID = "categoryId"//foreign key
    let kSUBCATEGORYID = "subcategoryId" //foreignkey
    let kDESCRIPTION = "description" // açıklaması
    let kPRICE = "price" //fiyat
    let kVIDEOLINKS = "videoLinks"
    let kIMAGELINK = "imageLink"
    let kDEALERNAME = "dealerName" //user tablosunundan fk

    //sepet
    let kOWNERID =  "ownerId"
    let kITEMIDS = "itemIds"
    
    //user
    let kEMAIL = "email"
    let kFIRSTNAME = "firstName"
    let kLASTNAME = "lastName"
    let kFULLNAME = "fullName"
    let kFULLADRESS =  "fullAdress"
    let kIMAGENAME = "imageName"
    let kCITIZIEN = "citizien"
    let kPHONE = "phoneNumber"
    let kDATEOFBIRTH = "dateOfBirth"
    
    let kONBOARD = "onBoard"
    let kPURCHASEDITEMIDS = "purchasedItemIds"

    static let gmailCheck:[Substring.Element] = ["@", "g", "m", "a", "i", "l", ".", "c", "o", "m"]

}

