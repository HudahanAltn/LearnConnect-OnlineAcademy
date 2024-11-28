//
//  Review.swift
//  LearnConnectOnlineAcademy
//
//  Created by Hüdahan Altun on 26.11.2024.
//

import Foundation

class Review{
    
    var id:String!//Yorum id(pk)
    var ownerId:String!//yorum sahibinin id'si.yorum sahibinin unique id'si email adresidir. fk
    var itemID:String!//ürün fk
    var comment:String!// yorum içeriği
    var point:String!// kurs puanı
    
    init(){
        
    }
    
    init(_dictionary:NSDictionary){
        
        id = _dictionary[FirebaseConstants().kOBJECTID] as? String
        ownerId = _dictionary[FirebaseConstants().kEMAIL] as? String
        itemID = _dictionary[FirebaseConstants().kITEMID] as? String
        comment = _dictionary[FirebaseConstants().kCOMMENT] as? String
        point = _dictionary[FirebaseConstants().kPOINT] as? String

    }
}
