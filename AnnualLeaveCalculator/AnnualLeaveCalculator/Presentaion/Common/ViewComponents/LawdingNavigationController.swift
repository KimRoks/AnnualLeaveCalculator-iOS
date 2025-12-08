//
//  LawdingNavigationController.swift
//  AnnualLeaveCalculator
//
//  Created by 김경록 on 8/11/25.
//

import UIKit

final class LawdingNavigationController: UINavigationController {
    
    private let navigationFontSize: CGFloat = 20
    
    private lazy var titleLabel: PaddedLabel = {
        let label = PaddedLabel(insets: .init(top: 0, left: 10, bottom: 0, right: 0))
        label.text = "LawDing"
        label.font = .pretendard(style: .bold, size: navigationFontSize)
        label.textColor = UIColor.brandColor

        return label
    }()
    
    private let infoButton: UIButton = {
        let button = UIButton(type: .system)
        var config = UIButton.Configuration.plain()
        let symbolConfig = UIImage.SymbolConfiguration(pointSize: 17, weight: .medium)
        config.image = UIImage(systemName: "info.square.fill", withConfiguration: symbolConfig)
        config.contentInsets = .init(top: 0, leading: 10, bottom: 0, trailing: 10)
        config.baseForegroundColor = UIColor.brandColor
        button.configuration = config
        button.heightAnchor.constraint(greaterThanOrEqualToConstant: 44).isActive = true
        button.widthAnchor.constraint(greaterThanOrEqualToConstant: 44).isActive = true
        button.addTarget(nil, action: #selector(infoButtonTapped), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        delegate = self
        setupCommonNavigationBar()
    }
    
    override init(rootViewController: UIViewController) {
        super.init(rootViewController: rootViewController)
        delegate = self
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        delegate = self
    }
    
    @objc private func infoButtonTapped() {
        let vc = InfoViewController()
        pushViewController(vc, animated: true)
    }
    
    private func setupCommonNavigationBar() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .BackgroundColor
        appearance.shadowColor = .clear
        
        let titleAttrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.pretendard(style: .bold, size: navigationFontSize),
            .foregroundColor: UIColor.brandColor
        ]
        appearance.titleTextAttributes = titleAttrs
        let plain = UIBarButtonItemAppearance(style: .plain)
        appearance.buttonAppearance = plain
        appearance.doneButtonAppearance = plain
        appearance.backButtonAppearance = plain
        
        navigationBar.standardAppearance = appearance
        navigationBar.scrollEdgeAppearance = appearance
        navigationBar.compactAppearance = appearance
        navigationBar.isTranslucent = false
        
        navigationBar.tintColor = UIColor.brandColor
    }
    
    private func applyNavigationItems(to viewController: UIViewController) {
        // 공통 Back 버튼/루트 처리
        if viewControllers.count > 1 {
            let backButton = UIButton(type: .system)
            var config = UIButton.Configuration.plain()
            let chevron = UIImage(systemName: "chevron.left")?
                .applyingSymbolConfiguration(.init(weight: .medium))
            config.image = chevron
            config.attributedTitle = AttributedString(
                "뒤로",
                attributes: AttributeContainer(
                    [.font: UIFont.pretendard(style: .bold, size: navigationFontSize)]
                )
            )
            config.imagePadding = 4
            config.baseForegroundColor = UIColor.brandColor
            config.contentInsets = .init(top: 0, leading: 10, bottom: 0, trailing: 0)
            backButton.configuration = config
            viewController.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backButton)
            backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        } else {
            viewController.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: titleLabel)
            viewController.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: infoButton)
        }
        
        let titleText = (viewController as? NavigationBarTitlePresentable)?.navigationTitle
        viewController.navigationItem.titleView = nil
        viewController.navigationItem.title = titleText
    }
    
    func refreshTitle(for viewController: UIViewController) {
        applyNavigationItems(to: viewController)
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
