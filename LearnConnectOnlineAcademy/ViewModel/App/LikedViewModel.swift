//
//  LikedViewModel.swift
//  LearnConnectOnlineAcademy
//
//  Created by Hüdahan Altun on 25.11.2024.
//

import Foundation
import UIKit

class LikedViewModel{
    
    func saveLikedToFirestore(_ liked :Liked){// yaratılan liked'ı firebase'e ekle
        FirebaseReference(.Liked).document(liked.id).setData(likedDictionaryFrom(liked) as! [String:Any] )
    }

    func likedDictionaryFrom(_ liked:Liked)->NSDictionary{//dict dönüşümü yapan fonksiyon
     
        return NSDictionary(objects:[liked.id,liked.ownerId,liked.itemIds],forKeys: [FirebaseConstants().kOBJECTID as NSCopying,
            FirebaseConstants().kOWNERID as NSCopying,
            FirebaseConstants().kITEMIDS as NSCopying])
    }
    
    //liked ownerID'ye göre getir.Varsa bi sepet getirir yoksa getirmez zaten yoksa yaratacağız varsa güncelliceğiz.
    func downloadLikedFromFirestore(_ ownerId:String,completion:@escaping(_ liked :Liked?)->Void){
        //owner id kullanıcın email adresi olacak.
        FirebaseReference(.Liked).whereField(FirebaseConstants().kOWNERID,isEqualTo: ownerId).getDocuments{
            snapshot,error in
            
            guard let snapshot = snapshot else{
                
                completion(nil)//sepet yok
                return
            }
            
            if !snapshot.isEmpty && snapshot.documents.count>0{//sepet var
                let liked = Liked(_dictionary: snapshot.documents.first!.data() as NSDictionary)
                completion(liked) //sepeti döndür
                
            }else{
                completion(nil)//sepet yok
            }
            
        }
    }
    
    //var olan liked güncellenir.
    func updateLikedInFirestore(_ liked:Liked, withValues:[String:Any],completion:@escaping(_ error:Error?)->Void){
        
        //cart id si bilinen liked güncelle
        FirebaseReference(.Liked).document(liked.id).updateData(withValues){
            error in
            
            completion(error)
        }
    }

    func createNewLiked(item:Item,ownerId:String){//yeni liked yaratır.
        let newLiked = Liked()//
        newLiked.id = UUID().uuidString
        newLiked.ownerId =  ownerId
        newLiked.itemIds = [item.id]
        saveLikedToFirestore(newLiked)
       
    }

    func downloadItemsForLiked(_ withIds:[String],completion:@escaping (_ itemArray:[Item])->Void){//liked içindeki itemleri indirir.bunu item ıd'leri ile  yapar ve bu fonk bize item dizisi döndürür.
        
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
    
    //liked ownerID'ye göre getir.Varsa bi liked getirir yoksa getirmez zaten yoksa yaratacağız varsa güncelliceğiz.
    func checkIsItemLikedBefore(_ ownerId:String,item:Item,completion:@escaping(_ isLikedBefore :Bool,_ error:Error?)->Void){
        //owner id kullanıcın email adresi olacak.
        
        FirebaseReference(.Liked).whereField(FirebaseConstants().kOWNERID,isEqualTo: ownerId).getDocuments{
            snapshot,error in
            
            guard let snapshot = snapshot else{
                
                completion(false,error)//sepet yok
                return
            }
            
            if !snapshot.isEmpty && snapshot.documents.count>0{//sepet var
                let liked = Liked(_dictionary: snapshot.documents.first!.data() as NSDictionary)
                
                if liked.itemIds.contains(item.id){
                    completion(true,nil)
                }else{
                    completion(false,nil)
                }
            }else{
                completion(false,error)//sepet yok
            }
            
        }
    }
  
}
