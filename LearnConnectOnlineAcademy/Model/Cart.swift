//
//  Cart.swift
//  LearnConnectOnlineAcademy
//
//  Created by Hüdahan Altun on 23.11.2024.
//

import Foundation

class Cart{
    
    var id:String!//sepetin kendi id'si
    var ownerId:String!//sepet sahibinin id'si.sepet sahibinin unique id'si email adresidir.
    var itemIds:[String]!//sepete eklenen ürünlerin id'leri lazım.Sepet 1 tane sepetteki ürünler birden fazladır.
    
    init(){
        
    }
    
    init(_dictionary:NSDictionary){//dict dönüşüm.
        
        id = _dictionary[FirebaseConstants().kOBJECTID] as? String
        ownerId = _dictionary[FirebaseConstants().kOWNERID] as? String
        itemIds = _dictionary[FirebaseConstants().kITEMIDS] as? [String]
    }
}
