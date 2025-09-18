//
//  UIView+.swift
//  AnnualLeaveCalculator
//
//  Created by 김경록 on 8/14/25.
//

import UIKit

public extension UIView {
    @discardableResult
    func addSubviews(_ subviews: UIView...) -> UIView {
        subviews.forEach { addSubview($0) }
        return self
    }
}
