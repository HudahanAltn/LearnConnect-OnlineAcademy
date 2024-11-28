//
//  ReviewViewModel.swift
//  LearnConnectOnlineAcademy
//
//  Created by Hüdahan Altun on 26.11.2024.
//

import Foundation


class ReviewViewModel {
    
    @Published var reviews:[Review] = [Review]()
    
    func saveReviewToFirestore(_ review:Review){
        FirebaseReference(.Review).document(review.id).setData(reviewDictionaryFrom(review) as! [String:Any])
    }
    
    func reviewDictionaryFrom(_ review:Review)->NSDictionary{
        return NSDictionary(objects: [review.id,
                                      review.ownerId,
                                      review.itemID,
                                      review.comment,
                                      review.point],
                            forKeys: [FirebaseConstants().kOBJECTID as NSCopying,
                                      FirebaseConstants().kEMAIL as NSCopying,
                                      FirebaseConstants().kITEMID as NSCopying,
                                      FirebaseConstants().kCOMMENT as NSCopying,
                                      FirebaseConstants().kPOINT as NSCopying])
    }
    
    func downloadReviewsFromFirebase(itemID:String){
        self.reviews.removeAll()
        FirebaseReference(.Review).whereField(FirebaseConstants().kITEMID, isEqualTo: itemID).getDocuments{
            snapshot,error in
            guard let snapshot = snapshot else{
                return
            }
            if !snapshot.isEmpty{
                for reviewDict in snapshot.documents{
                    self.reviews.append(Review(_dictionary: reviewDict.data() as NSDictionary))
                }
            }
        }
    }
    
    func downloadReviewsFromFirebase(itemID:String,completion:@escaping(_ review:[Review])->Void){
        var reviews:[Review] = [Review]()
        FirebaseReference(.Review).whereField(FirebaseConstants().kITEMID, isEqualTo: itemID).getDocuments{
            snapshot,error in
            guard let snapshot = snapshot else{
                completion([])
                return
            }
            if !snapshot.isEmpty{
                for reviewDict in snapshot.documents{
                    reviews.append(Review(_dictionary: reviewDict.data() as NSDictionary))
                }
                completion(reviews)
            }else{
                completion([])
            }
        }
    }
}
