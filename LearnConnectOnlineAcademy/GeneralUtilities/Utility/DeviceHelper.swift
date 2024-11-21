//
//  DeviceHelper.swift
//  LearnConnectOnlineAcademy
//
//  Created by Hüdahan Altun on 21.11.2024.
//

import UIKit

class DeviceHelper{
    static func getSafeAreaSize() -> (width: CGFloat, height: CGFloat)? {
        
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else {
            return nil
        }
        
        let safeAreaInsets = window.safeAreaInsets
        let safeAreaWidth = window.frame.width - safeAreaInsets.left - safeAreaInsets.right
        let safeAreaHeight = window.frame.height - safeAreaInsets.top - safeAreaInsets.bottom
        
        return (width: safeAreaWidth, height: safeAreaHeight)
    }
}
