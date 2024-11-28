//
//  OnSaleViewController.swift
//  LearnConnectOnlineAcademy
//
//  Created by Hüdahan Altun on 27.11.2024.
//

import UIKit
import EmptyDataSet_Swift

class OnSaleViewController: UIViewController {

    @IBOutlet weak var onSaleTableView: UITableView!
    
    var onSaleItems:[Item] = [Item] ()
    var onSaleVM = OnSaleViewModel()
    
    var onSale:OnSale?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        onSaleTableView.delegate = self
        onSaleTableView.dataSource = self
        onSaleTableView.emptyDataSetSource = self
        onSaleTableView.emptyDataSetDelegate = self
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        let loggedUser = UserViewModel.currentUser()
        loadOnSaleFromFirebase(loggedUser: loggedUser!)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.onSaleTableView.reloadData()
            self.navigationItem.title = "Satışa Sunulanlar (\(self.onSaleItems.count) Ürün)"
        }
    }
    
}

//MARK: - OnSaleHelper
extension OnSaleViewController{
    
    private func loadOnSaleFromFirebase(loggedUser:User?){//
        onSaleVM.downloadOnSaleFromFirestore(loggedUser!.email!){ onSale in//oturum açan kullanıcının sepetini indir.
            self.onSale = onSale
            self.loadItemsFromOnSale()//sepetteki itemleri getir.
        }
    }
    
    private func loadItemsFromOnSale(){//onSale itemleri getir.
        if onSale != nil{
            onSaleVM.downloadItemsForOnSale(onSale!.itemIds){ allItems in//onSale itemleri getir.
                print("gelen ürün sayısı:\(allItems.count)")
                self.onSaleItems = allItems
                self.onSaleTableView.reloadData()
                self.navigationItem.title = "..."
                
            }
        }
    }
    
    private func removeItemFromOnSale(itemId:String){//tablevie' dataosruce'dan sildik şimdi onSale'den silcez.
        for i in 0...(onSale?.itemIds.count)! {// sepetteki ürün sayısı kadar git
            if itemId == onSale?.itemIds[i] {//silinen item id'si ile sepetteki id'leri eşle
                onSale?.itemIds.remove(at: i)//sepetteki itemi sil
                return
            }
        }
    }
    
    func approveDeleteAlert(indexPath:IndexPath){
        let alertController = UIAlertController(title: "Ürünü Sil", message: "Seçili ürünü silmek istediğinizden eminmisin? Ürün ilgili kategoriden kaldırılacaktır.", preferredStyle: .alert)
        
        let OKButton = UIAlertAction(title: "Sil", style: .destructive){ _ in
            
            let deletedItem = self.onSaleItems.remove(at: indexPath.row)//data source'dan seçili itemi'i sil
            self.onSaleTableView.reloadData()//reload
            self.removeItemFromOnSale(itemId: deletedItem.id)//onSale kaldır
            ItemViewModel().removeItemFromFirestore(itemId: deletedItem.id)//ürünlerden komple kaldır.
            self.onSaleVM.updateOnSaleInFirestore(self.onSale!, withValues: [FirebaseConstants().kITEMIDS:self.onSale!.itemIds]){ error in
                if error != nil {
                    print("günc hatası")
                }
                self.loadItemsFromOnSale()
            }
        }
        let cancelButton = UIAlertAction(title: "İptal", style: .cancel){_ in
            print("iptal tıklandı")
            self.view.endEditing(true)
        }
        
        alertController.addAction(OKButton)
        alertController.addAction(cancelButton)
        
        self.present(alertController, animated: true)
    }
    
    
}
//MARK: -  UITableViewDataSource
extension OnSaleViewController:UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let delete = UIContextualAction(style: .destructive, title: "Sil"){ _,_,_ in
            self.approveDeleteAlert(indexPath: indexPath)
        }
        return UISwipeActionsConfiguration(actions: [delete])
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let itemVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "itemVC") as! ItemViewController
        itemVC.item = onSaleItems[indexPath.row]
        self.navigationController?.pushViewController(itemVC, animated: true)
    }
    
}
//MARK: - UITableViewDatasource
extension OnSaleViewController:UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
         return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return onSaleItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "onSaleCell",for:indexPath) as! OnSaleTableViewCell
        cell.createOnSaleItemsCell(onSaleItems[indexPath.row])
        return cell
        
    }
}
//MARK: - UITableViewEmptyDataset
extension OnSaleViewController:EmptyDataSetSource,EmptyDataSetDelegate{
    
    func title(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
        
        if Connectivity.isInternetAvailable(){
            return NSAttributedString(string: "Satışa çıkarılan kurs bulunamadı!")
        }else{
            return NSAttributedString(string: "İnternet Bağlantınızı Kontrol Ediniz!")
        }
        
    }
    
    func image(forEmptyDataSet scrollView: UIScrollView) -> UIImage? {
        
        
        if Connectivity.isInternetAvailable(){
            return UIImage(named: "increase")
        }else{
            return UIImage(named: "noWifi")
        }
    }
  
}
