//
//  SplashViewContrller.swift
//  AnnualLeaveCalculator
//
//  Created by 김경록 on 10/20/25.
//

import UIKit
import SnapKit

/// 런치스크린과 동일한 스플래시 화면.
/// - 최소 표시 시간 + 준비 작업 완료를 모두 만족하면 콜백으로 종료.
final class SplashViewController: UIViewController {
    
    // MARK: - UI
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "LawDing"
        label.font = .pretendard(style: .extraBold, size: 50)
        label.textColor = UIColor.brandColor
        label.textAlignment = .center
        
        return label
    }()
    
    private let subTitleLabel: UILabel = {
        let label = UILabel()
        label.font = .pretendard(style: .semiBold, size: 23)
        label.textColor = UIColor.brandColor
        label.textAlignment = .center
        label.text = "연차계산기"
        
        return label
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupLayout()
        setupConstraints()
    }
    
    // MARK: - Public API
    
    func start(
        minimumDuration: TimeInterval = 1.0,
        completion: @escaping () -> Void
    ) {
        DispatchQueue.main.asyncAfter(deadline: .now() + minimumDuration) {
            completion()
        }
    }
    
    // MARK: - Private
    
    private func setupLayout() {
        view.addSubviews(
            titleLabel,
            subTitleLabel
        )
    }
    
    private func setupConstraints() {
        titleLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.centerY.equalToSuperview().offset(-80)
        }
        subTitleLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(10)
            $0.centerX.equalToSuperview()
        }
    }
}
