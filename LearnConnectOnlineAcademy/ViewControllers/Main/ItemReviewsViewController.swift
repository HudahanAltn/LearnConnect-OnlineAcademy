//
//  ItemReviewsViewController.swift
//  LearnConnectOnlineAcademy
//
//  Created by Hüdahan Altun on 26.11.2024.
//

import UIKit
import Combine
class ItemReviewsViewController: UIViewController {
    
    @IBOutlet weak var itemReviewsTableView: UITableView!
    
    var reviewVM = ReviewViewModel()
    var item:Item?
    
    var reviews:[Review] = [Review]()
    
    private var cancellableItems:Set<AnyCancellable> = []

    override func viewDidLoad() {
        super.viewDidLoad()

        itemReviewsTableView.delegate = self
        itemReviewsTableView.dataSource = self
        itemReviewsTableView.separatorStyle = .none
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.navigationItem.largeTitleDisplayMode = .always
        setUpBinders()
       
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        reviewVM.downloadReviewsFromFirebase(itemID: item!.id!)
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

extension ItemReviewsViewController:UITableViewDelegate{
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 160
    }
}

extension ItemReviewsViewController:UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
         return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return reviewVM.reviews.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let reviewCell =  tableView.dequeueReusableCell(withIdentifier:"itemReviewCell", for:indexPath) as! ItemReviewsTableViewCell
        reviewCell.createItemsCell(reviewVM.reviews[indexPath.row])
        return reviewCell
        
    }
}
