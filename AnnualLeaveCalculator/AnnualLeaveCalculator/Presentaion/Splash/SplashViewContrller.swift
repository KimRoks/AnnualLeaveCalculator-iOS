//
//  SplashViewController.swift
//  AnnualLeaveCalculator
//
//  Created by 김경록 on 10/20/25.
//

import UIKit
import SnapKit

/// 런치스크린과 동일한 스플래시 화면.
/// - 지정 시간 경과 후 completion 호출만 수행.
final class SplashViewController: UIViewController {

    // MARK: - UI
    
    private let splashImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "LaunchScreen"))
        imageView.contentMode = .scaleAspectFit
        imageView.isAccessibilityElement = true
        imageView.accessibilityLabel = "LawDing, 연차계산기"
        
        return imageView
    }()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupLayout()
        setupConstraints()
    }

    // MARK: - Public API

    /// N초 뒤에 completion만 호출
    func start(minimumDuration: TimeInterval = 1.0,
               completion: @escaping () -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + minimumDuration) {
            completion()
        }
    }

    // MARK: - Private

    private func setupLayout() {
        view.addSubview(splashImageView)
    }

    private func setupConstraints() {
        splashImageView.snp.makeConstraints {
            $0.centerX.equalTo(view.safeAreaLayoutGuide.snp.centerX)
            $0.centerY.equalTo(view.snp.centerY).offset(-80)
        }
    }
}
