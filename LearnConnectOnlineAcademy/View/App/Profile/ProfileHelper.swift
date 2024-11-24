//
//  ProfileHelper.swift
//  LearnConnectOnlineAcademy
//
//  Created by Hüdahan Altun on 22.11.2024.
//

import Foundation
import UIKit

class ProfileHelper{
    
    func setButtonCornerRadius(value:CGFloat,views:UIView...){
        for view in views{
            view.layer.cornerRadius = value
        }
    }
    func setButtonBorderColor(value:CGFloat,color:UIColor,buttons:UIButton...){
        for button in buttons{
            button.layer.borderWidth = value
            button.layer.borderColor = color.cgColor
        }
    }

    func setAlphaValue(value:CGFloat,views:UIView...){
        for view in views{
            view.alpha = value
        }
    }
}
