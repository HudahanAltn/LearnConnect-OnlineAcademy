//
//  ItemsViewModel.swift
//  LearnConnectOnlineAcademy
//
//  Created by Hüdahan Altun on 22.11.2024.
//

import Foundation
import UIKit

class ItemViewModel{
    
    @Published var items:[Item] = [Item]()
    @Published var itemImages:[UIImage] = []
    
    //MARK: - Kategori altına item save eden fonksiyon
    
    func saveItemToFirestore(_ item:Item){
        
        FirebaseReference(.Items).document(item.id).setData(itemDictionaryFrom(item)as! [String:Any])
    }
    
    //MARK: - Dict dönüşümü yapan fonksiyon
    
    func itemDictionaryFrom(_ item:Item)->NSDictionary{
        
        return NSDictionary(objects: [item.id,item.categoryId,item.subCategoryId,item.name,item.description,item.price,item.imageLink,item.videoLinks,item.dealerMail],
                            forKeys: [FirebaseConstants().kOBJECTID as NSCopying,
                                      FirebaseConstants().kCATEGORYID as NSCopying,
                                      FirebaseConstants().kSUBCATEGORYID as NSCopying,
                                      FirebaseConstants().kNAME as NSCopying,
                                      FirebaseConstants().kDESCRIPTION as NSCopying,
                                      FirebaseConstants().kPRICE as NSCopying,
                                      FirebaseConstants().kIMAGELINK as NSCopying,
                                      FirebaseConstants().kVIDEOLINKS as NSCopying,
                                      FirebaseConstants().kDEALERNAME as NSCopying])
    }
    
    func saveItemsToFirestore(_ item:Item){
        
        FirebaseReference(.Items).document(item.id).setData(itemDictionaryFrom(item) as! [String:Any])
        
    }
    
    func downloadItemsFromFirebase(withSubCategoryId:String){ //download item
        self.items.removeAll()
        FirebaseReference(.Items).whereField(FirebaseConstants().kSUBCATEGORYID, isEqualTo: withSubCategoryId).getDocuments{
            
            snapshot,error in
            guard let snapshot = snapshot else{
                return
            }
            if !snapshot.isEmpty{
                for itemDict in snapshot.documents{
                    self.items.append(Item(_dictionary: itemDict.data() as NSDictionary))
                }
            }
        }
    }
}