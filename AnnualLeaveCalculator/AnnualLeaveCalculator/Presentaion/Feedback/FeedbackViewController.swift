//
//  FeedbackViewController.swift
//  AnnualLeaveCalculator
//
//  Created by 김경록 on 10/23/25.
//

import UIKit
import SnapKit
import Combine

final class FeedbackViewController: BaseViewController {
    
    // MARK: - Dependencies
    private let result: CalculationResultDTO
    private let viewModel: FeedbackViewModel
    private var cancellables = Set<AnyCancellable>()
    
    init(
        viewModel: FeedbackViewModel,
        result: CalculationResultDTO
    ) {
        self.viewModel = viewModel
        self.result = result
        viewModel.setCalculationID.send(result.calculationId)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) not implemented")
    }

    // MARK: - Container
    
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let containerStackView: UIStackView = {
        let sv = UIStackView()
        sv.axis = .vertical
        sv.spacing = 20
        return sv
    }()
    
    // MARK: - Card
    private let card: CardStackView = CardStackView()
    
    // MARK: - 유형
    private let typeTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "유형"
        label.font = .pretendard(style: .semiBold, size: 16)
        label.textColor = .label
        return label
    }()
    
    private let typeSegmented: UISegmentedControl = {
        let items = ["오류 제보", "서비스 문의", "개선 요청", "기타"]
        let seg = UISegmentedControl(items: items)
        seg.selectedSegmentIndex = 0
        return seg
    }()
    
    // MARK: - 내용
    private let messageTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "내용"
        label.font = .pretendard(style: .semiBold, size: 16)
        label.textColor = .label
        return label
    }()
    
    private let messageContainer = UIView()
    private let messageTextView: UITextView = {
        let tv = UITextView()
        tv.font = .pretendard(style: .regular, size: 16)
        tv.textColor = .label
        tv.isScrollEnabled = false
        tv.backgroundColor = .clear
        return tv
    }()
    
    private let messagePlaceholderLabel: UILabel = {
        let label = UILabel()
        label.text = "소중한 의견을 남겨주세요.(최소 5자)"
        label.font = .pretendard(style: .regular, size: 15)
        label.textColor = .secondaryLabel
        return label
    }()
    
    // MARK: - 이메일
    private let emailTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "답변 받을 이메일(선택)"
        label.font = .pretendard(style: .semiBold, size: 16)
        label.textColor = .label
        return label
    }()
    
    private let emailTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "예) example@email.com"
        tf.keyboardType = .emailAddress
        tf.autocapitalizationType = .none
        tf.autocorrectionType = .no
        tf.borderStyle = .roundedRect
        tf.font = .pretendard(style: .regular, size: 15)
        return tf
    }()
    
    // MARK: - 첨부 스위치
    private let attachRow = UIStackView()
    
    private let attachLabel: UILabel = {
        let label = UILabel()
        label.text = "현재 계산 정보와 함께 문의 보내기"
        label.font = .pretendard(style: .semiBold, size: 16)
        label.textColor = .label
        label.numberOfLines = 0
        return label
    }()
    
    private let attachSwitch: UISwitch = {
        let sw = UISwitch()
        sw.isOn = true
        return sw
    }()
    
    private let submitButton: ConfirmButton = ConfirmButton(title: "보내기")
    
    // 내부 제약 업데이트용
    private var messageHeightConstraint: Constraint?
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLayout()
        setupConstraints()
        style()
        hookTextViewAutoGrow()
        setupSegmentedAppearance()
        bindInputs()
        bindOutputs()
        
        viewModel.setAttachCurrentCalculationInfo.send(attachSwitch.isOn)
    }
    
    // MARK: - Layout
    private func setupLayout() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(containerStackView)
        
        containerStackView.addArrangedSubview(card)
        containerStackView.addArrangedSubview(submitButton)
        
        // 카드 내부 구성
        card.addArrangedSubviews(
            typeTitleLabel,
            typeSegmented,
            messageTitleLabel,
            messageContainer,
            emailTitleLabel,
            emailTextField,
            attachRow
        )
        
        // 내용 컨테이너
        messageContainer.addSubview(messageTextView)
        messageContainer.addSubview(messagePlaceholderLabel)
        
        // 첨부 스위치 행
        attachRow.axis = .horizontal
        attachRow.alignment = .center
        attachRow.spacing = 12
        attachRow.addArrangedSubview(attachLabel)
        attachRow.addArrangedSubview(attachSwitch)
    }
    
    private func setupConstraints() {
        scrollView.snp.makeConstraints { $0.edges.equalTo(view.safeAreaLayoutGuide) }
        
        contentView.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.width.equalToSuperview()
        }
        
        containerStackView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(20)
            $0.left.equalToSuperview().offset(20)
            $0.right.equalToSuperview().inset(20)
            $0.bottom.equalToSuperview().inset(20)
        }
        
        typeSegmented.snp.makeConstraints {
            $0.height.equalTo(32)
        }
        
        // 메시지 영역(동적 높이)
        messageContainer.snp.makeConstraints {
            messageHeightConstraint = $0.height.greaterThanOrEqualTo(110).constraint
        }
        messageTextView.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(5)
        }
        messagePlaceholderLabel.snp.makeConstraints {
            $0.top.equalTo(messageTextView).inset(5)
            $0.left.equalTo(messageTextView).inset(5)
        }
        
        emailTextField.snp.makeConstraints {
            $0.height.equalTo(44)
        }
        
        attachSwitch.setContentHuggingPriority(.required, for: .horizontal)
        
        submitButton.snp.makeConstraints {
            $0.height.equalTo(50)
        }
    }
    
    private func style() {
        // 카드 안 구분을 위해 간단한 보더 (프로젝트 공통 스타일이 있으면 교체)
        messageContainer.layer.cornerRadius = 10
        messageContainer.layer.borderWidth = 1
        messageContainer.layer.borderColor = UIColor.systemGray4.cgColor
        
        // SegmentedControl 기본 여백
        card.setCustomSpacing(8, after: typeTitleLabel)
        card.setCustomSpacing(20, after: typeSegmented)
        card.setCustomSpacing(8, after: messageTitleLabel)
        card.setCustomSpacing(20, after: messageContainer)
        card.setCustomSpacing(8, after: emailTitleLabel)
        card.setCustomSpacing(20, after: emailTextField)
    }
    
    private func setupSegmentedAppearance() {
        typeSegmented.setTitleTextAttributes([
            .foregroundColor: UIColor.black,
            .font: UIFont.pretendard(style: .semiBold, size: 12)
        ], for: .selected)
        
        typeSegmented.setTitleTextAttributes([
            .foregroundColor: UIColor.gray,
            .font: UIFont.pretendard(style: .semiBold, size: 12)
        ], for: .normal)
    }
    
    // MARK: - TextView Auto Grow
    private func hookTextViewAutoGrow() {
        messageTextView.delegate = self
        updatePlaceholderVisibility()
    }
    
    private func updatePlaceholderVisibility() {
        let isEmpty = (messageTextView.text ?? "").isEmpty
        messagePlaceholderLabel.isHidden = !isEmpty
    }
    
    private func updateMessageHeight() {
        let fitting = CGSize(width: messageTextView.bounds.width, height: .greatestFiniteMagnitude)
        let target = messageTextView.sizeThatFits(fitting).height
        // 패딩 포함 여유분
        let minHeight: CGFloat = 110
        let newHeight = max(minHeight, target + 24)
        messageHeightConstraint?.update(offset: newHeight)
        UIView.animate(withDuration: 0.2) {
            self.view.layoutIfNeeded()
        }
    }
    
    // MARK: - Bindings
    private func bindInputs() {
        // 유형
        typeSegmented.addTarget(self, action: #selector(segmentedChanged(_:)), for: .valueChanged)
        
        // 메시지
        // (delegate는 AutoGrow용, 값 전달은 textDidChangeNotification으로 안전하게)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(textViewDidChangeNotification(_:)),
            name: UITextView.textDidChangeNotification,
            object: messageTextView
        )
        
        // 이메일
        emailTextField.addTarget(self, action: #selector(emailChanged(_:)), for: .editingChanged)
        
        // 첨부 스위치
        attachSwitch.addTarget(self, action: #selector(attachSwitchChanged(_:)), for: .valueChanged)
        
        // 전송
        submitButton.addTarget(self, action: #selector(didTapSubmit), for: .touchUpInside)
    }
    
    private func bindOutputs() {
        // 제출 가능 여부
        viewModel.$isSubmitEnabled
            .receive(on: RunLoop.main)
            .sink { [weak self] enabled in
                self?.submitButton.isEnabled = enabled
                self?.submitButton.alpha = enabled ? 1.0 : 0.5
            }
            .store(in: &cancellables)
        
        // 로딩
        viewModel.$isSubmitting
            .receive(on: RunLoop.main)
            .sink { [weak self] loading in
                // 간단히 버튼만 비활성/활성 (공용 로딩뷰가 있으면 그거 사용)
                self?.submitButton.isEnabled = !loading && (self?.viewModel.isSubmitEnabled ?? false)
                self?.submitButton.alpha = loading ? 0.5 : 1.0
            }
            .store(in: &cancellables)
        
        // 성공
        viewModel.$didSubmit
            .filter { $0 }
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.navigationController?.popViewController(animated: true)
                self?.showToast(message: "피드백 전송을 완료했어요.")
            }
            .store(in: &cancellables)
        
        // 에러
        viewModel.error
            .receive(on: RunLoop.main)
            .sink { [weak self] err in
                self?.showAlert(message: err.localizedDescription)
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Actions
    @objc private func segmentedChanged(_ sender: UISegmentedControl) {
        viewModel.setSelectedTypeIndex.send(sender.selectedSegmentIndex)
    }
    
    @objc private func textViewDidChangeNotification(_ note: Notification) {
        guard note.object as? UITextView === messageTextView else { return }
        let text = messageTextView.text ?? ""
        viewModel.setMessage.send(text)
    }
    
    @objc private func emailChanged(_ sender: UITextField) {
        let text = sender.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        viewModel.setReplyEmail.send((text?.isEmpty ?? true) ? nil : text)
    }
    
    @objc private func attachSwitchChanged(_ sender: UISwitch) {
        viewModel.setAttachCurrentCalculationInfo.send(sender.isOn)
        // sender.isOn이 true여도 calculationID가 nil이면 VM에서 자동으로 nil 전송됨(첨부 안 함)
    }
    
    @objc private func didTapSubmit() {
        let idx = typeSegmented.selectedSegmentIndex
            let typeTitle = typeSegmented.titleForSegment(at: idx) ?? "-"
            let msg = messageTextView.text ?? ""
            let email = emailTextField.text ?? ""
            let attach = attachSwitch.isOn

            print("""
            [Feedback] Submit tapped
              • typeIndex: \(idx) (\(typeTitle))
              • message: \(msg)
              • email: \(email)
              • attachCurrentCalcInfo: \(attach)
            """)

        view.endEditing(true)
        viewModel.submitTapped.send(())
    }
}

// MARK: - UITextViewDelegate
extension FeedbackViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        updatePlaceholderVisibility()
        updateMessageHeight()
    }
}
