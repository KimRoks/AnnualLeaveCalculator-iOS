//
//  OptionalLabel.swift
//  AnnualLeaveCalculator
//
//  Created by 김경록 on 8/29/25.
//

import UIKit

final class OptionalLabel: UILabel {
    // MARK: - Init
    init() {
        super.init(frame: .zero)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    // MARK: - Private Methods
    private func setupUI() {
        text = "선택사항"
        textColor = UIColor(hex: "#8E8E93")
        font = .pretendard(style: .regular, size: 12)
    }
}
