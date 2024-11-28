//
//  SearchViewController.swift
//  LearnConnectOnlineAcademy
//
//  Created by Hüdahan Altun on 26.11.2024.
//

import UIKit
import EmptyDataSet_Swift
import AlgoliaSearchClient

class SearchViewController: UIViewController {
    @IBOutlet weak var searchBar: UISearchBar!
    
    @IBOutlet weak var searchTableView: UITableView!
    
    var activityIndicator:UIActivityIndicatorView = {
       var Activity = UIActivityIndicatorView()
        Activity.hidesWhenStopped = true
        Activity.color = UIColor.systemGreen
        Activity.style = .large
        return Activity
    }()
    
    var searchHelper = SearchHelper()//helper
    var itemVM = ItemViewModel()
    var searchVM = SearchViewModel()
    var searchResults:[Item] = [Item]()
    var itemIDSearchResultsFromAlgolia:[String] = [String] ()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self
        searchBar.autocapitalizationType = .none
        searchBar.returnKeyType = .done
        searchTableView.delegate = self
        searchTableView.dataSource = self
        searchTableView.emptyDataSetSource = self
        searchTableView.emptyDataSetDelegate = self
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if Connectivity.isInternetAvailable(){
            searchHelper.setAlphaValue(value: 0, views: searchTableView)
        }else{
            Alert.createAlert(title: "Hata", message: "İnternet Bağlantınızı Kontrol Ediniz!", view: self)
        }
    }

}

//MARK: - Helper
extension SearchViewController{

    private func showItemVC(withItem:Item){
        let itemVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "itemVC") as! ItemViewController
        itemVC.item = withItem
        self.navigationController?.pushViewController(itemVC, animated: true)
    }
    
    private func searchInFirebase(itemIds:[String]){
        itemVM.downloadItemsForSearching(itemIds){ itemArray in
            self.searchResults = itemArray
            self.searchTableView.reloadData()
            self.searchHelper.hideActivity(activityIndicator: self.activityIndicator, viewController: self)
        }
    }
    
    func userIsNotSearching(){
        searchHelper.hideActivity(activityIndicator: activityIndicator, viewController: self)
        searchHelper.hideTableView(tableView: searchTableView)
        
    }
    
    func userIsSeaching(searchText:String){
        searchHelper.showActivity(activityIndicator: activityIndicator, viewController: self)
        searchHelper.showTableView(tableView: searchTableView)
        
        itemIDSearchResultsFromAlgolia.removeAll()//temizle
        itemIDSearchResultsFromAlgolia = searchVM.searchItemAtAlgolia(searchString: searchText)
        searchInFirebase(itemIds: itemIDSearchResultsFromAlgolia)
    }
}

//MARK: - UITableViewDelegate
extension SearchViewController:UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        tableView.deselectRow(at: indexPath, animated: true)
        if Connectivity.isInternetAvailable(){
            showItemVC(withItem: searchResults[indexPath.row])
        }else{
            Alert.createAlert(title: "Hata", message: "İnternet Bağlantınızı Kontrol Ediniz!", view: self)
        }
        
    }
}

//MARK: - UITableViewDataSource
extension SearchViewController:UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
         return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResults.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let searchCell = tableView.dequeueReusableCell(withIdentifier: "searchCell",for:indexPath) as! SearchTableViewCell
        searchCell.createItemsCell(searchResults[indexPath.row])
        searchCell.runCellAnimation()
        let customSelectionColor = UIView()
        customSelectionColor.backgroundColor = .clear
        searchCell.selectedBackgroundView = customSelectionColor
        return searchCell
    }
}

//MARK: -  UISearchBarDelegate
extension SearchViewController:UISearchBarDelegate{
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {//dinamik arama
        
        if searchText == ""{
            userIsNotSearching()
        }else{
            userIsSeaching(searchText: searchText)
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {//klavyeyi kapat
        view.endEditing(true)
    }
    
}

//MARK: - UITableViewEmpty
extension SearchViewController:EmptyDataSetSource,EmptyDataSetDelegate{
    
    func title(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
        
        if Connectivity.isInternetAvailable(){
            return NSAttributedString(string: "Aranan kurs bulunamadı!")

        }else{
            return NSAttributedString(string: "İnternet Bağlantısı Yok!")
        }
    }
    
    func image(forEmptyDataSet scrollView: UIScrollView) -> UIImage? {
        
        if Connectivity.isInternetAvailable(){
            return UIImage(named: "noSearchResult")
        }else{
            return UIImage(named: "nowifi")
        }
        
    }
    
 
}
