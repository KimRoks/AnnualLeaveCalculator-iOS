//
//  BaseViewController.swift
//  AnnualLeaveCalculator
//
//  Created by 김경록 on 8/31/25.
//

import UIKit

class BaseViewController: UIViewController, NavigationBarTitlePresentable {
    var navigationTitle: String? { nil }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        enableInteractivePopGesture()
        view.backgroundColor = UIColor(hex: "#F5F5F5")
    }
    
    private func enableInteractivePopGesture() {
        guard let nc = navigationController else { return }
        nc.interactivePopGestureRecognizer?.delegate = self
        nc.interactivePopGestureRecognizer?.isEnabled = (nc.viewControllers.count > 1)
    }
    
    func showAlert(message: String, title: String? = nil, actionTitle: String = "확인") {
        let ac = UIAlertController(title: title, message: message, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: actionTitle, style: .default))
        present(ac, animated: true)
    }
}

extension BaseViewController: UIGestureRecognizerDelegate {
    
}
