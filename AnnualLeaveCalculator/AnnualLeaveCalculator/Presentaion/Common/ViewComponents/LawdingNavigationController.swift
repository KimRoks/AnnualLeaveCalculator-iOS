//
//  LawdingNavigationController.swift
//  AnnualLeaveCalculator
//
//  Created by 김경록 on 8/11/25.
//
import UIKit

final class LawdingNavigationController: UINavigationController {
    
    private let navigationFontSize: CGFloat = 20
    
    // 공용 왼쪽 타이틀 Label
    private lazy var titleLabel: PaddedLabel = {
        let label = PaddedLabel(insets: UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0))
        label.text = "Lawding"
        label.font = .pretendard(
            style: .bold,
            size: self.navigationFontSize
        )
        label.textColor = UIColor(hex: "0015FF")
        return label
    }()
    
    // 공용 오른쪽 버튼
    private let infoButton: UIButton = {
        let button = UIButton(type: .system)

        var config = UIButton.Configuration.plain()
        let symbolConfig = UIImage.SymbolConfiguration(pointSize: 17, weight: .medium)
        config.image = UIImage(systemName: "line.3.horizontal", withConfiguration: symbolConfig)

        config.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 10)

        config.baseForegroundColor = UIColor(hex: "0015FF")
        button.configuration = config

        button.heightAnchor.constraint(greaterThanOrEqualToConstant: 44).isActive = true
        button.widthAnchor.constraint(greaterThanOrEqualToConstant: 44).isActive = true

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
        let infoViewController = InfoViewController()
        self.pushViewController(infoViewController, animated: true)
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
            var config = UIButton.Configuration.plain()
            let chevron = UIImage(systemName: "chevron.left")?
                .applyingSymbolConfiguration(.init(weight: .medium))
            config.image = chevron
            
            config.attributedTitle = AttributedString(
                "Back",
                attributes: AttributeContainer([.font: UIFont.pretendard(style: .bold, size: navigationFontSize)])
            )
            config.imagePadding = 4
            config.baseForegroundColor = UIColor(hex: "0015FF")
            config.contentInsets = .init(top: 0, leading: 10, bottom: 0, trailing: 0)
            backButton.configuration = config

            viewController.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backButton)
            backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
            
            if viewController is ResultViewController {
                let titleLabel = UILabel()
                titleLabel.text = "계산결과"
                titleLabel.font = .pretendard(style: .bold, size: navigationFontSize)
                titleLabel.textColor = UIColor(hex: "0015FF")
                titleLabel.textAlignment = .center
                titleLabel.adjustsFontSizeToFitWidth = true
                titleLabel.minimumScaleFactor = 0.9
                viewController.navigationItem.titleView = titleLabel
            } else {
                viewController.navigationItem.titleView = nil
            }
        } else {
            // 루트일 때 → Lawding 타이틀
            viewController.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: titleLabel)
            
            // TODO: 메뉴 버튼 추후 업데이트
            
//            viewController.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: infoButton)
            viewController.navigationItem.titleView = nil
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
