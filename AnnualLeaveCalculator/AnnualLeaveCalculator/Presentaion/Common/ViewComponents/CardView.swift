//
//  CardView.swift
//  AnnualLeaveCalculator
//
//  Created by 김경록 on 8/21/25.
//

import UIKit
import SnapKit

final class CardView: UIView {

    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }

    // MARK: - Setup
    private func setupView() {
        backgroundColor = .white
        layer.cornerRadius = 12
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.05
        layer.shadowRadius = 4
        layer.shadowOffset = CGSize(width: 0, height: 2)

        // 레이아웃 마진 지정
        layoutMargins = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
    }

    /// 내부 콘텐츠를 layoutMarginsGuide를 이용해 넣는 helper
    func addContentView(_ contentView: UIView) {
        addSubview(contentView)
        contentView.snp.makeConstraints {
            $0.top.equalTo(layoutMarginsGuide.snp.top)
            $0.leading.equalTo(layoutMarginsGuide.snp.leading)
            $0.trailing.equalTo(layoutMarginsGuide.snp.trailing)
            $0.bottom.equalTo(layoutMarginsGuide.snp.bottom)
        }
    }
}
