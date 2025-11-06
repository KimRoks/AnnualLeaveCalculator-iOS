//
//  ForceUpdateAlertHostViewController.swift
//  AnnualLeaveCalculator
//
//  Created by 김경록 on 11/6/25.
//

import UIKit
import StoreKit

// MARK: - 버전 비교
struct Version: Comparable {
    let parts: [Int]
    init(_ string: String) {
        self.parts = string.split(separator: ".").map { Int($0) ?? 0 }
    }
    static func < (lhs: Version, rhs: Version) -> Bool {
        let maxCount = max(lhs.parts.count, rhs.parts.count)
        for i in 0..<maxCount {
            let l = i < lhs.parts.count ? lhs.parts[i] : 0
            let r = i < rhs.parts.count ? rhs.parts[i] : 0
            if l != r { return l < r }
        }
        return false
    }
}

// 기존 ForceUpdateViewController 대체: 알럿을 보여주는 호스트 VC
final class ForceUpdateAlertHostViewController: UIViewController, SKStoreProductViewControllerDelegate {
    private let appStoreId: String
    private let message: String
    private var didPresentOnce = false

    init(message: String, appStoreId: String) {
        self.message = message
        self.appStoreId = appStoreId
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .fullScreen
        isModalInPresentation = true
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) not implemented") }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        guard !didPresentOnce else { return }
        didPresentOnce = true

        let alert = UIAlertController(
            title: "업데이트가 필요합니다",
            message: message,
            preferredStyle: .alert
        )

        // 확인(유일한 버튼) → App Store 열기
        let confirm = UIAlertAction(title: "업데이트 하기", style: .default) { [weak self] _ in
            self?.openStore()
        }
        alert.addAction(confirm)
        alert.preferredAction = confirm

        // 바깥 터치로는 원래도 닫히지 않지만, 혹시 모를 제스처 닫기 방지
        alert.isModalInPresentation = true

        present(alert, animated: true)
    }

    private func openStore() {
        // 1) 인앱 App Store 시도
        let vc = SKStoreProductViewController()
        vc.delegate = self
        vc.isModalInPresentation = true
        let params = [SKStoreProductParameterITunesItemIdentifier: appStoreId]
        vc.loadProduct(withParameters: params) { [weak self] loaded, _ in
            guard let self = self else { return }
            if loaded {
                self.present(vc, animated: true)
            } else {
                // 2) 실패 시 App Store 앱으로
                if let url = URL(string: "itms-apps://itunes.apple.com/app/id\(self.appStoreId)") {
                    UIApplication.shared.open(url)
                }
            }
        }
    }

    func productViewControllerDidFinish(_ viewController: SKStoreProductViewController) {
        viewController.dismiss(animated: true)
    }
}

// 게이트키퍼: 알럿을 오버레이 윈도우로 띄움(앱 어디서든 막기 용도)
final class ForceUpdateGatekeeper {
    static let shared = ForceUpdateGatekeeper()
    private var window: UIWindow?

    func evaluateAndPresentIfNeeded(
        minSupportedVersion: String,
        appStoreId: String,
        message: String,
        in scene: UIWindowScene
    ) {
        let current = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "0"
        if Version(current) < Version(minSupportedVersion) {
            presentOverlay(appStoreId: appStoreId, message: message, in: scene)
        } else {
            dismissOverlay()
        }
    }

    private func presentOverlay(appStoreId: String, message: String, in scene: UIWindowScene) {
        guard window == nil else { return }
        let w = UIWindow(windowScene: scene)
        w.windowLevel = .alert + 1
        w.rootViewController = ForceUpdateAlertHostViewController(message: message, appStoreId: appStoreId)
        w.makeKeyAndVisible()
        window = w
    }

    private func dismissOverlay() {
        window?.isHidden = true
        window = nil
    }
}
