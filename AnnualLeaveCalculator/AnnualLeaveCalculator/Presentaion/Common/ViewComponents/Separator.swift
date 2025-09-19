//
//  Separator.swift
//  AnnualLeaveCalculator
//
//  Created by 김경록 on 9/19/25.
//

import UIKit

import SnapKit

final class Separator: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor(hex: "#F2F2F2")
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var intrinsicContentSize: CGSize {
        return CGSize(width: UIView.noIntrinsicMetric, height: 1)
    }
}
