//
//  CategoryViewModel.swift
//  LearnConnectOnlineAcademy
//
//  Created by Hüdahan Altun on 21.11.2024.
//

import Foundation
import UIKit

class CategoryViewModel{
    
    @Published var categories:[Category] = [Category]()

    func downloadCategoriesFromFirebase(){
        categories.removeAll()
        FirebaseReference(.Category).order(by: FirebaseConstants().kNAME).getDocuments{
            snapshot,error in
            guard let snapshot = snapshot else{
                return
            }
            if !snapshot.isEmpty{
                
                for categoryDict in snapshot.documents{
                    self.categories.append(Category(_dictionary: categoryDict.data() as NSDictionary))
                }
            }
        }
    }
    
    func downloadCategoryName(objectId:String,completion:@escaping(_ categoryName:String?)->Void){
        FirebaseReference(.Category).whereField(FirebaseConstants().kOBJECTID, isEqualTo: objectId).getDocuments{
            snapshot,error in
            guard let snapshot = snapshot else{
                completion(nil)
                return
            }
            if !snapshot.isEmpty{
                for categoryDict in snapshot.documents{
                    
                    let category = Category(_dictionary: categoryDict.data() as NSDictionary)
                    completion(category.name)
                }
            }
        }
    }
    
    
}



