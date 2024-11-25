//
//  CourseDetailsViewController.swift
//  LearnConnectOnlineAcademy
//
//  Created by Hüdahan Altun on 25.11.2024.
//

import UIKit
import AVFoundation
import AVKit


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
    
    
    @IBOutlet weak var mainVideoPlayerView: UIView!
    @IBOutlet weak var mainVidePlayerViewHeight: NSLayoutConstraint!
    @IBOutlet weak var videoPlayerView: UIView!
    @IBOutlet weak var playerButtonsStackView: UIStackView!
    @IBOutlet weak var video10secBack: UIImageView!{
        didSet {
            self.video10secBack.isUserInteractionEnabled = true
            self.video10secBack.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onTap10SecBack)))
        }
    }
    @IBOutlet weak var videoPlayStop: UIImageView!{
        didSet {
            self.videoPlayStop.isUserInteractionEnabled = true
            self.videoPlayStop.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onTapPlayPause)))
        }
    }
    @IBOutlet weak var video10secForward: UIImageView!{
        didSet {
            self.video10secForward.isUserInteractionEnabled = true
            self.video10secForward.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onTap10SecNext)))
        }
    }
    @IBOutlet weak var videoCurrentTimeLabel: UILabel!
    @IBOutlet weak var videoSlider: UISlider!{
        didSet {
            self.videoSlider.addTarget(self, action: #selector(onTapToSlide), for: .valueChanged)
        }
    }
    @IBOutlet weak var videoTotalTimeLabel: UILabel!
    @IBOutlet weak var fullScreen: UIImageView!{
        didSet {
            self.fullScreen.isUserInteractionEnabled = true
            self.fullScreen.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onTapToggleScreen)))
        }
    }
    @IBOutlet weak var courseVideoNameLabel: UILabel!
    @IBOutlet weak var courseListTableView: UITableView!
    
    var course:Item?
    var courseVideoList:[String] = [String]()
    
    private var videoPlayer:AVPlayer? = nil
    private var videoPlayerLayer:AVPlayerLayer? = nil
    
    private var timeObserver : Any? = nil
    private var isThumbSeek : Bool = false
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        courseListTableView.delegate = self
        courseListTableView.dataSource = self
        videoSlider.value = 0
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "chevron.backward"), style: .plain, target: self, action: #selector(self.turnBackToPage))
        self.navigationItem.title = "\(course!.name!)"
        // Do any additional setup after loading the view.
        courseVideoList = (course?.videoLinks)!
        videoPlayer?.addObserver(self, forKeyPath: "timeControlStatus", options: [.new, .initial], context: nil)

      
    }
   
    
    override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        super.willTransition(to: newCollection, with: coordinator)
        guard let windowInterface = self.windowInterface else { return }
        if windowInterface.isPortrait ==  true {
            self.mainVidePlayerViewHeight.constant = 300
        } else {
            self.mainVidePlayerViewHeight.constant = self.view.layer.bounds.width
        }
        print(self.mainVidePlayerViewHeight.constant)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
            self.videoPlayerLayer?.frame = self.mainVideoPlayerView.bounds
        })
    }

}
//MARK: - UITableview Protocols
extension CourseDetailsViewController:UITableViewDelegate,UITableViewDataSource{
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return DeviceHelper.getSafeAreaSize()!.height/15
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        tableView.deselectRow(at: indexPath, animated: true)
    
        print("didselectiçi : \(courseVideoList[indexPath.row])")
//        setVideoPlayer(videoURL: courseVideoList[indexPath.row])
        //load video
        //şimdilik AVPLaycontroller kullan
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
    @objc func playerDidFinishPlaying(notification: Notification) {
           lastPlaybackTime = nil // Video sona erdiğinde oynatma zamanını sıfırla.
    }
 
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return courseVideoList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier:"videoCell",for:indexPath) as! CourseDetailsTableViewCell
        
        cell.courseVideoNameLabel.text = "1)\(extractString(from: courseVideoList[indexPath.row])!)"
        return cell
    }
    

}

//MARK: - Video Player Functions
extension CourseDetailsViewController{
    
    private func setVideoPlayer(videoURL:String?){
        guard let url = URL(string: videoURL!) else { return}
        
        if self.videoPlayer == nil{
            self.videoPlayer = AVPlayer(url: url)
            self.videoPlayerLayer = AVPlayerLayer(player: videoPlayer)
            self.videoPlayerLayer?.videoGravity = .resizeAspectFill
            self.videoPlayerLayer?.frame = self.mainVideoPlayerView.bounds
            self.videoPlayerLayer?.addSublayer(self.videoPlayerView.layer)
            
            if let playerLayer = self.videoPlayerLayer{
                self.mainVideoPlayerView.layer.addSublayer(playerLayer)
            }
            
            self.videoPlayer?.play()
            self.videoPlayStop.image = UIImage(systemName: "pause.circle")
            self.video10secBack.alpha = 0
            self.video10secForward.alpha = 0
        }
        setObserverToPlayer()
    }

    private var windowInterface : UIInterfaceOrientation? {
        return self.view.window?.windowScene?.interfaceOrientation
    }
    
    private func setObserverToPlayer() {
        let interval = CMTime(seconds: 0.3, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        timeObserver = videoPlayer?.addPeriodicTimeObserver(forInterval: interval, queue: DispatchQueue.main, using: { elapsed in
            self.updatePlayerTime()
        })
    }
    
    private func updatePlayerTime() {
        guard let currentTime = self.videoPlayer?.currentTime() else { return }
        guard let duration = self.videoPlayer?.currentItem?.duration else { return }
        
        let currentTimeInSecond = CMTimeGetSeconds(currentTime)
        let durationTimeInSecond = CMTimeGetSeconds(duration)
        
        if self.isThumbSeek == false {
            self.videoSlider.value = Float(currentTimeInSecond/durationTimeInSecond)
        }
        
        let value = Float64(self.videoSlider.value) * CMTimeGetSeconds(duration)
        
        var hours = value / 3600
        var mins =  (value / 60).truncatingRemainder(dividingBy: 60)
        var secs = value.truncatingRemainder(dividingBy: 60)
        var timeformatter = NumberFormatter()
        timeformatter.minimumIntegerDigits = 2
        timeformatter.minimumFractionDigits = 0
        timeformatter.roundingMode = .down
        guard let hoursStr = timeformatter.string(from: NSNumber(value: hours)), let minsStr = timeformatter.string(from: NSNumber(value: mins)), let secsStr = timeformatter.string(from: NSNumber(value: secs)) else {
            return
        }
        self.videoCurrentTimeLabel.text = "\(hoursStr):\(minsStr):\(secsStr)"
        
        hours = durationTimeInSecond / 3600
        mins = (durationTimeInSecond / 60).truncatingRemainder(dividingBy: 60)
        secs = durationTimeInSecond.truncatingRemainder(dividingBy: 60)
        timeformatter = NumberFormatter()
        timeformatter.minimumIntegerDigits = 2
        timeformatter.minimumFractionDigits = 0
        timeformatter.roundingMode = .down
        guard let hoursStr = timeformatter.string(from: NSNumber(value: hours)), let minsStr = timeformatter.string(from: NSNumber(value: mins)), let secsStr = timeformatter.string(from: NSNumber(value: secs)) else {
            return
        }
        self.videoTotalTimeLabel.text = "\(hoursStr):\(minsStr):\(secsStr)"
    }
}

//MARK: - Objc Functions
extension CourseDetailsViewController{
    
    @objc func turnBackToPage(){
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc private func onTap10SecNext() {
        guard let currentTime = self.videoPlayer?.currentTime() else { return }
        let seekTime10Sec = CMTimeGetSeconds(currentTime).advanced(by: 10)
        let seekTime = CMTime(value: CMTimeValue(seekTime10Sec), timescale: 1)
        self.videoPlayer?.seek(to: seekTime, completionHandler: { completed in
            
        })
    }
    
    @objc private func onTap10SecBack() {
        guard let currentTime = self.videoPlayer?.currentTime() else { return }
        let seekTime10Sec = CMTimeGetSeconds(currentTime).advanced(by: -10)
        let seekTime = CMTime(value: CMTimeValue(seekTime10Sec), timescale: 1)
        self.videoPlayer?.seek(to: seekTime, completionHandler: { completed in
            
        })
    }
    
    @objc private func onTapPlayPause() {
    
        if self.videoPlayStop.image == UIImage(systemName: "play.circle"){
            self.videoPlayStop.image = UIImage(systemName: "pause.circle")
                        self.video10secBack.alpha = 0
                        self.video10secForward.alpha = 0
                        self.videoPlayer?.pause()
        }else if self.videoPlayStop.image == UIImage(systemName: "pause.circle") {
            self.videoPlayStop.image = UIImage(systemName: "play.circle")
                        self.video10secBack.alpha = 1
                        self.video10secForward.alpha = 1
                        self.videoPlayer?.play()
        }
//        if self.videoPlayer?.timeControlStatus == .playing {
//            self.videoPlayStop.image = UIImage(systemName: "pause.circle")
//            self.video10secBack.alpha = 0
//            self.video10secForward.alpha = 0
//            self.videoPlayer?.pause()
//        } else {
//            self.videoPlayStop.image = UIImage(systemName: "play.circle")
//            self.video10secBack.alpha = 1
//            self.video10secForward.alpha = 1
//            self.videoPlayer?.play()
//        }
    }
    @objc private func onTapToSlide() {
        self.isThumbSeek = true
        guard let duration = self.videoPlayer?.currentItem?.duration else { return }
        let value = Float64(self.videoSlider.value) * CMTimeGetSeconds(duration)
        if value.isNaN == false {
            let seekTime = CMTime(value: CMTimeValue(value), timescale: 1)
            self.videoPlayer?.seek(to: seekTime, completionHandler: { completed in
                if completed {
                    self.isThumbSeek = false
                }
            })
        }
    }
    
    @objc private func onTapToggleScreen() {
        if #available(iOS 16.0, *) {
            guard let windowSceen = self.view.window?.windowScene else { return }
            if windowSceen.interfaceOrientation == .portrait {
                windowSceen.requestGeometryUpdate(.iOS(interfaceOrientations: .landscape)) { error in
                    print(error.localizedDescription)
                }
            } else {
                windowSceen.requestGeometryUpdate(.iOS(interfaceOrientations: .portrait)) { error in
                    print(error.localizedDescription)
                }
            }
        } else {
            if UIDevice.current.orientation == .portrait {
                let orientation = UIInterfaceOrientation.landscapeRight.rawValue
                UIDevice.current.setValue(orientation, forKey: "orientation")
            } else {
                let orientation = UIInterfaceOrientation.portrait.rawValue
                UIDevice.current.setValue(orientation, forKey: "orientation")
            }
        }
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
}
