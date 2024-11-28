//
//  DownloadedVideosViewController.swift
//  LearnConnectOnlineAcademy
//
//  Created by Hüdahan Altun on 26.11.2024.
//

import UIKit
import CoreData
import AVKit
import AVFoundation
import EmptyDataSet_Swift

class DownloadedVideosViewController: UIViewController {
    
    @IBOutlet weak var downloadedVideoTableView: UITableView!
    
    let context = appDelegate.persistentContainer.viewContext
    var downloadedVideoList:[Video] = [Video]()
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        downloadedVideoTableView.delegate = self
        downloadedVideoTableView.dataSource = self
        downloadedVideoTableView.emptyDataSetSource = self
        downloadedVideoTableView.emptyDataSetDelegate = self
        fetchVideo()
    }
    override func viewWillAppear(_ animated: Bool) {
        fetchVideo()
    }
    func fetchVideo(){
        
        do{
            downloadedVideoList = try context.fetch(Video.fetchRequest())
        }catch{
            print("getirme hatası!")
        }
    }

}

//MARK: -  UITableViewDelegate
extension DownloadedVideosViewController: UITableViewDelegate{
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
    
        print("didselectiçi : \(downloadedVideoList[indexPath.row].savedVideoURL!)")

        let player = AVPlayer(url: URL(string: downloadedVideoList[indexPath.row].savedVideoURL!)!)
        let avplayerVC = AVPlayerViewController()
        avplayerVC.player = player
        self.present(avplayerVC, animated: true){
            player.play()
        }
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let delete = UIContextualAction(style: .destructive, title: "Sil"){ _,_,_ in
            let deletedItem = self.downloadedVideoList.remove(at: indexPath.row)
            self.context.delete(deletedItem)
            appDelegate.saveContext()
            tableView.reloadData()//reload
        }
        return UISwipeActionsConfiguration(actions: [delete])
    }
}
//MARK: - UITableViewDataSource
extension DownloadedVideosViewController: UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return downloadedVideoList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "downloadedVideoCell",for:indexPath) as! DownloadedVideosTableViewCell
        cell.videoNameLabel.text = downloadedVideoList[indexPath.row].videoName
        return cell
    }
}
//MARK: - UITableViewEmpty
extension DownloadedVideosViewController:EmptyDataSetSource,EmptyDataSetDelegate{
    
    func title(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
        
        return NSAttributedString(string: "İndirilen Kurs Yok!")
    }
    
    func image(forEmptyDataSet scrollView: UIScrollView) -> UIImage? {
        return UIImage(named: "noDownloaded")
        
    }
    
}


