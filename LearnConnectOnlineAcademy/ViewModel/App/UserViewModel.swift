//
//  UserViewModel.swift
//  LearnConnectOnlineAcademy
//
//  Created by Hüdahan Altun on 24.11.2024.
//

import Foundation
import FirebaseAuth

class UserViewModel{
    
//MARK: - Firebase'de oturum açmış kullanıcı yerelde kayıtlı mı değil mi?
    
    
    class func currentId()->String{//oturum açan kullanının kimliğini döndüren fonksiyon
        
        return Auth.auth().currentUser!.uid //mevcut kullanıcının id'si döner.currentUser firebase tarafından yaratılan nesnedir ve oturum açan kullanıcı'yı temsil eder.Bu kullanıcın id'si laızm
    }
    
    class func currentUser()->User?{//logged in olan kullanıcı döndürecek.optional return çünkü logged in olmayan kullanıcı olabilir
        
        if Auth.auth().currentUser != nil{//cihazda kimliği doğrulanmış kullanıcı geldi.Çünkü nil değil
            
            //firebase harici yerelde kayıt içinde tutmamız lazım
            //eğer yerelde kayıtlı ise direkt hesaba giriş yapcaz.değilse userdef nil döndürür.
            if let dictionary = UserDefaults.standard.object(forKey: FirebaseConstants().kEMAIL){
                //yerelde kullanıcı varsa
                return User(_dictionary: dictionary as! NSDictionary)//döndür
            }
        }
        return nil//kimliği doğrulanmış kullanıcı yok veya kullanıcı yerelde kayıtlı değil
    }
    
//MARK: - Login and Register
    
    //firebase'e kayıt olmuş kullanıcı login olmalı.Bu fonksiyon kullanıcı bilg. firebase'e iletir.Compleiton ile firebase den geri dönüş almalıyız çünkü daha önce kayıt olmamış kullanıcı olabilir veya yanlış girmiş olabiliriz veya aksine doğru girmiş olabiliriz.Ayrıca login yapınca bize login yapılan mailin daha önce doğrulanıp doğrulanmadığı bilgisi "isEmailVerified" ile gelir.
    
    class func loginUserWith(email:String,password:String,completion:@escaping(_ error:Error?, _ isEmailVerified:Bool)->Void){
        
        
        Auth.auth().signIn(withEmail: email, password: password){//giriş yap
            
            authResult,error in//authResult herşey yolunda,error ise hatayı tutar
            
            if error == nil{//hata yok
                
                //kayıtlı kullanıcı mevcut
                
                if authResult!.user.isEmailVerified{//kullanıcı maili doğrulandımı?
                
                    completion(error,true)//kayıtlı kullanıcı var ve maili doğrulanmış.nil,true
                    
                }else{
                    
                    print("maili doğrulanmamış kayıtlı  kullanıcı")
                    
                    completion(error,false)//kayıtlı kullanıcı var ama mail doğrulanmadı.nil,false
                }
            }else{//kayıtlı kullanıcı yok
                
                print("kayıtsız kullanıcı")
                completion(error,false)//kayıtlı kullanıcı yok,doğrulanmış mail yok. error,false
            }
            
        }
        
    }
    
    //Daha önceden hesap yaratmamış kullanıcnın mail ve şifre kaydı.Firebase Auth
    
    class func registerUserWith(email:String,password:String,completion:@escaping(_ createUserError:Error?,_ sendVerificationError:Error?)->Void){
        //buarada iki hata firebase'den gelebilir.1-kayıt durumunuda oluşabilecek hata, 2-doğrulama maili yollanırken oluşabilecek hata.
        
        Auth.auth().createUser(withEmail: email, password: password){//Kullanıcıyı auth'a kaydet.
            
            authResult,error in//kayıt bitti ve iki şey döndü
  
            
            if error == nil{//kullanıcı başarıyla kayıt oldu error yok şimdi e mail doğrulaması yolla
                
                //TODO: kullanıcıdan aldığım ad soyad bilgilerini buradan firestore'a yolla.Her halükarda kaydet.
                
                authResult!.user.sendEmailVerification{//doğrulama yollandı
                    
                    error in//doğrulama yollanırken hata olabilir.
                    
                    if error == nil{
                        print("doğrulama maili başarıyla yollandı")
                        completion(error,error)//kayıt başarılı doğrulama maili gönderme başarılı.nil,nil
                    }else{
                        print("doğrulama maili gönderilmesinde hata")
                        completion(error,error)//kayıt başarılı doğrulama maili gönderme başarısız.nil,error
                    }
                }
            }else{
                
                completion(error,error)//kayıt başarısız doğrulama maili gönderme başarısız.error,error
            }
        }
        
    }
    
//MARK: -  Save user or get user from Firestore
    
    class func userDictionaryFrom(_ user:User)->NSDictionary{//dict dönüşüm
        
        return NSDictionary(objects:[
                                     user.email,
                                     user.firstName,
                                     user.lastName,
                                     user.fullName,
                                     user.fullAdress,
                                     user.purchasedItemIds,
                                     user.onBoard,
                                     user.turkishCitizenshipId,
                                     user.phoneNumber,
                                     user.dateOfBirth,
                                     user.profilePicture],
                            forKeys:[
                                     FirebaseConstants().kEMAIL as NSCopying,
                                     FirebaseConstants().kFIRSTNAME as NSCopying,
                                     FirebaseConstants().kLASTNAME as NSCopying,
                                     FirebaseConstants().kFULLNAME as NSCopying,
                                     FirebaseConstants().kFULLADRESS as NSCopying,
                                     FirebaseConstants().kPURCHASEDITEMIDS as NSCopying,
                                     FirebaseConstants().kONBOARD as NSCopying,
                                     FirebaseConstants().kCITIZIEN as NSCopying,
                                     FirebaseConstants().kPHONE as NSCopying,
                                     FirebaseConstants().kDATEOFBIRTH as NSCopying,
                                     FirebaseConstants().kIMAGENAME as NSCopying])
    }
    
    class func saveUserToFirestore(user:User){//firestore'a kullanıcı nesnesi kayıt edilir.AccountInfoVC'de mail ile kayıt yaparken o kullanıcı nesnesinide kayıt edecek.Kullanıcı nesnesi primaryKey'i mail oalacak şekilde kayıt edilir.
        
        FirebaseReference(.User).document(user.email!).setData(userDictionaryFrom(user) as! [String:Any]){
            
            error in
            
            if error != nil{
                print("kullanıcı firestore kayıt hatası var")
            }
        }
    }
    
    
    
    
    class func saveUserOnPhone(user:NSDictionary){//WelcomeVC'de kullancıı giriş yapınca çalışacak ve auth ile başarıyla giriş yapan kişinin bilgileri yerele kaydedilecek.
        
        UserDefaults.standard.set(user, forKey: FirebaseConstants().kEMAIL)//kullanıcıyı yerele kEMAİL ile kaydet
        UserDefaults.standard.synchronize()
    }
    
    //Kullanıcı welcomeVC'den giriş yağınca giriş başarılı olursa  kullanıcı bilgileri firestore'dan indirilir.
    class func downloadUserFromFirestore(email:String){//kullanıcı welcomeVC'den giriş yapıyor
        //mail sorgulanıyor
        
        FirebaseReference(.User).document(email).getDocument{//email ile sorgulama yapılıyor.
            snapshot,error in
            
            guard let snapshot = snapshot else{
                //snapshot hatası
                return
            }
            
            if snapshot.exists{
                
                //önceden hesap açmış kullancıı var bunu yerele kaydet ve kullanıcı bilgilerini getir.Tekrar tekrar girişi önle
                self.saveUserOnPhone(user: snapshot.data()! as NSDictionary)
                
            }else{
                print("geçerli kullanıcı yok")
            }
            
        }
    }
    
//MARK: - Reset Account Password
    
    class func resetPassword(email:String,completion:@escaping(_ error:Error?)->Void){
        //tabi bu fonkisyon kayıtlı kullanıcı için çalışmalı .
        
        Auth.auth().sendPasswordReset(withEmail: email){//şifre sıfırlama  epostasını yolla
            error in

            if error == nil{//yollama başarılı

                completion(error)//yani nil
            }else{
                completion(error)//yollama başarısız.
            }
        }
 

    }
    
// MARK: - Logout
    
    class func logoutUserWith(completion:@escaping (_ error:Error?)->Void){
        
        do{
            try Auth.auth().signOut()
            
            //userdafuls alanından kEMAIL ile işaretli nesneyi sil
            UserDefaults.standard.removeObject(forKey: FirebaseConstants().kEMAIL)
            UserDefaults.standard.synchronize()
            
            completion(nil)//çıkış başarılı hata yok
        }catch let error as NSError{
            
            completion(error)//çıkış yapılamadı.
        }
        
    }

   
//MARK: - Update User
    
    //hem userdafults'u hemde firestore güncellenmeli.Çünkü login yapınca user tablosu userdefaults'a kayıt ediliyor.
    //sadece firestore da güncelleme yapınca eğet terkar giriş yaptırmazsak yeni güncellenene veriler uyg içinde gözükmez.
    class func updateUser(withValues:[String:Any],completion:@escaping(_ error:Error?)->Void){
        
        if let dict = UserDefaults.standard.object(forKey: FirebaseConstants().kEMAIL){
            
            let userObject = (dict as! NSDictionary).mutableCopy() as! NSMutableDictionary//mutable kopyasını alıyoruz.orj veri üzerinde işlem yapmaktan kaçınıyoruz.
            
            userObject.setValuesForKeys(withValues)//değiştiriyoruz.
            
            FirebaseReference(.User).document(UserViewModel.currentUser()!.email!).updateData(withValues){//değişimleri firestore'da da yapıyoruz.
                error in
        
                
                if error == nil{//güncelleme başarılı nil
                 
                    completion(error)
                    
                    saveUserOnPhone(user: userObject)//yerele yenisini kaydet.üzerine kaydedeilir.
                }else{
                    completion(error)//hata var.
                }
            }
        }
    }
    
    
    func downloadUserFromFirestore(userMail:String,completion:@escaping(_ name:User)->Void){
        
        FirebaseReference(.User).document(userMail).getDocument{//email ile sorgulama yapılıyor.
            snapshot,error in
            
            guard let snapshot = snapshot else{
                //snapshot hatası
                return
            }
            
            if snapshot.exists{
                
                completion(User(_dictionary: snapshot.data()! as NSDictionary))
                
            }else{
                print("geçerli kullanıcı yok")
            }
            
        }
    }
    
}
