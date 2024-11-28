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
    
    @IBOutlet weak var addReviewBarButton: UIBarButtonItem!
    @IBOutlet weak var downloadProgressView: UIProgressView!
    @IBOutlet weak var courseListTableView: UITableView!
    
    var course:Item?
    var courseVideoList:[String] = [String]()
    
    private var videoPlayer:AVPlayer? = nil
    private var videoPlayerLayer:AVPlayerLayer? = nil
    
    private var timeObserver : Any? = nil
    private var isThumbSeek : Bool = false
    
    let context = appDelegate.persistentContainer.viewContext
    var downloadedVideoList:[Video] = [Video]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        courseListTableView.delegate = self
        courseListTableView.dataSource = self
        courseListTableView.emptyDataSetSource = self
        courseListTableView.emptyDataSetDelegate = self
        setupUI()
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
            self.navigationItem.title = ""
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
        
        let fetchRequest:NSFetchRequest<Video> = Video.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "videoName == %@", extractString(from: courseVideoList[indexPath.row])!)
        var videoList:[Video] = [Video]()
        
        do{
            videoList = try context.fetch(fetchRequest)
        }catch{
            
        }
        if videoList.count>0{//video kayıt edilmiş
            let player = AVPlayer(url: URL(string: videoList.first!.savedVideoURL!)!)
            if let lastTime = getVideoTime(courseid: course!.id!,index: indexPath.row) {
                player.seek(to: lastTime, toleranceBefore: .zero, toleranceAfter: .zero)
            }
            let avplayerVC = AVPlayerViewController()
            avplayerVC.player = player
            
            self.present(avplayerVC, animated: true){
                player.play()
            }
            
            player.addPeriodicTimeObserver(forInterval: CMTime(seconds: 1, preferredTimescale: 1), queue: .main) { [weak self] currentTime in
                self?.saveVideoTime(courseid:(self?.course!.id!)!,index: indexPath.row, time: currentTime)
            }
        }else{//internetten indirilecek
            if Connectivity.isInternetAvailable(){
                let player = AVPlayer(url: URL(string: courseVideoList[indexPath.row])!)
                if let lastTime = getVideoTime(courseid: course!.id!,index: indexPath.row) {
                    player.seek(to: lastTime, toleranceBefore: .zero, toleranceAfter: .zero)
                }
                let avplayerVC = AVPlayerViewController()
                avplayerVC.player = player
                
                self.present(avplayerVC, animated: true){
                    player.play()
                }
                
                player.addPeriodicTimeObserver(forInterval: CMTime(seconds: 1, preferredTimescale: 1), queue: .main) { [weak self] currentTime in
                    self?.saveVideoTime(courseid:(self?.course!.id!)!,index: indexPath.row, time: currentTime)                        }
            }else{
                Alert.createAlert(title: Alert.noConnectionTitle, message: Alert.noConnectionMessage, view: self)
            }
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
            if Connectivity.isInternetAvailable(){
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
                configuraiton.performsFirstActionWithFullSwipe = false
                return configuraiton
            }else{
                return nil
                Alert.createAlert(title: Alert.noConnectionTitle, message: Alert.noConnectionMessage, view: self)
            }
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
        cell.courseVideoNameLabel.text = "\(extractString(from: courseVideoList[indexPath.row])!)"
        
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
    
    @objc func turnBackToPage(){
        self.navigationController?.popViewController(animated: true)
    }
}
//MARK: - Helper
extension CourseDetailsViewController {
    
    func setupUI(){
        courseListTableView.separatorStyle = .none
        self.navigationItem.title = "\(course!.name!)"
        courseVideoList = (course?.videoLinks)!.sorted()
        downloadProgressView.alpha = 0.0
        downloadProgressView.setProgress(0.0, animated: true)
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "chevron.backward"), style: .plain, target: self, action: #selector(self.turnBackToPage))
    }
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
    
    func fetchVideo(){
        
        do{
            downloadedVideoList = try context.fetch(Video.fetchRequest())
        }catch{
            print("getirme hatası!")
        }
    }
    
    func saveVideoTime(courseid:String,index:Int,time:CMTime?){
        if let time = time{
            UserDefaults.standard.set(time.seconds, forKey: "\(courseid)\(index)")
            
        }else{
            UserDefaults.standard.set(0.0, forKey: "\(courseid)\(index)")
        }
    }
    
    func getVideoTime(courseid:String,index:Int)->CMTime?{
        let seconds =  UserDefaults.standard.double(forKey: "\(courseid)\(index)")
        return seconds > 0 ? CMTime(seconds: seconds, preferredTimescale: 1) : nil
    }
    
}
//MARK: - EmptyDataSet
extension CourseDetailsViewController:EmptyDataSetSource,EmptyDataSetDelegate{
    
    
    func description(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
        if UserViewModel.currentUser() != nil{
            if Connectivity.isInternetAvailable(){
                return NSAttributedString(string: "Güncel kurslara erişin.")
            }else{
                return NSAttributedString(string: "")
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
