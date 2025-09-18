//
//  Font+.swift
//  AnnualLeaveCalculator
//
//  Created by 김경록 on 8/11/25.
//

import UIKit

public enum FontStyle {
    case regular
    case medium
    case bold
    case semiBold
    case extraBold

    var fontName: String {
        switch self {
        case .regular:
            return "Pretendard-Regular"
        case .medium:
            return "Pretendard-Medium"
        case .bold:
            return "Pretendard-Bold"
        case .semiBold:
            return "Pretendard-SemiBold"
        case .extraBold:
            return "Pretendard-ExtraBold"
        }
    }
}

extension UIFont {
    public static func pretendard(style: FontStyle, size: CGFloat) -> UIFont {
        guard let font = UIFont(name: style.fontName, size: size) else {
            return UIFont.systemFont(ofSize: size)
        }
        return font
    }
}
