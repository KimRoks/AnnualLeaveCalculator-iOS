//
//  CalculationTypeButton.swift
//  AnnualLeaveCalculator
//
//  Created by 김경록 on 8/19/25.
//

import UIKit

import SnapKit

final class CalculationTypeButton: UISegmentedControl {
    // MARK: - Init
    init(items: [String]) {
        super.init(items: items)
        setupStyle()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupStyle()
    }
    
    // MARK: - Setup
    private func setupStyle() {
        selectedSegmentIndex = 0
        
        // 텍스트 스타일
        setTitleTextAttributes([
            .foregroundColor: UIColor.black,
            .font: UIFont.pretendard(style: .bold, size: 16)
        ], for: .selected)
        
        setTitleTextAttributes([
            .foregroundColor: UIColor.gray,
            .font: UIFont.pretendard(style: .bold, size: 16)
        ], for: .normal)

        // 테두리
        layer.borderWidth = 2
        layer.borderColor = UIColor(hex: "D9D9D9").cgColor
        layer.cornerRadius = 8
        clipsToBounds = true
    }
}
