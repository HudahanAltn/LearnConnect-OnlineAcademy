//
//  Cart.swift
//  LearnConnectOnlineAcademy
//
//  Created by Hüdahan Altun on 23.11.2024.
//

import Foundation

class Cart{
    
    var id:String!
    var ownerId:String!
    var itemIds:[String]!
    
    init(){
    }
    
    init(_dictionary:NSDictionary){
        
        id = _dictionary[FirebaseConstants().kOBJECTID] as? String
        ownerId = _dictionary[FirebaseConstants().kOWNERID] as? String
        itemIds = _dictionary[FirebaseConstants().kITEMIDS] as? [String]
    }
}
