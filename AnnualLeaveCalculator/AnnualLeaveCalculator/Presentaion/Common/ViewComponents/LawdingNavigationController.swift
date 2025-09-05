//
//  LawdingNavigationController.swift
//  AnnualLeaveCalculator
//
//  Created by 김경록 on 8/11/25.
//
import UIKit

final class LawdingNavigationController: UINavigationController {
    
    // 공용 왼쪽 타이틀 Label
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Lawding"
        label.font = .pretendard(style: .bold, size: 20)
        label.textColor = UIColor(hex: "0015FF")
        return label
    }()
    
    // 공용 오른쪽 버튼
    private let infoButton: UIButton = {
        let button = UIButton(type: .system)
        
        let image = UIImage(systemName: "info.circle.fill")
        button.setImage(image, for: .normal)
        button.tintColor = UIColor(hex: "0015FF")
        button.addTarget(nil, action: #selector(infoButtonTapped), for: .touchUpInside)
        return button
    }()
    
    override init(rootViewController: UIViewController) {
        super.init(rootViewController: rootViewController)
        delegate = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func infoButtonTapped() {
        print("오른쪽 버튼 탭")
    }
    
    private func setupCommonNavigationBar() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(hex: "#F5F5F5")
        appearance.shadowColor = .clear
        navigationBar.standardAppearance = appearance
        navigationBar.scrollEdgeAppearance = appearance
        navigationBar.compactAppearance = appearance
        navigationBar.isTranslucent = false
    }
    
    private func applyNavigationItems(to viewController: UIViewController) {
        if viewControllers.count > 1 {
            // 스택이 2 이상일 때 → Back 버튼
            let backButton = UIButton(type: .system)
            let image = UIImage(systemName: "chevron.left")?
                .withConfiguration(UIImage.SymbolConfiguration(weight: .medium))
            backButton.setImage(image, for: .normal)
            
            backButton.tintColor = UIColor(hex: "0015FF")
            backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
            
            viewController.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backButton)
        } else {
            // 루트일 때 → Lawding 타이틀
            viewController.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: titleLabel)
            viewController.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: infoButton)
        }
    }
    @objc private func backButtonTapped() {
        popViewController(animated: true)
    }
}

extension LawdingNavigationController: UINavigationControllerDelegate {
    func navigationController(
        _ navigationController: UINavigationController,
        willShow viewController: UIViewController,
        animated: Bool
    ) {
        setupCommonNavigationBar()
        applyNavigationItems(to: viewController)
    }
}
