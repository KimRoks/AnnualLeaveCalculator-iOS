//
//  ResultBadgeLabel.swift
//  AnnualLeaveCalculator
//
//  Created by 김경록 on 9/6/25.
//

import UIKit
import SnapKit

final class ResultBadgeButton: UIButton {
    public func configure(type: CalculationResultDTO.LeaveType) {
        self.currentType = type
        applyConfiguration()
    }

    private var currentType: CalculationResultDTO.LeaveType = .annual

    private let textColor   = UIColor(hex: "#2850D7") // 40,80,215
    private let bgColor     = UIColor(hex: "#E7F2FF") // 231,242,255
    private let borderColor = UIColor(hex: "#BAD7FC") // 186,215,252


    override init(frame: CGRect) {
        super.init(frame: frame)
        isUserInteractionEnabled = false
        setContentCompressionResistancePriority(.required, for: .horizontal)
        setContentHuggingPriority(.required, for: .horizontal)
        applyConfiguration()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Configure
    private func applyConfiguration() {
        var config = UIButton.Configuration.plain()
        let title = titleForType(currentType)
        
        config.attributedTitle = AttributedString(
            title,
            attributes: AttributeContainer([.font: UIFont.pretendard(style: .bold, size: 12)])
        )

        config.baseForegroundColor = textColor

        var bg = UIBackgroundConfiguration.clear()
        bg.backgroundColor = bgColor
        bg.cornerRadius = 8
        bg.strokeColor = borderColor
        bg.strokeWidth = 1
        bg.backgroundInsets = NSDirectionalEdgeInsets(top: 4, leading: 6, bottom: 4, trailing: 6)
        config.background = bg
        config.titleAlignment = .center

        self.configuration = config
    }

    private func titleForType(_ type: CalculationResultDTO.LeaveType) -> String {
        switch type {
        case .monthly:               return "월차"
        case .annual:                return "연차"
        case .prorated:              return "비례연차"
        case .monthlyAndProrated:    return "월차 + 비례연차"
        }
    }
}
