//
//  ItemReviewsViewController.swift
//  LearnConnectOnlineAcademy
//
//  Created by Hüdahan Altun on 26.11.2024.
//

import UIKit
import Combine
import EmptyDataSet_Swift
class ItemReviewsViewController: UIViewController {
    
    @IBOutlet weak var itemReviewsTableView: UITableView!
    
    var item:Item?
    var reviewVM = ReviewViewModel()
    var reviews:[Review] = [Review]()
    
    private var cancellableItems:Set<AnyCancellable> = []

    override func viewDidLoad() {
        super.viewDidLoad()
        itemReviewsTableView.delegate = self
        itemReviewsTableView.dataSource = self
        itemReviewsTableView.emptyDataSetSource = self
        itemReviewsTableView.emptyDataSetDelegate = self
        itemReviewsTableView.separatorStyle = .none
        navigationItem.title = item?.name

        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "chevron.backward"), style: .plain, target: self, action: #selector(self.turnBackToPage))
        setUpBinders()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        if Connectivity.isInternetAvailable(){
            reviewVM.downloadReviewsFromFirebase(itemID: item!.id!)
        }else{
            Alert.createAlert(title: Alert.noConnectionTitle, message: Alert.noConnectionMessage, view: self)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        reviewVM.reviews.removeAll()
    }
    
    func setUpBinders(){
        reviewVM.$reviews.sink{ [weak self]  itemss in
            DispatchQueue.main.async {
                self?.itemReviewsTableView.reloadData()
            }
        }.store(in: &cancellableItems)
    }

}
//MARK: - UITableViewDelegate
extension ItemReviewsViewController:UITableViewDelegate{
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 160
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
//MARK: - UITableDataSource
extension ItemReviewsViewController:UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
         return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return reviewVM.reviews.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let reviewCell =  tableView.dequeueReusableCell(withIdentifier:"itemReviewCell", for:indexPath) as! ItemReviewsTableViewCell
        reviewCell.createReviewCell(reviewVM.reviews[indexPath.row])
        return reviewCell
        
    }
}
//MARK: - UITableViewEmpty
extension ItemReviewsViewController:EmptyDataSetSource,EmptyDataSetDelegate{
    func title(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
        
        if Connectivity.isInternetAvailable(){
            return NSAttributedString(string: "Kursa ait değerlendirme bulunamadı!")
        }else{
            return NSAttributedString(string: "İnternet bağlantınızı kontrol ediniz!")
        }
        
    }
    
    func image(forEmptyDataSet scrollView: UIScrollView) -> UIImage? {
        if Connectivity.isInternetAvailable(){
            return UIImage(named: "noComments")
        }else{
            return UIImage(named: "noWifi")
        }
        
    }
}
//MARK: - OBJC
extension ItemReviewsViewController{
    
    @objc func turnBackToPage(){
        self.navigationController?.popViewController(animated: true)
    }
}
