//
//  StorageManager.swift
//  LearnConnectOnlineAcademy
//
//  Created by Hüdahan Altun on 22.11.2024.
//

import Foundation
import FirebaseStorage
import UIKit

let storage = Storage.storage()


extension Notification.Name{
    static let downloadInfo = Notification.Name("downloadInfo")
}
class StorageManager{
    
    //MARK: - Firestore Image Upload
    
    //firebase e resim kayıt temel fonkisonudur.her kayıt gerçekleşince bize bu fonksiyon tek bir resim için tek bir link verecek.bu linki daha sonra resim download etmede kullanacaz.
    func saveImageInFirebase(imageData:Data,fileName:String,completion:@escaping(_ imageLink:String?)->Void){
        
        var task:StorageUploadTask!
        let storageRef = storage.reference(forURL:FirebaseConstants().kFILEREFERENCE).child(fileName)
        
        task = storageRef.putData(imageData,metadata: nil){
            metadata,error in
            
            task.removeAllObservers()
            
            if error != nil{//hata var
                print("error uploading image",error!.localizedDescription)
                completion(nil)
                return
            }
            // hata yok
            storageRef.downloadURL{
                url,error in
                guard let downloadURL = url else{
                    completion(nil)
                    return
                }
                completion(downloadURL.absoluteString)
            }
        }
    }
    
    //AddItemVC sayfasında kullanıcı ürün fotoğrafını firestorage'e yükler.Completion ile resimlere aid dosya yolu linkleri alır.
    func uploadImages(images:[UIImage?],itemId:String,completion:@escaping (_ imageLinks:[String])->Void){
        
        var uploadImagesCount = 0
        var imageLinkArray:[String] = [String]()
        var nameSuffix = 0
        
        
        for image in images{
            let fileName = "ItemImages/" + itemId + "/" + "\(nameSuffix)" + ".jpg"
            let imageData = image!.jpegData(compressionQuality: 0.5)
            saveImageInFirebase(imageData: imageData!, fileName: fileName){
                imageLink in
                
                if imageLink != nil{
                    imageLinkArray.append(imageLink!)
                    uploadImagesCount += 1
                    if uploadImagesCount == images.count{
                        completion(imageLinkArray)
                    }
                }
            }
            nameSuffix += 1
        }
        
    }
    
    
    //MARK: - Firestore Video Upload
    func saveVideoInFirebase(videoData:Data,fileName:String,completion:@escaping(_ videoLink:String?)->Void){
        
        var task:StorageUploadTask!
        let storageRef = storage.reference(forURL:FirebaseConstants().kFILEREFERENCE).child(fileName)
        
        task = storageRef.putData(videoData,metadata: nil){
            metadata,error in
            
            task.removeAllObservers()
            if error != nil{//hata var
                print("error uploading video",error!.localizedDescription)
                completion(nil)
                return
            }
            print("video uploaded successfully")
            storageRef.downloadURL{
                url,error in
                guard let downloadURL = url else{
                    completion(nil)
                    return
                }
                completion(downloadURL.absoluteString)
            }
        }
    }
    
    func uploadVideos(videoURLs:[URL],itemId:String, completion:@escaping (_ videoLinks:[String])->Void){
        
        var uploadVideosCount = 0
        var videoLinkArray:[String] = [String]()
        var nameSuffix = 0
        
        for videoURL in videoURLs{
            let fileName = "ItemVideos/" + itemId + "/" + "\(nameSuffix)" + videoURL.lastPathComponent
            guard let videoData = try? Data(contentsOf: videoURL) else {
                print(" Video is not founded")
                return
            }
            
            saveVideoInFirebase(videoData: videoData, fileName: fileName){
                videoLink in
                
                if videoLink != nil{
                    videoLinkArray.append(videoLink!)
                    uploadVideosCount += 1
                    if uploadVideosCount == videoURLs.count{
                        completion(videoLinkArray)
                    }
                }
            }
            nameSuffix += 1
        }
    }
    
    //MARK: - Firebase User Profile
    
    //Kullanıcının profil fotoğrafını storage'e yüklemesi için oluşturulan fonksiyon.
    func uploadProfilePictureImages(images:[UIImage?],userId:String,completion:@escaping (_ imageLinks:[String])->Void){
        
        if Connectivity.isInternetAvailable(){//internet varsa yükleme yap
            
            //kaç image yğkleyeceğimiz bilmiyoruz ve completion ı ne zaman çağoıracağmızı bilmioz
            
            var uploadImagesCount = 0 // yüklenen resim sayısı
            var imageLinkArray:[String] = [] //  image linkleri tutacak dizi
            var nameSuffix = 0//  firebase e yüklenen resimlerin adları yok zaten 3 resim yüklicez bu değişken ile ad setlemesi yapcaz
            
            
            for image in images{// kullanıcın seçtiği resimleri tek tek aldık
                
                //dinamik dosya yolu
                let fileName = "ProfilePicturesImages/" + userId + "/" + "\(nameSuffix)" + ".jpg"
                
                //0.5 çözünürlük kaybı ile yükledik
                
                let imageData = image!.jpegData(compressionQuality: 0.5)
                
                // resmi temel fonksiyona geçtik
                saveImageInFirebase(imageData: imageData!, fileName: fileName){
                    imageLink in
                    
                    if imageLink != nil{
                        imageLinkArray.append(imageLink!)
                        uploadImagesCount += 1
                        if uploadImagesCount == images.count{
                            
                            completion(imageLinkArray) // artık kaç tane resim eklediysek eklenen resimlerin linkleri bize completion ile dizi şeklinde dönecek
                        }
                    }
                    
                }
                nameSuffix += 1
            }
        }else{
            
            print("no internet")
        }
        
    }
    
    func deleteProfileImage(imageUrl:String,completion:@escaping(_ error:Error?)->Void){// profilini kullanıcı düzenlerken yeni fotoğraf eklemek isterse önceki storage'den silinmelidir.
        let storageRef = storage.reference()
        let imageRef = storageRef.child(imageUrl)
        imageRef.delete { error in
            if let error = error {
                completion(error)//silme başarısız
            } else {
                completion(error)//silme başarılı
            }
        }
    }
    
    //MARK: - Firestore Image Download
    
    func downloadImage(imageUrl: String, completion: @escaping (_ image:UIImage?) -> Void) {
        
        guard let url = URL(string: imageUrl) else {
            print("Invalid URL")
            return
        }
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Error: \(error)")
                completion(nil)
                return
            }
            
            if let data = data, let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    completion(image)
                }
            } else {
                DispatchQueue.main.async {
                    completion(nil)
                }
            }
        }.resume()
    }
    //MARK: - Firestore download videos

    func fetchVideoNames(itemId: String, completion: @escaping ([String]) -> Void) {
        
        let folderPath = "ItemVideos/" + itemId + "/"
        let folderRef = Storage.storage().reference().child(folderPath)
        
        // listAll() ile klasör içeriğini al
        folderRef.listAll { result, error in
            if let error = error {
                print("Klasör içerikleri alınamadı: \(error.localizedDescription)")
                completion([])
                return
            }
            
            // Dosya isimlerini al
            let videoNames = result!.items.map { $0.name }
            completion(videoNames)
        }
    }
    
    func downloadAndSaveVideo(videoURL: String, fileName: String, completion: @escaping (URL?) -> Void) {
        let storageRef = Storage.storage().reference(forURL: videoURL)
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(fileName + ".mov")
        
        let downloadTask = storageRef.write(toFile: tempURL) { url, error in
            if let error = error {
                print("Video indirme hatası:")
                completion(nil)
                return
            }
         
            if let savedURL = self.saveVideoToDocuments(tempURL: tempURL, fileName: fileName) {
                completion(savedURL)
            } else {
                completion(nil)
            }
        }
        
        downloadTask.observe(.progress) { snapshot in
            guard let progress = snapshot.progress else { return }
            let totalBytes = progress.totalUnitCount
            let bytesTransferred = progress.completedUnitCount
            let progressValue = Float(bytesTransferred) / Float(totalBytes)
            
            NotificationCenter.default.post(name: .downloadInfo, object: nil,userInfo: ["remainTime": progressValue])
        }
        
    }
    
    func saveVideoToDocuments(tempURL: URL, fileName: String) -> URL? {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let destinationURL = documentsDirectory.appendingPathComponent(fileName + ".mov")
        
        do {
            if FileManager.default.fileExists(atPath: destinationURL.path) {
                try FileManager.default.removeItem(at: destinationURL)
            }
            
            try FileManager.default.moveItem(at: tempURL, to: destinationURL)
            print("Video başarıyla kaydedildi: \(destinationURL)")
            return destinationURL
        } catch {
            print("Video kaydetme hatası: \(error.localizedDescription)")
            return nil
        }
    }
    
}
