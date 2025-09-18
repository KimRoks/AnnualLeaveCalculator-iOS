//
//  ResultViewController.swift
//  AnnualLeaveCalculator
//
//  Created by 김경록 on 9/5/25.
//

import UIKit
import SnapKit

final class ResultViewController: BaseViewController {
    private let result: CalculationResultDTO
    
    private var infoBottomConstraint: Constraint?
    private var availabilityBottomConstraint: Constraint?
    
    private let scrollView = UIScrollView()
    private let contentView = UIView()

    // MARK: ResultCard
    private let resultCardView: CardView = CardView()
    
    private let resultLabel: UILabel = {
        let label = UILabel()
        label.text = "계산 결과"
        label.font = .pretendard(style: .bold, size: 15)
        return label
    }()
    
    private let resultBadgeButton: ResultBadgeButton = ResultBadgeButton()
    
    private let resultDescriptionLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        let baseFont = UIFont.pretendard(style: .medium, size: 12)
        label.textColor = UIColor(hex: "#8E8E93")
        label.font = baseFont
        return label
    }()
    
    private let resultSeparator: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(hex: "#F2F2F2")
        return view
    }()
    
    private let resultCardLabel: PaddedLabel = {
        let label = PaddedLabel(insets: .init(top: 6, left: 10, bottom: 6, right: 10))
        label.backgroundColor = UIColor(hex: "#E7F2FF")
        label.textColor = UIColor(hex: "#153BD3")
        label.layer.cornerRadius = 5
        label.clipsToBounds = true
        label.textAlignment = .center
        label.font = .pretendard(style: .bold, size: 30)
        return label
    }()
    
    private let availabilityPeriodBadgeLabel: PaddedLabel = {
        let label = PaddedLabel(insets: UIEdgeInsets(top: 4, left: 8, bottom: 4, right: 8))
        label.font = .pretendard(style: .medium, size: 13)
        label.textColor = UIColor(hex: "#8E8E93")
        label.numberOfLines = 1
        label.backgroundColor = UIColor(hex: "#F7F7F7")
        label.layer.cornerRadius = 4
        label.clipsToBounds = true
        return label
    }()
    
    private let proratedAvailablePeriodBadgeLabel: PaddedLabel = {
        let label = PaddedLabel(insets: UIEdgeInsets(top: 4, left: 8, bottom: 4, right: 8))
        label.font = .pretendard(style: .medium, size: 13)
        label.textColor = UIColor(hex: "#8E8E93")
        label.numberOfLines = 1
        label.backgroundColor = UIColor(hex: "#F7F7F7")
        label.layer.cornerRadius = 4
        label.clipsToBounds = true
        return label
    }()
    
    // MARK: InfoCard
    private let infoCardView: CardView = CardView()
    
    private let infoLabel: UILabel = {
        let label = UILabel()
        label.text = "계산 정보"
        label.font = .pretendard(style: .bold, size: 15)
        return label
    }()
    
    private let infoSeparator: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(hex: "#F2F2F2")
        return view
    }()
    
    private let infoDetailStack: UIStackView = {
        let v = UIStackView()
        v.axis = .vertical
        v.spacing = 16
        return v
    }()
    
    private let monthlySectionStack: UIStackView = {
        let v = UIStackView()
        v.axis = .vertical
        v.spacing = 6
        return v
    }()
    
    private let proratedSectionStack: UIStackView = {
        let v = UIStackView()
        v.axis = .vertical
        v.spacing = 6
        return v
    }()
    
    private let infoSeparatorBottom: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor(hex: "#F2F2F2")
        return v
    }()
    
    private let totalMonthlyLabel: UILabel = UILabel()
    private let monthlyAccrualPeriodLabel: UILabel = UILabel()
    private let monthlyAvailablePeriodLabel: UILabel = UILabel()
    private let totalProratedLabel: UILabel = UILabel()
    private let proratedAccrualPeriodLabel: UILabel = UILabel()
    private let proratedAvailablePeriodLabel: UILabel = UILabel()
    private let totalLeaveDaysLabel: UILabel = UILabel()
    
    // MARK: DetailCard
    private let detailCardView: CardView = CardView()
    
    private let detailLabel: UILabel = {
        let label = UILabel()
        label.text = "상세보기"
        label.font = .pretendard(style: .bold, size: 15)
        return label
    }()
    
    private let detailButton: ChevronButton = ChevronButton(title: "이동")
    private let completeButton: ConfirmButton = ConfirmButton(title: "처음으로")
    
    // MARK: LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLayout()
        setupConstraints()
        configureUI()
        
        completeButton.addAction(UIAction { [weak self] _ in
            self?.completeButtonTapped()
        },for: .touchUpInside)
    }
    
    // MARK: init
    init(result: CalculationResultDTO) {
        self.result = result
        super.init(nibName: nil, bundle: nil)
    }
    
    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func completeButtonTapped() {
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    // MARK: ConfigureUI
    private func configureUI() {
        resultBadgeButton.configure(type: result.leaveType)
        bindResultDescriptionLabel()
        resultCardLabel.text = "총 \(result.calculationDetail.totalLeaveDays)일"
        bindAvailabilityPeriodLabel()
        bindProratedAvailablePeriodLabel()
        setupInfoSections()
        bindDetailSections(with: result)
    }
    
    private func setupInfoSections() {
        [totalMonthlyLabel,
         totalProratedLabel,
         totalLeaveDaysLabel
        ].forEach {
            $0.font = .pretendard(style: .bold, size: 14)
            $0.textColor = .label
            $0.numberOfLines = 1
        }
        [monthlyAccrualPeriodLabel, monthlyAvailablePeriodLabel,
         proratedAccrualPeriodLabel, proratedAvailablePeriodLabel].forEach {
            $0.font = .pretendard(style: .regular, size: 12)
            $0.textColor = UIColor(hex: "#8E8E93")
            $0.numberOfLines = 1
        }
        
        // 섹션 구성
        monthlySectionStack.addArrangedSubviews(
            totalMonthlyLabel,
            monthlyAccrualPeriodLabel,
            monthlyAvailablePeriodLabel
        )
        
        proratedSectionStack.addArrangedSubviews(
            totalProratedLabel,
            proratedAccrualPeriodLabel,
            proratedAvailablePeriodLabel
        )
        
        // 순서: 월별 → 비례(옵셔널) → 구분선 → 총합
        infoCardView.addSubview(infoDetailStack)
        infoDetailStack.addArrangedSubviews(
            monthlySectionStack,
            proratedSectionStack,
            infoSeparatorBottom,
            totalLeaveDaysLabel
        )
        
        infoSeparatorBottom.snp.makeConstraints {
            $0.height.equalTo(1)
        }
        
        // infoSeparator 바로 아래에 배치
        infoDetailStack.snp.makeConstraints {
            $0.top.equalTo(infoSeparator.snp.bottom).offset(10)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.bottom.equalToSuperview().inset(20)
        }
    }
    
    private func bindDetailSections(with result: CalculationResultDTO) {
        totalLeaveDaysLabel.text = "총 연차 합계: \(result.calculationDetail.totalLeaveDays)일"

        let monthly = result.calculationDetail.monthlyDetail
        let prorated = result.calculationDetail.proratedDetail

        if let m = monthly {
            totalMonthlyLabel.text = "월차 합계: \(m.totalLeaveDays)일"
            monthlyAccrualPeriodLabel.text = "월차 산정기간: \(m.accrualPeriod.startDate) ~ \(m.accrualPeriod.endDate)"
            monthlyAvailablePeriodLabel.text = "월차 가용 기간: \(m.availablePeriod.startDate) ~ \(m.availablePeriod.endDate)"
            monthlySectionStack.isHidden = false
        } else {
            monthlySectionStack.isHidden = true
            totalMonthlyLabel.text = nil
            monthlyAccrualPeriodLabel.text = nil
            monthlyAvailablePeriodLabel.text = nil
        }

        // 비례
        if let p = prorated {
            totalProratedLabel.text = "비례연차 합계: \(p.totalLeaveDays)일"
            proratedAccrualPeriodLabel.text = "비례연차 산정 기간: \(p.accrualPeriod.startDate) ~ \(p.accrualPeriod.endDate)"
            proratedAvailablePeriodLabel.text = "비례연차 가용 기간: \(p.availablePeriod.startDate) ~ \(p.availablePeriod.endDate)"
            proratedSectionStack.isHidden = false
        } else {
            proratedSectionStack.isHidden = true
            totalProratedLabel.text = nil
            proratedAccrualPeriodLabel.text = nil
            proratedAvailablePeriodLabel.text = nil
        }

        // 하단 구분선: 둘 다 없으면 숨김
        let hasAnySection = (monthly != nil) || (prorated != nil)
        infoSeparatorBottom.isHidden = !hasAnySection
    }
    
    // MARK: Layout
    private func setupLayout() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        contentView.addSubviews(
            resultCardView,
            infoCardView,
            detailCardView,
            completeButton
        )
        
        resultCardView.addSubviews(
            resultLabel,
            resultBadgeButton,
            resultSeparator,
            resultDescriptionLabel,
            resultCardLabel,
            availabilityPeriodBadgeLabel,
            proratedAvailablePeriodBadgeLabel
        )
        
        infoCardView.addSubviews(
            infoLabel,
            infoSeparator
        )
        
        detailCardView.addSubviews(
            detailLabel,
            detailButton
        )
    }
    
    private func setupConstraints() {
        scrollView.snp.makeConstraints {
            $0.edges.equalTo(view.safeAreaLayoutGuide)
        }
        contentView.snp.makeConstraints {
            $0.edges.equalTo(scrollView.contentLayoutGuide)
            $0.width.equalTo(scrollView.frameLayoutGuide)
        }
        
        // Result card
        resultCardView.snp.makeConstraints {
            $0.top.equalTo(contentView.snp.top).offset(20)
            $0.leading.trailing.equalTo(contentView).inset(20)
        }
        
        resultLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(20)
            $0.leading.equalToSuperview().offset(20)
        }
        
        resultBadgeButton.snp.makeConstraints {
            $0.centerY.equalTo(resultLabel)
            $0.leading.equalTo(resultLabel.snp.trailing).offset(2)
        }
        
        resultSeparator.snp.makeConstraints {
            $0.top.equalTo(resultLabel.snp.bottom).offset(10)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(1)
        }
        
        resultDescriptionLabel.snp.makeConstraints {
            $0.top.equalTo(resultSeparator.snp.bottom).offset(10)
            $0.leading.equalToSuperview().offset(20)
        }
        
        resultCardLabel.snp.makeConstraints {
            $0.top.equalTo(resultDescriptionLabel.snp.bottom).offset(10)
            $0.leading.equalToSuperview().offset(20)
        }
        
        availabilityPeriodBadgeLabel.snp.makeConstraints {
            $0.top.equalTo(resultCardLabel.snp.bottom).offset(10)
            $0.leading.equalToSuperview().offset(20)
            availabilityBottomConstraint = $0.bottom.equalToSuperview().offset(-20).constraint
        }
        
        // 비례연차가 보여지는 케이스라면, availabilityBottom 비활성화
        availabilityBottomConstraint?.deactivate()
        
        proratedAvailablePeriodBadgeLabel.snp.makeConstraints {
            $0.top.equalTo(availabilityPeriodBadgeLabel.snp.bottom).offset(10)
            $0.leading.equalToSuperview().offset(20)
            infoBottomConstraint = $0.bottom.equalToSuperview().offset(-20).constraint
        }
        
        // Info card
        infoCardView.snp.makeConstraints {
            $0.top.equalTo(resultCardView.snp.bottom).offset(20)
            $0.leading.trailing.equalTo(contentView).inset(20)
        }
        
        infoLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(20)
            $0.leading.equalToSuperview().offset(20)
        }
        
        infoSeparator.snp.makeConstraints {
            $0.top.equalTo(infoLabel.snp.bottom).offset(5)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(1)
        }
        
        // Detail card
        detailCardView.snp.makeConstraints {
            $0.top.equalTo(infoCardView.snp.bottom).offset(20)
            $0.leading.trailing.equalTo(contentView).inset(20)
        }
        
        detailLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(20)
            $0.leading.equalToSuperview().offset(20)
            $0.bottom.equalToSuperview().offset(-20)
        }
        
        detailButton.snp.makeConstraints {
            $0.top.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().offset(-20)
            $0.bottom.equalToSuperview().offset(-20)
        }
        
        completeButton.snp.makeConstraints {
            $0.top.equalTo(detailCardView.snp.bottom).offset(20)
            $0.leading.equalTo(contentView).offset(20)
            $0.trailing.equalTo(contentView).offset(-20)
            $0.height.equalTo(50)
            $0.bottom.equalTo(contentView.snp.bottom).offset(-20)
        }
    }
    
    private func bindResultDescriptionLabel() {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.timeZone = TimeZone(identifier: "Asia/Seoul")
        formatter.dateFormat = "yyyy-MM-dd"
        
        guard
            let start = formatter.date(from: result.hireDate),
            let end = formatter.date(from: result.referenceDate)
        else {
            resultDescriptionLabel.text = "열심히 일한 당신의 총 연차는"
            return
        }
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "Asia/Seoul") ?? .current
        let diff = calendar.dateComponents([.day], from: start, to: end).day ?? 0
        let days = max(0, diff) + 1
        
        resultDescriptionLabel.text = "\(days)일간 열심히 일한 당신의 총 연차는"
    }
    
    private func formatKRDate(_ iso: String) -> String {
        let inF = DateFormatter()
        inF.calendar = .init(identifier: .gregorian)
        inF.locale = Locale(identifier: "ko_KR")
        inF.timeZone = .init(secondsFromGMT: 0)
        inF.dateFormat = "yyyy-MM-dd"
        
        let outF = DateFormatter()
        outF.calendar = .init(identifier: .gregorian)
        outF.locale = Locale(identifier: "ko_KR")
        outF.timeZone = .current
        outF.dateFormat = "yyyy년 MM월 dd일"
        
        guard let d = inF.date(from: iso) else { return iso }
        return outF.string(from: d)
    }
    
    private func bindAvailabilityPeriodLabel() {
        let font = availabilityPeriodBadgeLabel.font ?? .systemFont(ofSize: 10)
        let color = availabilityPeriodBadgeLabel.textColor ?? .label
        
        let periodText: String = {
            if let period = result.calculationDetail.availablePeriod {
                return "연차 가용 기간:  \(period.startDate) ~ \(period.endDate)"
            } else {
                return "사용 가능 기간:  -"
            }
        }()
        
        let symConfig = UIImage.SymbolConfiguration(pointSize: font.pointSize, weight: .medium)
        let symbol = UIImage(systemName: "calendar", withConfiguration: symConfig)?
            .withTintColor(color, renderingMode: .alwaysOriginal)
        
        let att = NSMutableAttributedString()
        
        if let symbol = symbol {
            let attachment = NSTextAttachment()
            attachment.image = symbol
            let yOffset = (font.capHeight - symbol.size.height) / 2
            attachment.bounds = CGRect(x: 0, y: yOffset, width: symbol.size.width, height: symbol.size.height)
            att.append(NSAttributedString(attachment: attachment))
            att.append(NSAttributedString(string: " "))
        }
        
        att.append(NSAttributedString(
            string: periodText,
            attributes: [
                .font: font,
                .foregroundColor: color
            ]
        ))
        
        availabilityPeriodBadgeLabel.attributedText = att
    }
    
    private func bindProratedAvailablePeriodLabel() {
        guard let prorated = result.calculationDetail.proratedDetail else {
            // 없으면 라벨 숨기고 하단 앵커를 availability 라벨로 내림
            proratedAvailablePeriodBadgeLabel.isHidden = true
            proratedAvailablePeriodBadgeLabel.attributedText = nil
            infoBottomConstraint?.deactivate()
            availabilityBottomConstraint?.activate()
            return
        }
        
        // 있으면 라벨 노출 + 하단 앵커를 변경
        proratedAvailablePeriodBadgeLabel.isHidden = false
        availabilityBottomConstraint?.deactivate()
        infoBottomConstraint?.activate()
        
        let font = proratedAvailablePeriodBadgeLabel.font ?? .systemFont(ofSize: 10)
        let color = proratedAvailablePeriodBadgeLabel.textColor ?? .label
        let periodText = "비례 연차 가용 기간:  \(prorated.availablePeriod.startDate) ~ \(prorated.availablePeriod.endDate)"
        
        let symConfig = UIImage.SymbolConfiguration(pointSize: font.pointSize, weight: .medium)
        let symbol = UIImage(systemName: "calendar", withConfiguration: symConfig)?
            .withTintColor(color, renderingMode: .alwaysOriginal)
        
        let att = NSMutableAttributedString()
        if let symbol {
            let attachment = NSTextAttachment()
            attachment.image = symbol
            let yOffset = (font.capHeight - symbol.size.height) / 2
            attachment.bounds = CGRect(x: 0, y: yOffset, width: symbol.size.width, height: symbol.size.height)
            att.append(NSAttributedString(attachment: attachment))
            att.append(NSAttributedString(string: " "))
        }
        att.append(NSAttributedString(string: periodText, attributes: [.font: font, .foregroundColor: color]))
        proratedAvailablePeriodBadgeLabel.attributedText = att
    }
}
