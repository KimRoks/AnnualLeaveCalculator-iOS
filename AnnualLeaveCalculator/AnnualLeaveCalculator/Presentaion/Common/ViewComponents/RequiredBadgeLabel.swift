//
//  RequiredBadgeLabel.swift
//  AnnualLeaveCalculator
//
//  Created by 김경록 on 9/11/25.
//

import UIKit

final class RequiredBadgeLabel: UILabel {
    private let insets = UIEdgeInsets(top: 2, left: 4, bottom: 2, right: 4)
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor(hex: "#EAF6FF")     // 옅은 하늘색
        textColor = UIColor(hex: "#153BD3")           // 포인트 블루
        font = .pretendard(style: .medium, size: 11)
        layer.cornerRadius = 8
        clipsToBounds = true
        text = "필수사항"
    }
    required init?(coder: NSCoder) { fatalError() }

    override func drawText(in rect: CGRect) {
        super.drawText(in: rect.inset(by: insets))
    }
    override var intrinsicContentSize: CGSize {
        let s = super.intrinsicContentSize
        return CGSize(width: s.width + insets.left + insets.right,
                      height: s.height + insets.top + insets.bottom)
    }
}
