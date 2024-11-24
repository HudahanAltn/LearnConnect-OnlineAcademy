//
//  UIImageView+Ext.swift
//  LearnConnectOnlineAcademy
//
//  Created by Hüdahan Altun on 22.11.2024.
//

import Foundation
import UIKit

extension UIImageView{
    
    func setImageViewFrame(cornerRadius:CGFloat){
        layer.cornerRadius = cornerRadius
        clipsToBounds = true
        contentMode = .scaleAspectFill
    }
    
}


extension UIImage {
    func fixedOrientation() -> UIImage {
        // Görüntünün zaten doğru oryantasyonda olup olmadığını kontrol et
        if self.imageOrientation == .up {
            return self
        }

        // Görüntü oryantasyonunu düzeltmek için grafik bağlamı oluştur
        UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale)
        defer { UIGraphicsEndImageContext() }

        self.draw(in: CGRect(origin: .zero, size: self.size))
        let normalizedImage = UIGraphicsGetImageFromCurrentImageContext()!
        return normalizedImage
    }
}
