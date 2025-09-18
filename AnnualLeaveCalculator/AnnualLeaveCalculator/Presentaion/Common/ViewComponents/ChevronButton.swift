//
//  ChevronButton.swift
//  AnnualLeaveCalculator
//
//  Created by 김경록 on 8/29/25.
//

import UIKit

final class ChevronButton: UIButton {
    
    init(title: String) {
        super.init(frame: .zero)
        configure(title: title)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    private func configure(title: String) {
        var config = UIButton.Configuration.filled()
        config.baseBackgroundColor = .systemGray6
        config.baseForegroundColor = .systemGray
        config.cornerStyle = .medium
    
        config.attributedTitle = AttributedString(title, attributes: AttributeContainer([
            .font: UIFont.pretendard(style: .bold, size: 12)
        ]))
        
        self.configuration = config
    }
}
