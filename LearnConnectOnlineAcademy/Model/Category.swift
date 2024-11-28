//
//  Category.swift
//  LearnConnectOnlineAcademy
//
//  Created by Hüdahan Altun on 21.11.2024.
//

import Foundation


class Category{
    
    var id:String
    var name:String
    
    init(_name:String){
        id = ""
        name = _name
    }
    
    init(_dictionary:NSDictionary){
        id = _dictionary[FirebaseConstants().kOBJECTID] as! String
        name = _dictionary[FirebaseConstants().kNAME] as! String
    }
    
  
}
