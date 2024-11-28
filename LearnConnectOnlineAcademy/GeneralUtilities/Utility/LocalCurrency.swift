//
//  LocalCurrency.swift
//  LearnConnectOnlineAcademy
//
//  Created by Hüdahan Altun on 23.11.2024.
//

import Foundation

struct LocalCurrency{
    
    func convertCurrency(_ number:Double)->String{
        let currencyFormatter = NumberFormatter()
        currencyFormatter.usesGroupingSeparator = true
        currencyFormatter.numberStyle = .currency
        currencyFormatter.locale = Locale(identifier: "tr_TR")
        
        return currencyFormatter.string(from: NSNumber(value: number))!
    }
}
