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
    private let card1 = CardStackView()
    private let card1view = UIView()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "특이 사항이 있는 기간"
        label.font = .pretendard(style: .bold, size: 23)
        label.textColor = .label
        return label
    }()
    
    private let subTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "특이 사항은 최대 3개까지 입력 가능"
        label.font = .pretendard(style: .medium, size: 12)
        label.textColor = UIColor(hex: "#8E8E93")
        return label
    }()
    
    // 사유
    private let reasonLabel: UILabel = {
        let label = UILabel()
        label.text = "사유"
        label.font = .pretendard(style: .medium, size: 16)
        label.setContentHuggingPriority(.required, for: .horizontal)
        label.setContentCompressionResistancePriority(.required, for: .horizontal)
        return label
    }()
    private let dropDownButton = DropDownButton()
    
    // 시작일
    private let startDateLabel: UILabel = {
        let label = UILabel()
        label.text = "시작일"
        label.font = .pretendard(style: .medium, size: 16)
        label.setContentHuggingPriority(.required, for: .horizontal)
        label.setContentCompressionResistancePriority(.required, for: .horizontal)
        return label
    }()
    
    private let startDateButton = DateButton()
    
    // 종료일
    private let endDateLabel: UILabel = {
        let label = UILabel()
        label.text = "종료일"
        label.font = .pretendard(style: .medium, size: 16)
        label.setContentHuggingPriority(.required, for: .horizontal)
        label.setContentCompressionResistancePriority(.required, for: .horizontal)
        return label
    }()
    private let endDateButton = DateButton()
    
    // 가로 행들
    private let reasonRow: UIStackView = {
        let sv = UIStackView()
        sv.axis = .horizontal
        sv.spacing = 8
        sv.alignment = .center
        sv.distribution = .fill
        return sv
    }()
    
    private let startRow: UIStackView = {
        let sv = UIStackView()
        sv.axis = .horizontal
        sv.spacing = 8
        sv.alignment = .center
        sv.distribution = .fill
        return sv
    }()
    
    private let endRow: UIStackView = {
        let sv = UIStackView()
        sv.axis = .horizontal
        sv.spacing = 8
        sv.alignment = .center
        sv.distribution = .fill
        return sv
    }()
    
    // reason / start / end 세 줄을 세로로 묶는 스택
    private let infoStack: UIStackView = {
        let sv = UIStackView()
        sv.axis = .vertical
        sv.spacing = 16
        sv.alignment = .fill
        sv.distribution = .fill
        return sv
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
        view.backgroundColor = UIColor(hex: "#F5F5F5")
        setupLayout()
        setupConstraints()
        bind()
        dropDownButton.onItemSelected = { [weak self] selected in
            // 필요 시 선택시 바로 처리
            print("선택된 값: \(selected)")
            self?.haptics(.light)
        }
        
        confirmButton.addTarget(self, action: #selector(didTapConfirm), for: .touchUpInside)
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
        // 에러 처리 (토스트/알럿 등)
        viewModel.error
            .receive(on: RunLoop.main)
            .sink { [weak self] err in
                self?.showAlert(message: err.localizedDescription)
            }
            .store(in: &bag)
        
        viewModel.didAdd
            .receive(on: RunLoop.main)
            .sink { [weak self] in
                self?.dropDownButton.reset()          
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
        self.navigationController?.popViewController(animated: true)
    }
    
    private func haptics(_ style: UIImpactFeedbackGenerator.FeedbackStyle) {
        let gen = UIImpactFeedbackGenerator(style: style)
        gen.impactOccurred()
    }
    
    // MARK: - Layout
    private func setupLayout() {
        view.addSubviews(
            card1
        )
        card1.addArrangedSubview(card1view)
        
        // spacer
        let reasonSpacer = UIView()
        let startSpacer = UIView()
        let endSpacer = UIView()
        [reasonSpacer, startSpacer, endSpacer].forEach {
            $0.setContentHuggingPriority(.defaultLow, for: .horizontal)
            $0.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        }
        
        // 행 구성
        reasonRow.addArrangedSubviews(
            reasonLabel,
            reasonSpacer,
            dropDownButton
        )
        startRow.addArrangedSubviews(
            startDateLabel,
            startSpacer,
            startDateButton
        )
        endRow.addArrangedSubviews(
            endDateLabel,
            endSpacer,
            endDateButton
        )
        infoStack.addArrangedSubviews(
            reasonRow,
            startRow,
            endRow
        )
        
        // card1 내부
        card1view.addSubviews(
            titleLabel,
            subTitleLabel,
            infoStack,
            confirmButton
        )
    }
    
    private func setupConstraints() {
        // Card1
        card1.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(16)
            $0.leading.equalTo(view.safeAreaLayoutGuide).offset(20)
            $0.trailing.equalTo(view.safeAreaLayoutGuide).inset(20)
        }
        
        // Card1 내부
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
            $0.width.equalTo(view.snp.width).multipliedBy(0.6)
        }
        
        startDateButton.snp.makeConstraints {
            $0.width.equalTo(dropDownButton)
        }
        endDateButton.snp.makeConstraints {
            $0.width.equalTo(dropDownButton)
        }
        
        endDateButton.snp.makeConstraints { $0.width.equalTo(startDateButton) }
    }
}
