//
//  OnSaleViewModel.swift
//  LearnConnectOnlineAcademy
//
//  Created by Hüdahan Altun on 27.11.2024.
//


import Foundation


class OnSaleViewModel{
    
    
    func saveOnSaleToFirestore(_ onSale :OnSale){
        FirebaseReference(.OnSale).document(onSale.id).setData(onSaleDictionaryFrom(onSale)as! [String:Any] )
    }

    func onSaleDictionaryFrom(_ onSale:OnSale)->NSDictionary{
        return NSDictionary(objects:[onSale.id,onSale.ownerId,onSale.itemIds],forKeys: [FirebaseConstants().kOBJECTID as NSCopying,
            FirebaseConstants().kOWNERID as NSCopying,
            FirebaseConstants().kITEMIDS as NSCopying])
    }
 
    func downloadOnSaleFromFirestore(_ ownerId:String,completion:@escaping(_ onSale :OnSale?)->Void){
        FirebaseReference(.OnSale).whereField(FirebaseConstants().kOWNERID,isEqualTo: ownerId).getDocuments{
            snapshot,error in
            guard let snapshot = snapshot else{
                completion(nil)//sepet yok
                return
            }
            if !snapshot.isEmpty && snapshot.documents.count>0{//sepet var
                
                let onSale = OnSale(_dictionary: snapshot.documents.first!.data() as NSDictionary)
                completion(onSale) //sepeti döndür
            }else{
                completion(nil)//sepet yok
            }
            
        }
    }

    func updateOnSaleInFirestore(_ onSale:OnSale, withValues:[String:Any],completion:@escaping(_ error:Error?)->Void){
        FirebaseReference(.OnSale).document(onSale.id).updateData(withValues){
            error in
            
            completion(error)
        }
    }

    func createNewOnSale(item:Item,ownerId:String){
        let newOnSale = OnSale()//
        newOnSale.id = UUID().uuidString
        newOnSale.ownerId =  ownerId
        newOnSale.itemIds = [item.id]
        saveOnSaleToFirestore(newOnSale)
       
    }

    func downloadItemsForOnSale(_ withIds:[String],completion:@escaping (_ itemArray:[Item])->Void){
        var count = 0//indirelecek item sayısını tutar
        var itemArray:[Item] = [Item]()//itemleri tutacka olan array
        
        if withIds.count > 0{
            print("for öncesi giriş withIds sayısı:\(withIds.count)")
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
                    }
                    else{
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
}
