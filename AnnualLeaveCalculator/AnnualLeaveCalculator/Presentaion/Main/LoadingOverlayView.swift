//
//  LoadingOverlayView.swift
//  AnnualLeaveCalculator
//
//  Created by 김경록 on 9/7/25.
//

import UIKit

final class LoadingOverlayView: UIView {
    private let blur = UIVisualEffectView(effect: UIBlurEffect(style: .systemThinMaterialDark))
    private let indicator = UIActivityIndicatorView(style: .large)
    private let label: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 13, weight: .medium)
        l.textColor = .secondarySystemBackground
        l.textAlignment = .center
        l.numberOfLines = 0
        return l
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.black.withAlphaComponent(0.2)
        addSubview(blur)
        blur.contentView.addSubview(indicator)
        blur.contentView.addSubview(label)

        blur.layer.cornerRadius = 12
        blur.clipsToBounds = true

        blur.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.lessThanOrEqualTo(260)
            make.leading.greaterThanOrEqualToSuperview().offset(24)
        }
        indicator.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(16)
            make.centerX.equalToSuperview()
        }
        label.snp.makeConstraints { make in
            make.top.equalTo(indicator.snp.bottom).offset(10)
            make.leading.trailing.equalToSuperview().inset(16)
            make.bottom.equalToSuperview().inset(16)
        }
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    func set(text: String?) { label.text = text ?? "계산 중..." }
    func start() { indicator.startAnimating() }
    func stop()  { indicator.stopAnimating() }
}
