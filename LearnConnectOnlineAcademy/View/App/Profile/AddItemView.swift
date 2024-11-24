//
//  AddItemView.swift
//  LearnConnectOnlineAcademy
//
//  Created by Hüdahan Altun on 22.11.2024.
//

import Foundation
import UIKit
import Photos
import PhotosUI

class AddItemView{

    func setButtonCornerRadius(value:CGFloat,views:UIView...){
        for view in views{
            view.layer.cornerRadius = value
        }
    }
    
    func setAlphaValue(value:CGFloat,views:UIView...){
        for view in views{
            view.alpha = value
        }
    }
    
    func configureCategory(pickerview:UIPickerView,textfield:UITextField,view:AddItemViewController){
        pickerview.delegate = view
        pickerview.dataSource = view
        textfield.inputView = pickerview
    }
    func configureSubCategory(pickerview:UIPickerView,textfield:UITextField,view:AddItemViewController){
        pickerview.delegate = view
        pickerview.dataSource = view
        textfield.inputView = pickerview
    }
   
    func runAnimate(views:UIView...){
        for view in views{
            UIView.animate(withDuration: 0.5){
                view.alpha = 1
            }
        }
    }
    
    func retreieveAnimate(views:UIView...){
        for view in views{
            UIView.animate(withDuration: 0.5){
                view.alpha = 0
            }
        }
    }
    
    
}

