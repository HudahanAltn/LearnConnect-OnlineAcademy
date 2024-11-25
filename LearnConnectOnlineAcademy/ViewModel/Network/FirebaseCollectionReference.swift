//
//  FirebaseCollectionReference.swift
//  LearnConnectOnlineAcademy
//
//  Created by Hüdahan Altun on 21.11.2024.
//

import Foundation
import FirebaseFirestore


enum FCollectionReference:String{//Firebase'de verilerimiz farklı tablolarda saklanacak.Bunlar tablolardır.
    case Category
    case SubCategory
    case User
    case Items
    case Cart
    case Liked
}

func FirebaseReference(_ collectionReference:FCollectionReference)->CollectionReference{//Tablo referanslarına erişim için yazılan fonksiyon.
    return Firestore.firestore().collection(collectionReference.rawValue)
}
