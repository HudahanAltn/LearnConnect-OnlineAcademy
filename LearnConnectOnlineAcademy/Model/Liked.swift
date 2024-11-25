//
//  Liked.swift
//  LearnConnectOnlineAcademy
//
//  Created by Hüdahan Altun on 25.11.2024.
//

import Foundation


class Liked{//kullanıcın beğendiği ürünlerin tutulacağı liste
    
    var id:String!//listenin kendi id'si
    var ownerId:String!//liste sahibinin id'si
    var itemIds:[String]!//listeye eklenen ürünlerin id'leri lazım.Sepet 1 tane sepetteki ürünler birden fazladır.
    
    init(){
        
    }
    
    init(_dictionary:NSDictionary){//dict dönüşüm.
        
        id = _dictionary[FirebaseConstants().kOBJECTID] as? String
        ownerId = _dictionary[FirebaseConstants().kOWNERID] as? String
        itemIds = _dictionary[FirebaseConstants().kITEMIDS] as? [String]
    }
}
