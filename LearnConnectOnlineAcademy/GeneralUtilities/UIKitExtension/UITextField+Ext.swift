//
//  UITextField+Ext.swift
//  LearnConnectOnlineAcademy
//
//  Created by Hüdahan Altun on 22.11.2024.
//

import Foundation
import UIKit

extension UITextField {
    
    func setIconAtLeft(_ image: UIImage,color:UIColor) {
        let iconView = UIImageView(frame:CGRect(x: 2, y:4, width: 26, height: 26))
        iconView.image = image
        iconView.tintColor = color
        
        let iconContainerView: UIView = UIView(frame:CGRect(x: 10, y: 0, width: 34, height: 34))
        iconContainerView.addSubview(iconView)
        
        leftView = iconContainerView
        leftViewMode = .always
    }
    
    func setIconAtRight(_ image: UIImage,color:UIColor) {
        let iconView = UIImageView(frame:CGRect(x: 2, y:4, width: 26, height: 26))
        iconView.image = image
        iconView.tintColor = color
        
        let iconContainerView: UIView = UIView(frame:CGRect(x: 10, y: 0, width: 34, height: 34))
        iconContainerView.addSubview(iconView)
        
        rightView = iconContainerView
        rightViewMode = .always
    }
    
    
}
