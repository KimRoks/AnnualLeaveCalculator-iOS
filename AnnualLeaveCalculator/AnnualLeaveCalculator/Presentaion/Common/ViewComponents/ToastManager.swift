//
//  ToastManager.swift
//  AnnualLeaveCalculator
//
//  Created by 김경록 on 10/26/25.
//

import UIKit

import SnapKit

final class ToastManager {
    static let shared = ToastManager()
    
    private var isShowingToast = false
    
    private init() {}
    
    private let toastView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.56)
        view.layer.cornerRadius = 10
        view.clipsToBounds = true
        view.alpha = 0
        view.isUserInteractionEnabled = false
        return view
    }()
    
    private let toastLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .pretendard(
            style: .medium,
            size: 14
        )
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()
    
    func show(message: String) {
        guard let windowScene = UIApplication.shared.connectedScenes
            .first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene,
              let window = windowScene.windows.first(where: { $0.isKeyWindow }),
              !isShowingToast else {
            return
        }
        
        isShowingToast = true
        
        toastLabel.text = message
        
        if toastLabel.superview == nil {
            toastView.addSubview(toastLabel)
        }
        if toastView.superview == nil {
            window.addSubview(toastView)
        }
        
        toastLabel.snp.remakeConstraints {
            $0.top.bottom.equalToSuperview().inset(10)
            $0.centerY.equalToSuperview()
            $0.leading.trailing.equalToSuperview().inset(12)
        }
        
        toastView.snp.remakeConstraints {
            $0.centerX.equalToSuperview()
            $0.bottom.equalTo(window.safeAreaLayoutGuide.snp.bottom).offset(-80)
            $0.leading.greaterThanOrEqualToSuperview().offset(40)
            $0.trailing.lessThanOrEqualToSuperview().offset(-40)
        }
        
        UIView.animate(
            withDuration: 0.3,
            animations: {
                self.toastView.alpha = 1
            }) { _ in
                UIView.animate(
                    withDuration: 0.3,
                    delay: 1.6,
                    options: [],
                    animations: {
                        self.toastView.alpha = 0
                    }) { _ in
                        self.toastView.removeFromSuperview()
                        self.toastLabel.removeFromSuperview()
                        self.isShowingToast = false
                    }
            }
    }
}
