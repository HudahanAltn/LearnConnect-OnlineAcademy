//
//  LikedViewModel.swift
//  LearnConnectOnlineAcademy
//
//  Created by Hüdahan Altun on 25.11.2024.
//

import Foundation
import UIKit

class LikedViewModel{
    
    func saveLikedToFirestore(_ liked :Liked){
        FirebaseReference(.Liked).document(liked.id).setData(likedDictionaryFrom(liked) as! [String:Any] )
    }
    
    func likedDictionaryFrom(_ liked:Liked)->NSDictionary{
        
        return NSDictionary(objects:[liked.id,liked.ownerId,liked.itemIds],forKeys: [FirebaseConstants().kOBJECTID as NSCopying,
                                                                                     FirebaseConstants().kOWNERID as NSCopying,
                                                                                     FirebaseConstants().kITEMIDS as NSCopying])
    }
    
    func downloadLikedFromFirestore(_ ownerId:String,completion:@escaping(_ liked :Liked?)->Void){
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
    
    func updateLikedInFirestore(_ liked:Liked, withValues:[String:Any],completion:@escaping(_ error:Error?)->Void){
        FirebaseReference(.Liked).document(liked.id).updateData(withValues){
            error in
            completion(error)
        }
    }
    
    func createNewLiked(item:Item,ownerId:String){
        let newLiked = Liked()//
        newLiked.id = UUID().uuidString
        newLiked.ownerId =  ownerId
        newLiked.itemIds = [item.id]
        saveLikedToFirestore(newLiked)
        
    }
    
    func downloadItemsForLiked(_ withIds:[String],completion:@escaping (_ itemArray:[Item])->Void){
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

    func checkIsItemLikedBefore(_ ownerId:String,item:Item,completion:@escaping(_ isLikedBefore :Bool,_ error:Error?)->Void){

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
