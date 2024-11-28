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
    static let uploadInfo = Notification.Name("uploadInfo")
}
class StorageManager{
    
    //MARK: - Firestore Image Upload
    
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
            
            
            storageRef.downloadURL{
                url,error in
                guard let downloadURL = url else{
                    completion(nil)
                    return
                }
                completion(downloadURL.absoluteString)
            }
        }
        
        task.observe(.progress) { snapshot in
            guard let progress = snapshot.progress else { return }
            let totalBytes = progress.totalUnitCount
            let bytesTransferred = progress.completedUnitCount
            let progressValue = Float(bytesTransferred) / Float(totalBytes)
            
            NotificationCenter.default.post(name: .uploadInfo, object: nil,userInfo: ["uploadRemainTime": progressValue])
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
    func uploadProfilePictureImages(images:[UIImage?],userId:String,completion:@escaping (_ imageLinks:[String])->Void){
        
        if Connectivity.isInternetAvailable(){
            var uploadImagesCount = 0
            var imageLinkArray:[String] = []
            var nameSuffix = 0
            
            
            for image in images{
                let fileName = "ProfilePicturesImages/" + userId + "/" + "\(nameSuffix)" + ".jpg"
                
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
        }else{
            
            print("no internet")
        }
        
    }
    
    func deleteProfileImage(imageUrl:String,completion:@escaping(_ error:Error?)->Void){
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

        folderRef.listAll { result, error in
            if let error = error {
                print("Klasör içerikleri alınamadı: \(error.localizedDescription)")
                completion([])
                return
            }
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
