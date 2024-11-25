//
//  PaymentHelper.swift
//  LearnConnectOnlineAcademy
//
//  Created by Hüdahan Altun on 24.11.2024.
//


import Foundation
import UIKit

class PaymentHelper{
    
    func setButtonCornerRadius(value:CGFloat,views:UIView...){
        for view in views{
            view.layer.cornerRadius = value
        }
    }
}
