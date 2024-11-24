//
//  CartHelper.swift
//  LearnConnectOnlineAcademy
//
//  Created by Hüdahan Altun on 24.11.2024.
//

import UIKit


class CartHelper{
    
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
}
