//
//  Item.swift
//  LearnConnectOnlineAcademy
//
//  Created by Hüdahan Altun on 22.11.2024.
//

import Foundation

class Item:Equatable{

    var id:String! //pri key
    var categoryId:String! //foreign key
    var subCategoryId:String! //foreign key
    var name:String! // video kurs ismi
    var description:String!// açıklaması
    var price:Double! //  fiyatı
    var imageLink:String! // kapak resim linki
    var videoLinks:[String]! //mulitple video link. images will be stored on firestore
    var dealerMail:String! // satıcı foreignKey
    
    init(){
    }

    init(_dictionary:NSDictionary){
        id = _dictionary[FirebaseConstants().kOBJECTID] as? String
        categoryId = _dictionary[FirebaseConstants().kCATEGORYID] as? String
        subCategoryId = _dictionary[FirebaseConstants().kSUBCATEGORY_PATH] as? String
        name = _dictionary[FirebaseConstants().kNAME] as? String
        description = _dictionary[FirebaseConstants().kDESCRIPTION] as? String
        price  = _dictionary[FirebaseConstants().kPRICE] as? Double
        imageLink = _dictionary[FirebaseConstants().kIMAGELINK] as? String
        videoLinks = _dictionary[FirebaseConstants().kVIDEOLINKS] as? [String]
        dealerMail = _dictionary[FirebaseConstants().kDEALERNAME] as? String
    }
    
    
    static func == (lhs: Item, rhs: Item) -> Bool {
        return lhs.id == rhs.id
    }
    
    
}
