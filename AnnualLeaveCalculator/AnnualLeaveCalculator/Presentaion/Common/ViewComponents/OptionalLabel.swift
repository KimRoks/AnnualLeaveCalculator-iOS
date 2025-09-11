//
//  OptionalLabel.swift
//  AnnualLeaveCalculator
//
//  Created by 김경록 on 8/29/25.
//

import UIKit

final class OptionalLabel: UILabel {
    // MARK: - Init
    init(title: String = "선택사항") {
        super.init(frame: .zero)
        setupUI(title: title)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    // MARK: - Private Methods
    private func setupUI(title: String) {
        text = title
        textColor = UIColor(hex: "#8E8E93")
        font = .pretendard(style: .regular, size: 12)
    }
    
    func setTitle(for title: String) {
        self.text = title
    }
}
