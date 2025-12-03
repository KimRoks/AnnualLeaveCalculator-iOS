//
//  UIColor+.swift
//  AnnualLeaveCalculator
//
//  Created by 김경록 on 8/11/25.
//

import UIKit

extension UIColor {
    /// 16진수 컬러 컨스트럭터
    public convenience init(hex: String, alpha: CGFloat = 1.0) {
        var hexFormatted: String = hex.trimmingCharacters(
            in: CharacterSet.whitespacesAndNewlines
        ).uppercased()
        if hexFormatted.hasPrefix("#") {
            hexFormatted = String(hexFormatted.dropFirst())
        }
        var rgbValue: UInt64 = 0
        Scanner(string: hexFormatted).scanHexInt64(&rgbValue)
        self.init(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: alpha
        )
    }
    
    static var brandColor: UIColor {
        UIColor { trait in
            if trait.userInterfaceStyle == .dark {
                return UIColor(hex: "#0057B8")
            } else {
                return UIColor(hex: "#0057B8")
            }
        }
    }
}
