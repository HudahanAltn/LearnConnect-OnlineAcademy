//
//  CourseDetailsViewController.swift
//  LearnConnectOnlineAcademy
//
//  Created by Hüdahan Altun on 25.11.2024.
//

import UIKit
import AVFoundation
import AVKit
import CoreData
import EmptyDataSet_Swift
let appDelegate = UIApplication.shared.delegate as! AppDelegate

class CourseDetailsViewController: UIViewController {

    let lastPlaybackTimeKey = "LastPlaybackTime" // UserDefaults anahtarı
    
        var lastPlaybackTime: CMTime? {
            get {
                // Saklanan zamanı UserDefaults'tan al ve CMTime'a dönüştür.
                let seconds = UserDefaults.standard.double(forKey: lastPlaybackTimeKey)
                return seconds > 0 ? CMTime(seconds: seconds, preferredTimescale: 1) : nil
            }
            set {
                // CMTime'ı UserDefaults'ta sakla.
                if let newValue = newValue {
                    UserDefaults.standard.set(newValue.seconds, forKey: lastPlaybackTimeKey)
                } else {
                    UserDefaults.standard.removeObject(forKey: lastPlaybackTimeKey)
                }
            }
        }
    @IBOutlet weak var addReviewBarButton: UIBarButtonItem!
    @IBOutlet weak var downloadProgressView: UIProgressView!
    @IBOutlet weak var courseVideoNameLabel: UILabel!
    @IBOutlet weak var courseListTableView: UITableView!
    
    var course:Item?
    var courseVideoList:[String] = [String]()
    
    private var videoPlayer:AVPlayer? = nil
    private var videoPlayerLayer:AVPlayerLayer? = nil
    
    private var timeObserver : Any? = nil
    private var isThumbSeek : Bool = false
    

    let context = appDelegate.persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        courseListTableView.delegate = self
        courseListTableView.dataSource = self
        courseListTableView.emptyDataSetSource = self
        courseListTableView.emptyDataSetDelegate = self
        courseListTableView.separatorStyle = .none
        courseVideoNameLabel.text = "\(course!.name!)"
        courseVideoList = (course?.videoLinks)!
        downloadProgressView.alpha = 0.0
        downloadProgressView.setProgress(0.0, animated: true)
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "chevron.backward"), style: .plain, target: self, action: #selector(self.turnBackToPage))
        videoPlayer?.addObserver(self, forKeyPath: "timeControlStatus", options: [.new, .initial], context: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.videoRemaining(notification:)), name:.downloadInfo, object: nil)
      
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "courseDetailsToReview"{
            let vc = segue.destination as! ReviewViewController
            vc.course = course
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if UserViewModel.currentUser() == nil{
            self.navigationItem.title = "Learn Connect"
            addReviewBarButton.isHidden = true
            courseVideoNameLabel.text = ""
            courseVideoList.removeAll()
            courseListTableView.reloadData()
        }else{
            addReviewBarButton.isHidden = false
            if Connectivity.isInternetAvailable(){
                courseListTableView.reloadData()
            }else{
                courseVideoList.removeAll()
                courseListTableView.reloadData()
                Alert.createAlert(title: Alert.noConnectionTitle, message: Alert.noConnectionMessage, view: self)
            }
        }
        
    }
    
    @IBAction func addCommentButtonPressed(_ sender: Any) {
        if Connectivity.isInternetAvailable(){
            performSegue(withIdentifier: "courseDetailsToReview", sender: course)
        }else{
            Alert.createAlert(title: Alert.noConnectionTitle, message: Alert.noConnectionMessage, view: self)
        }
    }
    

}

//MARK: - UITableviewDelegate
extension CourseDetailsViewController:UITableViewDelegate{
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return DeviceHelper.getSafeAreaSize()!.height/10
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        tableView.deselectRow(at: indexPath, animated: true)
            
        let player = AVPlayer(url: URL(string: courseVideoList[indexPath.row])!)
        if let lastTime = lastPlaybackTime {
                    player.seek(to: lastTime, toleranceBefore: .zero, toleranceAfter: .zero)
                }
        let avplayerVC = AVPlayerViewController()
        avplayerVC.player = player

        self.present(avplayerVC, animated: true){
            player.play()
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(playerDidFinishPlaying), name: .AVPlayerItemDidPlayToEndTime, object: player.currentItem)

                player.addPeriodicTimeObserver(forInterval: CMTime(seconds: 1, preferredTimescale: 1), queue: .main) { [weak self] currentTime in
                    self?.lastPlaybackTime = currentTime // Her bir saniyede oynatma zamanını güncelle.
                }
    }
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
      
        let fetchRequest:NSFetchRequest<Video> = Video.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "videoName == %@", extractString(from: courseVideoList[indexPath.row])!)
        var videoList:[Video] = [Video]()
        
        do{
            videoList = try context.fetch(fetchRequest)
        }catch{
            
        }
        if videoList.count > 0{
            return nil
        }else{
            let download = UIContextualAction(style: .normal, title: ""){
                (action, view, completionHandler) in
                tableView.setEditing(false, animated: true)
                completionHandler(true)
                StorageManager().downloadAndSaveVideo(videoURL: self.courseVideoList[indexPath.row] , fileName:self.extractString(from: self.courseVideoList[indexPath.row])! ) { savedURL in
                      
                      if let savedURL = savedURL {
                          let video = Video(context: self.context)
                          video.videoName = self.extractString(from: self.courseVideoList[indexPath.row])!
                          video.savedVideoURL = savedURL.absoluteString
                          appDelegate.saveContext()
                          tableView.reloadData()
                          Alert.createAlert(title: "Başarılı", message: "\(self.extractString(from: self.courseVideoList[indexPath.row])!) indirildi", view: self)
                      }else {
                          Alert.createAlert(title: "Hata", message: "Video indirme başarısız oldu!", view: self)

                      }
                  }
            }
            download.backgroundColor = .systemGreen 
            download.image = UIImage(systemName: "arrow.down.circle.fill")
            var configuraiton = UISwipeActionsConfiguration(actions: [download])
            configuraiton.performsFirstActionWithFullSwipe = false // Full swipe'da da aksiyon yapılmasını istemiyorsanız
            return configuraiton
        }
        
    }
   
}
//MARK: - UITableViewDataSource
extension CourseDetailsViewController: UITableViewDataSource{
    
    
       func numberOfSections(in tableView: UITableView) -> Int {
           return 1
       }
       func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
           return courseVideoList.count
       }
       
       func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
           
           let cell = tableView.dequeueReusableCell(withIdentifier:"videoCell",for:indexPath) as! CourseDetailsTableViewCell
           cell.courseVideoNameLabel.text = "1)\(extractString(from: courseVideoList[indexPath.row])!)"
           
           let fetchRequest:NSFetchRequest<Video> = Video.fetchRequest()
           fetchRequest.predicate = NSPredicate(format: "videoName == %@", extractString(from: courseVideoList[indexPath.row])!)
           var videoList:[Video] = [Video]()
           do{
               videoList = try context.fetch(fetchRequest)
           }catch{
               print("hata")
           }
           if videoList.count > 0{
               cell.videoDownloadImageView.image = UIImage(systemName: "externaldrive.badge.checkmark")
           }else{
               cell.videoDownloadImageView.image = nil
           }
           return cell
       }
       
}
//MARK: - Objc Functions
extension CourseDetailsViewController{
    
    @objc func videoRemaining(notification:Notification){
        if let newData = notification.userInfo?["remainTime"] as? Float {
            downloadProgressView.alpha = 1.0
            downloadProgressView.setProgress(newData, animated:true)
            print("courseDetailVC içi kalan süre: \(newData)")
            if newData == 1.0{
                downloadProgressView.alpha = 0.0
                downloadProgressView.setProgress(0.0,animated: true)
            }
        }else{
            print("hata")
        }
        
        
        
    }
    
    @objc func playerDidFinishPlaying(notification: Notification) {
           lastPlaybackTime = nil // Video sona erdiğinde oynatma zamanını sıfırla.
    }
    
    @objc func turnBackToPage(){
        self.navigationController?.popViewController(animated: true)
    }
}

extension CourseDetailsViewController {
    
    func extractString(from urlString: String) -> String? {
        // URL'yi çözümle
        guard let url = URLComponents(string: urlString) else {
            print("Geçersiz URL")
            return nil
        }
        
        // Path kısmını al
        guard let path = url.path.removingPercentEncoding else {
            print("Path alınamadı")
            return nil
        }
        
        // `%2F` ile `.` arasındaki kısmı çıkar
        if let startRange = path.range(of: "/ItemVideos/"),
           let endRange = path.range(of: ".", range: startRange.upperBound..<path.endIndex) {
            let extractedString = String(path[startRange.upperBound..<endRange.lowerBound])
            if let slashRange = extractedString.range(of: "/") {
                    let result2 = String(extractedString[slashRange.upperBound...])
                    return result2
                }
            return nil
        }
        
        print("İlgili aralık bulunamadı")
        return nil
    }
    
    func getSavedVideoURL(fileName: String) -> URL? {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileURL = documentsDirectory.appendingPathComponent(fileName)

        if FileManager.default.fileExists(atPath: fileURL.path) {
            return fileURL
        } else {
            print("Dosya mevcut değil.")
            return nil
        }
    }
    
    func deleteVideo(fileName: String) -> Bool {
        let fileManager = FileManager.default
        let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileURL = documentsDirectory.appendingPathComponent(fileName)

        do {
            if fileManager.fileExists(atPath: fileURL.path) {
                try fileManager.removeItem(at: fileURL)
                print("Video başarıyla silindi: \(fileURL)")
                return true
            } else {
                print("Dosya mevcut değil: \(fileURL)")
                return false
            }
        } catch {
            print("Video silme hatası: \(error.localizedDescription)")
            return false
        }
    }
}



extension CourseDetailsViewController:EmptyDataSetSource,EmptyDataSetDelegate{
    
   
    func description(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
        if UserViewModel.currentUser() != nil{
            if Connectivity.isInternetAvailable(){
                return NSAttributedString(string: "Güncel kurslara erişin.")
            }else{
                return NSAttributedString(string: "Kursları görüntülemek için internet bağlantısı gerekmektedir!")
            }
        }else{
            if Connectivity.isInternetAvailable(){
                return NSAttributedString(string: "Kursları görüntülemek için giriş yapılmalıdır!")
            }else{
                return NSAttributedString(string: "")
            }
        }
        
        
    }
    func title(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
        
        if Connectivity.isInternetAvailable(){
            return NSAttributedString(string: "Satın alınan kurs bulunamadı!")
        }else{
            return NSAttributedString(string: "Kursları görüntülemek için internet bağlantısı gereklidir!")
        }
    }
    
    func image(forEmptyDataSet scrollView: UIScrollView) -> UIImage? {
        
        if Connectivity.isInternetAvailable(){
            return UIImage(named: "history")
        }else{
            return UIImage(named: "noWifi")
        }
        
    }
  
}
