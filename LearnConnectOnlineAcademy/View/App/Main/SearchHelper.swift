//
//  SearchHelper.swift
//  LearnConnectOnlineAcademy
//
//  Created by Hüdahan Altun on 26.11.2024.
//

import Foundation
import UIKit

class SearchHelper{
    
    func setAlphaValue(value:CGFloat,views:UIView...){
        for view in views{
            view.alpha = value
        }
    }
    
    func runAnimationWhenUserCLickedBarButtonItem(searchBar:UISearchBar){
        
        UIView.animate(withDuration: 0.5){
            if searchBar.alpha == 0{
                searchBar.alpha = 1
            }else{
                 searchBar.alpha = 0
            }
        }
    }
    
    func showTableView(tableView:UITableView){
        UIView.animate(withDuration: 0.5){
            tableView.alpha = 1
        }
    }
    func hideTableView(tableView:UITableView){
        UIView.animate(withDuration: 0.5){
            tableView.alpha = 0
        }
    }
    func showActivity(activityIndicator:UIActivityIndicatorView,viewController:SearchViewController){
        viewController.view.addSubview(activityIndicator)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: viewController.view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: viewController.view.centerYAnchor)
        ])
        activityIndicator.startAnimating()
        
    }
    func hideActivity(activityIndicator:UIActivityIndicatorView,viewController:SearchViewController){
        viewController.activityIndicator.removeFromSuperview()
        activityIndicator.stopAnimating()
    }
    
}
