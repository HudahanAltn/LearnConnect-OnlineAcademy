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
        print("categori yaratıldı normal")
    }
    
    init(_dictionary:NSDictionary){//firebase için
        id = _dictionary[FirebaseConstants().kOBJECTID] as! String
        name = _dictionary[FirebaseConstants().kNAME] as! String
        print("categori yaratıldı dict")

    }
    deinit{
        print("category yok edildis")
    }
    
  
}
