//
//  ItemsViewController.swift
//  LearnConnectOnlineAcademy
//
//  Created by Hüdahan Altun on 22.11.2024.
//

import UIKit
import Combine
import EmptyDataSet_Swift
class ItemsViewController: UIViewController {

    @IBOutlet weak var itemsTableView: UITableView!
    
    var subcategory:SubCategory?
    var itemsVM = ItemViewModel()

    private var cancellableItems:Set<AnyCancellable> = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = subcategory?.name
        
        itemsTableView.delegate = self
        itemsTableView.dataSource = self
        itemsTableView.separatorStyle = .none
        itemsTableView.emptyDataSetSource = self
        itemsTableView.emptyDataSetDelegate = self

        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "chevron.backward"), style: .plain, target: self, action: #selector(self.turnBackToPage))
        setUpBinders()
    }
    override func viewWillAppear(_ animated: Bool) {
        if Connectivity.isInternetAvailable(){
            itemsVM.downloadItemsFromFirebase(withSubCategoryId: subcategory!.id)
        }else{
            Alert.createAlert(title: Alert.noConnectionTitle, message: Alert.noConnectionMessage, view: self)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        itemsVM.items.removeAll()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "itemsToItem"{
            let itemVC = segue.destination as! ItemViewController
            itemVC.item = sender as? Item
        }
    }
    
    func setUpBinders(){
        itemsVM.$items.sink{ [weak self]  itemss in
            DispatchQueue.main.async {
                self?.itemsTableView.reloadData()
            }
        }.store(in: &cancellableItems)
    }
}
//MARK: - UITableViewDelegate
extension ItemsViewController:UITableViewDelegate{
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return DeviceHelper.getSafeAreaSize()!.height/5
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        tableView.deselectRow(at: indexPath, animated: true)
        if Connectivity.isInternetAvailable(){
            performSegue(withIdentifier: "itemsToItem", sender: itemsVM.items[indexPath.row])
        }else{
            Alert.createAlert(title: Alert.noConnectionTitle, message: Alert.noConnectionMessage, view: self)
        }
    }
    
}
//MARK: - UITableViewDataSource
extension ItemsViewController:UITableViewDataSource{

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemsVM.items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let itemCell = tableView.dequeueReusableCell(withIdentifier: "itemCell", for: indexPath) as! ItemTableViewCell
        itemCell.createItemsCell(itemsVM.items[indexPath.row])
        itemCell.runCellAnimation()
        
        return itemCell
    }
    
}
//MARK: - EmptyDataSetTableView
extension ItemsViewController:EmptyDataSetSource,EmptyDataSetDelegate{
    
    func title(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
        
        return NSAttributedString(string: "Görüntülenecek kurs bulunamadı!")
    }
    
    func image(forEmptyDataSet scrollView: UIScrollView) -> UIImage? {
        if Connectivity.isInternetAvailable(){
            return UIImage(named: "emptyBox")
        }else{
            return UIImage(named: "noWifi")
        }
        
    }
    
}
//MARK: - OBJC
extension ItemsViewController{
    
    @objc func turnBackToPage(){
        self.navigationController?.popViewController(animated: true)
    }
}
