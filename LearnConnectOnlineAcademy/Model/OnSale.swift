//
//  OnSale.swift
//  LearnConnectOnlineAcademy
//
//  Created by Hüdahan Altun on 27.11.2024.
//

import Foundation

import Foundation

class OnSale{
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
