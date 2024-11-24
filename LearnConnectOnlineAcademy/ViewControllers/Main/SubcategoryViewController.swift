//
//  SubcategoryViewController.swift
//  LearnConnectOnlineAcademy
//
//  Created by Hüdahan Altun on 22.11.2024.
//

import UIKit
import Combine

class SubcategoryViewController: UIViewController {

    @IBOutlet weak var subcategoryTableView: UITableView!
    
    var subcategoryVM = SubcategoryViewModel()
    private var cancellableSubcategory:Set<AnyCancellable> = []
    var category:Category?
   
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = category!.name
        subcategoryTableView.delegate = self
        subcategoryTableView.dataSource = self
        subcategoryTableView.separatorStyle = .none

        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "chevron.backward"), style: .plain, target: self, action: #selector(self.turnBackToPage))

        setUpBinders()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if Connectivity.isInternetAvailable(){
            subcategoryVM.downloadSubCategoriesFromFirebase(withSubCategoryId: category!.id )
        }else{
            Alert.createAlert(title: Alert.noConnectionTitle, message: Alert.noConnectionMessage, view: self)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        //nesneleri bellekten temizle
        subcategoryVM.subCategories.removeAll()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "subcategoryToItems"{
            let itemsVC = segue.destination as! ItemsViewController
            itemsVC.subcategory = sender as? SubCategory
        }
        
    }
    
    func setUpBinders(){
        subcategoryVM.$subCategories.sink{ [weak self]  subcategories in
            if  subcategories.count > 0{
                self?.subcategoryTableView.reloadData()
            }
        }.store(in: &cancellableSubcategory)
    }


}

extension SubcategoryViewController:UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return DeviceHelper.getSafeAreaSize()!.height/12
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        tableView.deselectRow(at: indexPath, animated: true)
        if Connectivity.isInternetAvailable(){
            performSegue(withIdentifier: "subcategoryToItems", sender: subcategoryVM.subCategories[indexPath.row])
        }else{
            Alert.createAlert(title: Alert.noConnectionTitle, message: Alert.noConnectionMessage, view: self)
        }
    }
}

extension SubcategoryViewController:UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return subcategoryVM.subCategories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let categoryCell = tableView.dequeueReusableCell(withIdentifier: "subcategoryCell",for:indexPath) as! SubcategoryTableViewCell
        categoryCell.subcategoryNameLabel.text = subcategoryVM.subCategories[indexPath.row].name
        categoryCell.runCellAnimation()
        return categoryCell
    }
}


extension SubcategoryViewController{
    
    @objc func turnBackToPage(){
        self.navigationController?.popViewController(animated: true)
    }
}
