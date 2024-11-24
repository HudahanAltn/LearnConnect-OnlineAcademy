//
//  SubcategoryViewModel.swift
//  LearnConnectOnlineAcademy
//
//  Created by Hüdahan Altun on 22.11.2024.
//

import Foundation

class SubcategoryViewModel{
    
    @Published var subCategories:[SubCategory] = [SubCategory]()
    
    
    func downloadSubCategoriesFromFirebase(withSubCategoryId:String){
        subCategories.removeAll()
        FirebaseReference(.SubCategory).whereField(FirebaseConstants().kCATEGORYID, isEqualTo: withSubCategoryId).getDocuments{
            snapshot,error in
            
            guard let snapshot = snapshot else{
                return
            }
            if !snapshot.isEmpty{
                for subcatDict in snapshot.documents{
                    self.subCategories.append(SubCategory(_dictionary: subcatDict.data() as NSDictionary))
                }
                

            }
        
        }
    }
}





