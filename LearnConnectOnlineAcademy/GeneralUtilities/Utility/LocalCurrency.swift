//
//  LocalCurrency.swift
//  LearnConnectOnlineAcademy
//
//  Created by Hüdahan Altun on 23.11.2024.
//

import Foundation

struct LocalCurrency{
    
    func convertCurrency(_ number:Double)->String{//81
        let currencyFormatter = NumberFormatter()//81
        currencyFormatter.usesGroupingSeparator = true//81
        currencyFormatter.numberStyle = .currency//81
        currencyFormatter.locale = Locale(identifier: "tr_TR")
        
        return currencyFormatter.string(from: NSNumber(value: number))!//81
    }
}
