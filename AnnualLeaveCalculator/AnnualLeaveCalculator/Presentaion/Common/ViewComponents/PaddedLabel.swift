//
//  PaddedLabel.swift
//  AnnualLeaveCalculator
//
//  Created by 김경록 on 9/14/25.
//

import UIKit

final class PaddedLabel: UILabel {
    var textInsets: UIEdgeInsets = UIEdgeInsets(top: 6, left: 10, bottom: 6, right: 10) {
        didSet { invalidateIntrinsicContentSize() }
    }

    convenience init(insets: UIEdgeInsets) {
        self.init(frame: .zero)
        self.textInsets = insets
    }

    override func drawText(in rect: CGRect) {
        super.drawText(in: rect.inset(by: textInsets))
    }

    override var intrinsicContentSize: CGSize {
        var size = super.intrinsicContentSize
        size.width  += textInsets.left + textInsets.right
        size.height += textInsets.top  + textInsets.bottom
        return size
    }

    override func sizeThatFits(_ size: CGSize) -> CGSize {
        let size = super.sizeThatFits(
            CGSize(
                width: size.width - textInsets.left - textInsets.right,
                height: size.height - textInsets.top - textInsets.bottom
            )
        )
        return CGSize(
            width: size.width + textInsets.left + textInsets.right,
            height: size.height + textInsets.top + textInsets.bottom
        )
    }
}
