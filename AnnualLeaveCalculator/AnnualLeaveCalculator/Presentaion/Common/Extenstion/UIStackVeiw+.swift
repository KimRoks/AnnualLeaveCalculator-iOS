//
//  UIStackVeiw+.swift
//  AnnualLeaveCalculator
//
//  Created by 김경록 on 8/19/25.
//

import UIKit

extension UIStackView {
    @discardableResult
    func addArrangedSubviews(_ subviews: UIView...) -> UIStackView {
        subviews.forEach { addArrangedSubview($0) }
        return self
    }
}
