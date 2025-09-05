//
//  SubtitleLabel.swift
//  AnnualLeaveCalculator
//
//  Created by 김경록 on 8/21/25.
//

import UIKit

final class SubtitleLabel: UILabel {
    
    init(title: String) {
        super.init(frame: .zero)
        setupLabel(with: title)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupLabel(with title: String) {
        self.text = title
        self.textColor = UIColor.systemGray
        self.font = .pretendard(style: .bold, size: 16)
    }
}
