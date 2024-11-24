//
//  ViewController.swift
//  LearnConnectOnlineAcademy
//
//  Created by Hüdahan Altun on 21.11.2024.
//

import UIKit
import Combine

class ViewController: UIViewController {

    
    @IBOutlet weak var searchBar: UISearchBar!
    
    @IBOutlet weak var categoryTableView: UITableView!
    
    var categoryVM = CategoryViewModel()
   
    private var cancellableItems:Set<AnyCancellable> = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        categoryTableView.dataSource = self
        categoryTableView.delegate = self
        categoryTableView.separatorStyle = .none

        setUpBinders()
        // Do any additional setup after loading the view.
    }
  
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "categoryToSubcategory"{
            let subCategoryVC = segue.destination as! SubcategoryViewController
            subCategoryVC.category = sender as? Category
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        if Connectivity.isInternetAvailable(){
            categoryVM.downloadCategoriesFromFirebase()
        }else{
            Alert.createAlert(title: Alert.noConnectionTitle, message: Alert.noConnectionMessage, view: self)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        //nesneleri bellekten temizle
        categoryVM.categories.removeAll()
    }
    
    
    
    func setUpBinders(){
        categoryVM.$categories.sink{ [weak self]  itemss in
            DispatchQueue.main.async {
                self?.categoryTableView.reloadData()
            }
        }.store(in: &cancellableItems)
    }

}

//MARK: - UITableViewDelegate
extension ViewController:UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return DeviceHelper.getSafeAreaSize()!.height/12
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        tableView.deselectRow(at: indexPath, animated: true)
        if Connectivity.isInternetAvailable(){
            performSegue(withIdentifier: "categoryToSubcategory", sender: categoryVM.categories[indexPath.row])
        }else{
            Alert.createAlert(title: Alert.noConnectionTitle, message: Alert.noConnectionMessage, view: self)
        }
    }
    
}
//MARK: -UITableViewDataSource
extension ViewController:UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categoryVM.categories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let categoryCell = tableView.dequeueReusableCell(withIdentifier: "categoryCell",for:indexPath) as! CategoryTableViewCell
        categoryCell.CategoryNameLabel.text = categoryVM.categories[indexPath.row].name
        categoryCell.runCellAnimation()
        return categoryCell
    }
    
}

extension ViewController:UISearchBarDelegate{

    
    
}


