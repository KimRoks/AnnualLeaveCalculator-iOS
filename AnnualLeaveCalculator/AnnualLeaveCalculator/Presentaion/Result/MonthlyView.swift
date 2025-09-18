//
//  MonthlyView.swift
//  AnnualLeaveCalculator
//
//  Created by 김경록 on 9/7/25.
//

import UIKit

final class MonthlyView: UIView {
    
    init(result: CalculationResultDTO) {
        super.init(frame: .zero)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private let keyValueTitleLabel = OptionalLabel()
    private let keyValueLabel = UILabel()
    private let accrualPeriodTitleLabel = OptionalLabel()
    private let accrualPeriodLabel = UILabel()
    private let availablePeriodTitleLabel = OptionalLabel()
    private let availablePeriodLabel = UILabel()
    private let totalValueTitleLable = OptionalLabel()
    private let totalValueLable = UILabel()
    
    
    private func configureUI(with result: CalculationResultDTO) {
        keyValueTitleLabel.setTitle(for: result.leaveType.rawValue)
        
        
    }
}
