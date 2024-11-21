//
//  FirebaseConstants.swift
//  LearnConnectOnlineAcademy
//
//  Created by Hüdahan Altun on 21.11.2024.
//

import Foundation

//bunlar firebasedeki tablo pathlerine karşılık gelir.

struct FirebaseConstants{
    
    let kFILEREFERENCE = "gs://vakifbank-intern.appspot.com" // firebase storage link
    
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

}

