//
//  CoursesViewController.swift
//  LearnConnectOnlineAcademy
//
//  Created by Hüdahan Altun on 24.11.2024.
//

import UIKit
import EmptyDataSet_Swift
class CoursesViewController: UIViewController {

    @IBOutlet weak var coursesTableView: UITableView!
    
    var itemVM = ItemViewModel()
    var purchasedCourses:[Item] = [Item] ()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        coursesTableView.delegate = self
        coursesTableView.dataSource = self
        coursesTableView.emptyDataSetSource = self
        coursesTableView.emptyDataSetDelegate = self
        coursesTableView.separatorStyle = .none
    }
   
    override func viewWillAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        if UserViewModel.currentUser() == nil{
            self.navigationItem.title = "Learn Connect"
            purchasedCourses.removeAll()
            coursesTableView.reloadData()
        }else{
            if Connectivity.isInternetAvailable(){
                loadPurchasedItems()
            }else{
                purchasedCourses.removeAll()
                coursesTableView.reloadData()
                Alert.createAlert(title: Alert.noConnectionTitle, message: Alert.noConnectionMessage, view: self)
            }
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "coursesToCourseDetails"{
            let courseDetailVC = segue.destination as! CourseDetailsViewController
            courseDetailVC.course = sender as? Item
        }
    }
    
    func loadPurchasedItems(){
        itemVM.downloadPurchasedItems(UserViewModel.currentUser()!.purchasedItemIds){ allItems in
            self.purchasedCourses = allItems
            print("we have \(self.purchasedCourses.count) purchased items")
            self.coursesTableView.reloadData()
            self.navigationItem.title = "\(self.purchasedCourses.count) Kayıtlı Kurs"
        }
    }
}


//MARK: - UITableViewDelegate
extension CoursesViewController:UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
    
  
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        tableView.deselectRow(at: indexPath, animated: true)
        if Connectivity.isInternetAvailable(){
            performSegue(withIdentifier: "coursesToCourseDetails", sender: purchasedCourses[indexPath.row])
        }else{
            Alert.createAlert(title: Alert.noConnectionTitle, message: Alert.noConnectionMessage, view: self)
        }
    }
    
}

//MARK: - UITableViewDataSource
extension CoursesViewController:UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return purchasedCourses.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "courseCell",for:indexPath) as! CoursesTableViewCell
        cell.createItemsCell(purchasedCourses[indexPath.row])
        return cell
    }
    
}

extension CoursesViewController:EmptyDataSetSource,EmptyDataSetDelegate{
    
   
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
