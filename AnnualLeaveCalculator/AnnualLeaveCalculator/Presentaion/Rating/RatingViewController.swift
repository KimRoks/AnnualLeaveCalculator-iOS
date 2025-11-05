//
//  RatingViewController.swift
//  AnnualLeaveCalculator
//
//  Created by 김경록 on 11/6/25.
//

import UIKit
import SnapKit

final class RatingViewController: UIViewController, ToastDisplayable {

    // MARK: - Dependencies
    private let useCase: AnnualLeaveCalculatorUseCase
    private let ratingManager: RatingPromptManager
    private let logger = FirebaseAnalyticsLogger()
    
    // MARK: - State
    private var selectedRating: Int? {
        didSet {
            guard selectedRating != oldValue else { return }
            selectionHaptic.selectionChanged()
            selectionHaptic.prepare()
            updateConfirmState()
            updateStars(selected: selectedRating ?? 0)
        }
    }

    // MARK: - Haptics
    private let selectionHaptic = UISelectionFeedbackGenerator()

    // MARK: - UI
    private let dimView = UIView()
    private let contentView = UIView()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "만족도를 남겨주세요!"
        label.font = .pretendard(style: .semiBold, size: 18)
        label.textColor = .label
        label.textAlignment = .center
        return label
    }()

    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "여러분의 의견이 큰 도움이 됩니다."
        label.font = .pretendard(style: .regular, size: 14)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        return label
    }()

    private let starsStack = UIStackView()
    private var starButtons: [UIButton] = []

    private let confirmButton: ConfirmButton = ConfirmButton(title: "보내기")
    private let spinner = UIActivityIndicatorView(style: .medium)

    // MARK: - Init
    init(
        useCase: AnnualLeaveCalculatorUseCase,
        ratingManager: RatingPromptManager
    ) {
        self.useCase = useCase
        self.ratingManager = ratingManager
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .overFullScreen
        modalTransitionStyle = .crossDissolve
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) not implemented") }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupConstraints()
        setupStars()
        setupGestures()

        selectionHaptic.prepare()
        // ✅ 초기값 5점
        selectedRating = 5
        updateConfirmState()
    }

    // MARK: - Setup
    private func setupViews() {
        // dim
        view.addSubview(dimView)
        dimView.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        dimView.alpha = 0

        // card
        view.addSubview(contentView)
        contentView.backgroundColor = .systemBackground
        contentView.layer.cornerRadius = 16
        contentView.layer.masksToBounds = true

        // stars stack
        starsStack.axis = .horizontal
        starsStack.alignment = .center
        starsStack.distribution = .fillEqually
        starsStack.spacing = 8

        contentView.addSubview(titleLabel)
        contentView.addSubview(subtitleLabel)
        contentView.addSubview(starsStack)
        contentView.addSubview(confirmButton)
        contentView.addSubview(spinner)

        spinner.hidesWhenStopped = true
        confirmButton.addTarget(
            self,
            action: #selector(didTapConfirm),
            for: .touchUpInside
        )

        UIView.animate(withDuration: 0.2) { self.dimView.alpha = 1 }
    }

    private func setupConstraints() {
        dimView.snp.makeConstraints { $0.edges.equalToSuperview() }

        contentView.snp.makeConstraints {
            $0.centerY.equalTo(view.safeAreaLayoutGuide).offset(-20)
            $0.leading.equalToSuperview().offset(28)
            $0.trailing.equalToSuperview().inset(28)
        }

        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(20)
            $0.leading.trailing.equalToSuperview().inset(16)
        }
        subtitleLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(6)
            $0.leading.trailing.equalToSuperview().inset(16)
        }
        starsStack.snp.makeConstraints {
            $0.top.equalTo(subtitleLabel.snp.bottom).offset(16)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(44)
        }
        confirmButton.snp.makeConstraints {
            $0.top.equalTo(starsStack.snp.bottom).offset(16)
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.height.equalTo(44)
            $0.bottom.equalToSuperview().inset(16)
        }
        spinner.snp.makeConstraints { $0.center.equalTo(starsStack) }
    }

    private func setupStars() {
        for i in 1...5 {
            let button = makeStarButton(tag: i)
            button.addTarget(self, action: #selector(didTapStar(_:)), for: .touchUpInside)
            starButtons.append(button)
            starsStack.addArrangedSubview(button)
        }
        updateStars(selected: 0) // 초기 렌더(선택 반영은 selectedRating 세터에서 다시 함)
    }

    private func makeStarButton(tag: Int) -> UIButton {
        let symbolConfig = UIImage.SymbolConfiguration(pointSize: 28, weight: .regular)
        let empty = UIImage(systemName: "star", withConfiguration: symbolConfig)?
            .withRenderingMode(.alwaysTemplate)
        let filled = UIImage(systemName: "star.fill", withConfiguration: symbolConfig)?
            .withRenderingMode(.alwaysTemplate)

        var config = UIButton.Configuration.plain()
        config.background.backgroundColor = .clear
        config.contentInsets = .zero

        let button = UIButton(configuration: config, primaryAction: nil)
        button.tag = tag
        button.setImage(empty, for: .normal)
        button.setImage(filled, for: .selected)
        button.showsMenuAsPrimaryAction = false
        button.tintColor = .tertiaryLabel

        button.configurationUpdateHandler = { btn in
            btn.configuration?.background.backgroundColor = .clear
        }
        return button
    }

    private func setupGestures() {
        let outsideTap = UITapGestureRecognizer(
            target: self,
            action: #selector(didTapOutside)
        )
        outsideTap.cancelsTouchesInView = false
        dimView.addGestureRecognizer(outsideTap)
    }

    // MARK: - Actions
    @objc private func didTapOutside() {
        ratingManager.markDismissedThisSession()
        logger.log(.ratingDismissed)
        dismiss(animated: true)
    }

    @objc private func didTapStar(_ sender: UIButton) {
        selectedRating = sender.tag
    }

    @objc private func didTapConfirm() {
        guard let rating = selectedRating else { return }

        setLoading(true)
        Task { [weak self] in
            guard let self = self else { return }
            do {
                try await self.useCase.submitRating(
                    type: .satisfaction,
                    content: nil,
                    email: nil,
                    rating: rating,
                    calculationId: nil
                )
                await MainActor.run {
                    self.setLoading(false)
                    self.dismiss(animated: true)
                    self.showToast(message: "피드백 전송을 완료했어요.")
                    self.ratingManager.markSubmitted()
                    self.logger.log(.ratingSubmitted(score: rating))
                }
            } catch {
                await MainActor.run {
                    self.setLoading(false)
                    self.presentErrorAlert(error)
                }
            }
        }
    }

    // MARK: - Helpers
    private func updateStars(selected: Int) {
        for (index, button) in starButtons.enumerated() {
            button.isSelected = index < selected
            button.tintColor = button.isSelected ? .systemYellow : .tertiaryLabel
        }
    }

    private func updateConfirmState() {
        let enabled = (selectedRating != nil)
        confirmButton.isEnabled = enabled
        confirmButton.alpha = enabled ? 1.0 : 0.5
    }

    private func setLoading(_ loading: Bool) {
        if loading { spinner.startAnimating() } else { spinner.stopAnimating() }
        starButtons.forEach { $0.isUserInteractionEnabled = !loading }
        confirmButton.isEnabled = !loading && (selectedRating != nil)
        confirmButton.alpha = confirmButton.isEnabled ? 1.0 : 0.5
    }

    private func presentErrorAlert(_ error: Error) {
        let alert = UIAlertController(
            title: "전송 실패",
            message: (error as NSError).localizedDescription,
            preferredStyle: .alert
        )
        alert.addAction(.init(title: "확인", style: .default))
        present(alert, animated: true)
    }
}
