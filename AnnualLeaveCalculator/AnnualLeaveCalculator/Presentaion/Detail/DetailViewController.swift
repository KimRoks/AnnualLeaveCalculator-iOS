//
//  DetailViewController.swift
//  AnnualLeaveCalculator
//
//  Created by 김경록 on 8/31/25.
//

import UIKit
import SnapKit
import Combine

final class DetailViewController: BaseViewController {
    
    // MARK: - ViewModel & Combine
    let viewModel: DetailViewModel
    private var bag = Set<AnyCancellable>()
    
    /// 1. 이전 화면으로 데이터를 돌려보낼 Publisher
    let didFinish = PassthroughSubject<[DetailRow], Never>()
    
    // MARK: Card1
    private let cardStackView = CardStackView()
    private let cardView = UIView()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "특이 사항이 있는 기간"
        label.font = .pretendard(style: .bold, size: 23)
        label.textColor = UIColor(hex: "#3C3C3C")
        
        return label
    }()
    
    private let subTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "특이 사항은 최대 3개까지 입력 가능"
        label.font = .pretendard(style: .medium, size: 12)
        label.textColor = UIColor(hex: "#8E8E93")
        return label
    }()
    
    private let reasonLabel: UILabel = {
        let label = UILabel()
        label.text = "사유"
        label.font = .pretendard(style: .medium, size: 16)
        label.setContentHuggingPriority(.required, for: .horizontal)
        label.setContentCompressionResistancePriority(.required, for: .horizontal)
        return label
    }()
    
    private let dropDownButton = DropDownButton(kind: .nonWorkingTypes)
    
    private let startDateLabel: UILabel = {
        let label = UILabel()
        label.text = "시작일"
        label.font = .pretendard(style: .medium, size: 16)
        label.setContentHuggingPriority(.required, for: .horizontal)
        label.setContentCompressionResistancePriority(.required, for: .horizontal)
        return label
    }()
    
    private let startDateButton = DateButton()
    
    private let endDateLabel: UILabel = {
        let label = UILabel()
        label.text = "종료일"
        label.font = .pretendard(style: .medium, size: 16)
        label.setContentHuggingPriority(.required, for: .horizontal)
        label.setContentCompressionResistancePriority(.required, for: .horizontal)
        return label
    }()
    
    private let endDateButton = DateButton()
    
    private let reasonRow: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 8
        stackView.alignment = .center
        stackView.distribution = .fill
        return stackView
    }()
    
    private let startRow: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 8
        stackView.alignment = .center
        stackView.distribution = .fill
        return stackView
    }()
    
    private let endRow: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 8
        stackView.alignment = .center
        stackView.distribution = .fill
        return stackView
    }()
    
    // reason / start / end 세 줄을 세로로 묶는 스택
    private let infoStack: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.alignment = .fill
        stackView.distribution = .fill
        return stackView
    }()
    
    private let confirmButton: ConfirmButton = ConfirmButton(title: "추가하기")
    
    init(viewModel: DetailViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLayout()
        setupConstraints()
        bind()
        dropDownButton.onItemSelected = { [weak self] _ in
            self?.haptics(.light)
        }
        
        confirmButton.addTarget(
            self,
            action: #selector(didTapConfirm),
            for: .touchUpInside
        )
    }
    
    /// 화면이 Pop될 때 상위로 현재 데이터 전달
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if self.isMovingFromParent {
            didFinish.send(viewModel.rows)
        }
    }
    
    // MARK: - Bind
    private func bind() {
        viewModel.error
            .receive(on: RunLoop.main)
            .sink { [weak self] error in
                self?.showAlert(message: error.localizedDescription)
            }
            .store(in: &bag)
        
        viewModel.didAdd
            .receive(on: RunLoop.main)
            .sink { [weak self] in
                self?.dropDownButton.reset()
                self?.navigationController?.popViewController(animated: true)
            }
            .store(in: &bag)
    }
    
    // MARK: - Actions
    @objc private func didTapConfirm() {
        guard let reason = dropDownButton.selectedItem else {
            showAlert(message: "사유를 선택해주세요.")
            return
        }
        guard let startDate = startDateButton.currentDate else {
            showAlert(message: "시작일을 선택해주세요.")
            return
        }
        guard let endDate = endDateButton.currentDate else {
            showAlert(message: "종료일을 선택해주세요.")
            return
        }
        
        // ViewModel에 추가 요청
        viewModel.add.send(.init(reason: reason, start: startDate, end: endDate))
    }
    
    private func haptics(_ style: UIImpactFeedbackGenerator.FeedbackStyle) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.impactOccurred()
    }
    
    // MARK: - Layout
    private func setupLayout() {
        view.addSubviews(
            cardStackView
        )
        cardStackView.addArrangedSubview(cardView)
        
        reasonRow.addArrangedSubviews(
            reasonLabel,
            dropDownButton
        )
        startRow.addArrangedSubviews(
            startDateLabel,
            startDateButton
        )
        endRow.addArrangedSubviews(
            endDateLabel,
            endDateButton
        )
        infoStack.addArrangedSubviews(
            reasonRow,
            startRow,
            endRow
        )
        
        cardView.addSubviews(
            titleLabel,
            subTitleLabel,
            infoStack,
            confirmButton
        )
    }
    
    private func setupConstraints() {
        cardStackView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(16)
            $0.leading.equalTo(view.safeAreaLayoutGuide).offset(20)
            $0.trailing.equalTo(view.safeAreaLayoutGuide).inset(20)
        }
        
        // Card 내부
        titleLabel.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
        }
        subTitleLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(6)
            $0.leading.trailing.equalToSuperview()
        }
        infoStack.snp.makeConstraints {
            $0.top.equalTo(subTitleLabel.snp.bottom).offset(20)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(confirmButton.snp.top).offset(-20)
        }
        confirmButton.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalToSuperview()
            $0.height.equalTo(40)
        }
        
        dropDownButton.snp.makeConstraints {
            $0.width.equalTo(view.snp.width).multipliedBy(0.5)
        }
        
        startDateButton.snp.makeConstraints {
            $0.width.equalTo(dropDownButton)
        }
        endDateButton.snp.makeConstraints {
            $0.width.equalTo(dropDownButton)
        }
        
        endDateButton.snp.makeConstraints { $0.width.equalTo(startDateButton)
        }
    }
}
