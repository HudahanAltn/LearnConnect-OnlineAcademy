//
//  ItemsViewModel.swift
//  LearnConnectOnlineAcademy
//
//  Created by Hüdahan Altun on 22.11.2024.
//

import Foundation
import UIKit
import AlgoliaSearchClient
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
    
    //kullanıcınnı satın adlığı kurslar
    func downloadPurchasedItems(_ withIds:[String],completion:@escaping (_ itemArray:[Item])->Void){
        var count = 0//indirelecek item sayısını tutar
        var itemArray:[Item] = [Item]()//itemleri tutacka olan array
        if withIds.count > 0 {
            for itemId in withIds{
                FirebaseReference(.Items).document(itemId).getDocument{ snapshot,error in
                    guard let snapshot = snapshot else{
                        completion(itemArray)
                        return
                    }
                    
                    if snapshot.exists {
                        itemArray.append(Item(_dictionary: snapshot.data()! as NSDictionary))//item yarat ve diziye ekle
                        count += 1
                    }else {
                        completion(itemArray)
                    }

                    if count == withIds.count {
                        completion(itemArray)
                    }
                }
            }
        }else{
            completion(itemArray)
        }
    }
    
    //MARK: - Search
    func downloadItemsForSearching(_ withIds:[String],completion:@escaping (_ itemArray:[Item])->Void){
        
        var count = 0
        var itemArray:[Item] = [Item]()
        if withIds.count > 0{
            for itemId in withIds{
                FirebaseReference(.Items).document(itemId).getDocument{
                    snapshot,error in
                    guard let snapshot = snapshot else{
                        completion(itemArray)
                        return
                    }
                    if snapshot.exists{
                        itemArray.append(Item(_dictionary: snapshot.data()! as NSDictionary))
                        count += 1
                    }else{
                        completion(itemArray)
                    }
    
                    if count == withIds.count{
                        
                        completion(itemArray)
                    }
                }
            }
        }else{
            completion(itemArray)
        }
    }
    func saveItemToAlgolia(item:Item){
        
        let index = AlgoliaService.shared.index
        let itemToSave = AlgoliaItem(objectID: ObjectID(rawValue: item.id!), name: item.name)
        let _: ()? = try? index.saveObject(itemToSave).wait()
    }
}
