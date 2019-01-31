//
//  Utility.swift
//  Crypto
//
//  Created by Milan Shah on 1/18/19.
//  Copyright © 2019 Milan Shah. All rights reserved.
//

import Foundation
import UIKit

// Show Crypto Progress Indicator
func showCryptoProgressIndicator(view:UIView) {
    
    view.isUserInteractionEnabled = false
    let cryptoProgressIndicator = CryptoProgressIndicator(text: "Please wait...")
    cryptoProgressIndicator.tag = CryptoProgressIndicatorTag
    view.addSubview(cryptoProgressIndicator)
}

// Hide Crypto Progress Indicator
func hideCryptoProgressIndicator(view:UIView){
    
    view.isUserInteractionEnabled = true
    if let progressTagView = view.viewWithTag(CryptoProgressIndicatorTag) {
        progressTagView.removeFromSuperview()
    }
    
}

func hexStringToUIColor (hex:String) -> UIColor {
    var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
    
    if (cString.hasPrefix("#")) {
        cString.remove(at: cString.startIndex)
    }
    
    if ((cString.count) != 6) {
        return UIColor.gray
    }
    
    var rgbValue:UInt32 = 0
    Scanner(string: cString).scanHexInt32(&rgbValue)
    
    return UIColor(
        red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
        green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
        blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
        alpha: CGFloat(1.0))
}

