//
//  CartViewModel.swift
//  LearnConnectOnlineAcademy
//
//  Created by Hüdahan Altun on 23.11.2024.
//

import Foundation
import UIKit

class CartViewModel{
    
    func saveCartToFirestore(_ cart :Cart){// yaratılan cart'ı firebase'e ekle
        
        
        FirebaseReference(.Cart).document(cart.id).setData(cartDictionaryFrom(cart)as! [String:Any] )
    }

    func cartDictionaryFrom(_ cart:Cart)->NSDictionary{//dict dönüşümü yapan fonksiyon
     
        return NSDictionary(objects:[cart.id,cart.ownerId,cart.itemIds],forKeys: [FirebaseConstants().kOBJECTID as NSCopying,
            FirebaseConstants().kOWNERID as NSCopying,
            FirebaseConstants().kITEMIDS as NSCopying])
    }
    
    //sepeti ownerID'ye göre getir.Varsa bi sepet getirir yoksa getirmez zaten yoksa yaratacağız varsa güncelliceğiz.
    func downloadCartFromFirestore(_ ownerId:String,completion:@escaping(_ cart :Cart?)->Void){
        //owner id kullanıcın email adresi olacak.
        FirebaseReference(.Cart).whereField(FirebaseConstants().kOWNERID,isEqualTo: ownerId).getDocuments{
            snapshot,error in
            
            guard let snapshot = snapshot else{
                
                completion(nil)//sepet yok
                return
            }
            
            if !snapshot.isEmpty && snapshot.documents.count>0{//sepet var
                
                let cart = Cart(_dictionary: snapshot.documents.first!.data() as NSDictionary)
                completion(cart) //sepeti döndür
                
            }else{
                completion(nil)//sepet yok
            }
            
        }
    }
    
    //var olan sepet güncellenir.
    func updateCartInFirestore(_ cart:Cart, withValues:[String:Any],completion:@escaping(_ error:Error?)->Void){
        
        //cart id si bilinen sepeti güncelle
        FirebaseReference(.Cart).document(cart.id).updateData(withValues){
            error in
            
            completion(error)//hata var yada yok döndür gitsin
        }
    }
    
    func createNewCart(item:Item,ownerId:String){//yeni sepet yaratır.
        let newCart = Cart()//
        newCart.id = UUID().uuidString
        newCart.ownerId =  ownerId
        newCart.itemIds = [item.id]
        saveCartToFirestore(newCart)
       
    }
    
    func downloadItemsForCart(_ withIds:[String],completion:@escaping (_ itemArray:[Item])->Void){//Cart içindeki itemleri indirir.bunu item ıd'leri ile  yapar ve bu fonk bize item dizisi döndürür.
        
        var count = 0//indirelecek item sayısını tutar
        var itemArray:[Item] = [Item]()//itemleri tutacka olan array
        
        if withIds.count > 0{
            
            for itemId in withIds{
                FirebaseReference(.Items).document(itemId).getDocument{
                    
                    snapshot,error in
                    
                    guard let snapshot = snapshot else{
                        
                        completion(itemArray)
                        
                        return
                    }
                    
                    if snapshot.exists{
                        
                        itemArray.append(Item(_dictionary: snapshot.data()! as NSDictionary))//item yarat ve diziye ekle
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

}
