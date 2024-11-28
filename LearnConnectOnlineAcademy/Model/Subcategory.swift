//
//  Subcategory.swift
//  LearnConnectOnlineAcademy
//
//  Created by Hüdahan Altun on 22.11.2024.
//

import Foundation
import UIKit

class SubCategory{
    
    var id:String
    var categoryId:String! //foreign key
    var name:String

    
    init(_name:String,_categoryId:String){
        id = ""
        name = _name
        categoryId = _categoryId
    }
    
    init(_dictionary:NSDictionary){
        id = _dictionary[FirebaseConstants().kOBJECTID] as! String
        categoryId = _dictionary[FirebaseConstants().kCATEGORYID] as? String
        name = _dictionary[FirebaseConstants().kNAME] as! String
    }
}
