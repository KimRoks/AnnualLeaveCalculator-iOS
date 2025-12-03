//
//  BaseViewController.swift
//  AnnualLeaveCalculator
//
//  Created by 김경록 on 8/31/25.
//

import UIKit
class BaseViewController: UIViewController, NavigationBarTitlePresentable, ToastDisplayable {
    var navigationTitle: String? { nil }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(hex: "#FBFBFB")
        hookInteractivePopGesture()
    }

    /// 화면이 사라질 때(뒤로 가기 등) 떠 있는 팝오버/모달을 먼저 정리
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if isMovingFromParent || navigationController?.transitionCoordinator != nil {
            presentedViewController?.dismiss(animated: false)
        }
    }

    private func hookInteractivePopGesture() {
        guard let nc = navigationController,
              let popGR = nc.interactivePopGestureRecognizer else { return }
        popGR.delegate = self
        popGR.isEnabled = (nc.viewControllers.count > 1)
    }
    func showAlert(message: String, title: String? = nil, actionTitle: String = "확인") {
        let ac = UIAlertController(title: title, message: message, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: actionTitle, style: .default))
        present(ac, animated: true)
    }
}

extension BaseViewController: UIGestureRecognizerDelegate {
    /// 인터랙티브 pop 제스처가 시작되려 할 때 팝오버가 떠 있으면 먼저 닫고, 이번 스와이프는 취소
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        // 네비 pop 제스처만 타겟팅
        if gestureRecognizer === navigationController?.interactivePopGestureRecognizer {
            if presentedViewController != nil {
                // 팝오버/모달 먼저 정리
                presentedViewController?.dismiss(animated: false)
                // 이번 제스처는 취소하고, 사용자에게 한 번 더 스와이프하도록
                return false
            }
        }
        return true
    }
}
