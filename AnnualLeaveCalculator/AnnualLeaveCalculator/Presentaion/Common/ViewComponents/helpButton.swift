//
//  helpButton.swift
//  AnnualLeaveCalculator
//
//  Created by 김경록 on 8/21/25.
//

import UIKit

final class HelpButton: UIButton {
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupButton()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupButton()
    }
    
    // MARK: - Setup
    private func setupButton() {
        let config = UIImage.SymbolConfiguration(pointSize: 16, weight: .medium)
        let image = UIImage(systemName: "questionmark.circle", withConfiguration: config)
        self.setImage(image, for: .normal)
        self.tintColor = .lightGray
        self.translatesAutoresizingMaskIntoConstraints = false
    }
}
