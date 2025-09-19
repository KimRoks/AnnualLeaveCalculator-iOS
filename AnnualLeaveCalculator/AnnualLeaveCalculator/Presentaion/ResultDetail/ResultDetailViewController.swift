//
//  ResultDetailViewController.swift
//  AnnualLeaveCalculator
//
//  Created by 김경록 on 9/19/25.
//

import UIKit
import SnapKit

final class ResultDetailViewController: BaseViewController {
    // MARK: - Init
    init(result: CalculationResultDTO) {
        self.result = result
        super.init(nibName: nil, bundle: nil)
    }
    
    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}
