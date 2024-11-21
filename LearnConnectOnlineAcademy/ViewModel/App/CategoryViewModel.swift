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
    
    //MARK: - Kategori kayıtlarını tek tek çeken fonksiyon
    
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
    
    
    
}



